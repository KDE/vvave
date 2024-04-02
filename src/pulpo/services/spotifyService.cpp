#include "spotifyService.h"
#include <QEventLoop>
#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
 #include <QByteArrayView>

using namespace PULPO;

spotify::spotify()
{
    this->scope.insert(ONTOLOGY::ALBUM, {INFO::ARTWORK});
    this->scope.insert(ONTOLOGY::ARTIST, {INFO::ARTWORK, INFO::TAGS});
    this->scope.insert(ONTOLOGY::TRACK, {INFO::TAGS, INFO::ARTWORK, INFO::METADATA});
    connect(this, &spotify::arrayReady, this, &spotify::parse);
}

void spotify::set(const PULPO::REQUEST &request)
{
    qDebug() << "Setting the spotify request" << request.track;
    this->request = request;

    if (!scopePass()) {
        ERROR(this->request)
    }

    auto url = this->API;

    QUrl encodedArtist(this->request.track[FMH::MODEL_KEY::ARTIST]);
    encodedArtist.toEncoded(QUrl::FullyEncoded);

    switch (this->request.ontology) {
    case ONTOLOGY::ARTIST: {
        url.append("artist:");
        url.append(encodedArtist.toString());
        url.append("&type=artist&limit=5");
        break;
    }

    case ONTOLOGY::ALBUM: {
        QUrl encodedAlbum(this->request.track[FMH::MODEL_KEY::ALBUM]);
        encodedAlbum.toEncoded(QUrl::FullyEncoded);

        url.append("album:");
        url.append(encodedAlbum.toString());
        url.append("%20artist:");
        url.append(encodedArtist.toString());
        url.append("&type=album");
        break;
    }

    case ONTOLOGY::TRACK: {
        QUrl encodedTrack(this->request.track[FMH::MODEL_KEY::TITLE]);
        encodedTrack.toEncoded(QUrl::FullyEncoded);

        url.append("track:");
        url.append(encodedTrack.toString());

        url.append("&type=track&limit=5");
        break;
    }
    }

    auto credentials = this->CLIENT_ID + ":" + this->CLIENT_SECRET;
    auto auth = credentials.toLocal8Bit().toBase64();
    auto header = QByteArrayView("Basic ") + QByteArrayView(auth);

    auto sp_request = QNetworkRequest(QUrl("https://accounts.spotify.com/api/token"));
    sp_request.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");
    sp_request.setRawHeader("Authorization", header);

    static QNetworkAccessManager *manager = new QNetworkAccessManager;
    QNetworkReply *reply = manager->post(sp_request, "grant_type=client_credentials");

    connect(reply, &QNetworkReply::finished, [this, reply, url]() {
        if (reply->error()) {
            qDebug() << reply->error();
            ERROR(this->request)
        }

        auto response = reply->readAll();
        auto data = QJsonDocument::fromJson(response).object().toVariantMap();
        auto token = data["access_token"].toString();

        qDebug() << "[spotify service]: " << url << token;

        this->retrieve(url, {{"Authorization", "Bearer " + token}});

        reply->deleteLater();
    });
}

void spotify::parseArtist(const QByteArray &array)
{
    qDebug() << "trying to parse artists form spotify array";
    QJsonParseError jsonParseError;
    QJsonDocument jsonResponse = QJsonDocument::fromJson(static_cast<QString>(array).toUtf8(), &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError) {
        ERROR(this->request)
    }

    if (!jsonResponse.isObject()) {
        ERROR(this->request)
    }

    auto data = jsonResponse.object().toVariantMap();
    auto itemMap = data.value("artists").toMap().value("items");

    if (itemMap.isNull()) {
        ERROR(this->request)
    }

    QList<QVariant> items = itemMap.toList();

    if (items.isEmpty()) {
        ERROR(this->request)
    }

    auto root = items.first().toMap();

    if (this->request.info.contains(INFO::TAGS)) {
        QStringList stats;
        stats << root.value("popularity").toString();
        stats << root.value("followers").toMap().value("total").toString();

        this->responses << PULPO::RESPONSE{PULPO_CONTEXT::ARTIST_STAT, stats};

        auto genres = root.value("genres").toStringList();
        this->responses << PULPO::RESPONSE{PULPO_CONTEXT::GENRE, genres};
    }

    if (this->request.info.contains(INFO::ARTWORK)) {
        const auto images = root.value("images").toList();
        auto albumArt_url = images.isEmpty() ? "" : images.first().toMap().value("url").toString();
        this->responses << PULPO::RESPONSE{PULPO_CONTEXT::IMAGE, albumArt_url};
    }

    Q_EMIT this->responseReady(this->request, this->responses);
}

void spotify::parseAlbum(const QByteArray &array)
{
    QJsonParseError jsonParseError;
    QJsonDocument jsonResponse = QJsonDocument::fromJson(static_cast<QString>(array).toUtf8(), &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError) {
        ERROR(this->request)
    }

    if (!jsonResponse.isObject()) {
        ERROR(this->request)
    }

    QJsonObject mainJsonObject(jsonResponse.object());
    auto data = mainJsonObject.toVariantMap();
    auto itemMap = data.value("albums").toMap().value("items");

    if (itemMap.isNull()) {
        ERROR(this->request)
    }
    QList<QVariant> items = itemMap.toList();

    if (items.isEmpty()) {
        ERROR(this->request)
    }

    if (this->request.info.contains(INFO::ARTWORK)) {
        auto albumArt_url = items.first().toMap().value("images").toList().first().toMap().value("url").toString();
        this->responses << PULPO::RESPONSE{PULPO_CONTEXT::IMAGE, albumArt_url};
    }

    Q_EMIT this->responseReady(this->request, this->responses);
}

void spotify::parseTrack(const QByteArray &array)
{
    QJsonParseError jsonParseError;
    QJsonDocument jsonResponse = QJsonDocument::fromJson(static_cast<QString>(array).toUtf8(), &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError) {
        ERROR(this->request)
    }

    if (!jsonResponse.isObject()) {
        ERROR(this->request)
    }

    QJsonObject mainJsonObject(jsonResponse.object());
    auto data = mainJsonObject.toVariantMap();
    auto itemMap = data.value("tracks").toMap().value("items");

    if (itemMap.isNull()) {
        ERROR(this->request)
    }

    QList<QVariant> items = itemMap.toList();

    if (items.isEmpty()) {
        ERROR(this->request)
    }

    // get album title
    for (const auto &item : items) {
        auto album = item.toMap().value("album").toMap();
        auto trackArtist = album.value("artists").toList().first().toMap().value("name").toString();

        if (trackArtist.contains(this->request.track[FMH::MODEL_KEY::ARTIST])) {
            if (this->request.info.contains(INFO::TAGS)) {
                auto popularity = item.toMap().value("popularity").toString();
                this->responses << PULPO::RESPONSE{PULPO_CONTEXT::TRACK_STAT, popularity};
            }

            if (this->request.info.contains(INFO::METADATA)) {
                auto trackAlbum = album.value("name").toString();
                this->responses << PULPO::RESPONSE{PULPO_CONTEXT::ALBUM_TITLE, trackAlbum};

                auto trackPosition = item.toMap().value("track_number").toString();
                this->responses << PULPO::RESPONSE{PULPO_CONTEXT::TRACK_NUMBER, trackPosition};
            }

            if (this->request.info.contains(INFO::ARTWORK)) {
                auto albumArt_url = album.value("images").toList().first().toMap().value("url").toString();
                this->responses << PULPO::RESPONSE{PULPO_CONTEXT::IMAGE, albumArt_url};
            }

        } else
            continue;
    }

    Q_EMIT this->responseReady(this->request, this->responses);
}
