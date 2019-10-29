#include "nextmusic.h"
#include <QUrl>
#include <QDomDocument>
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariantMap>

#ifdef STATIC_MAUIKIT
#include "fm.h"
#else
#include <MauiKit/fm.h>
#endif

static const inline QNetworkRequest formRequest(const QUrl &url, const  QString &user, const QString &password)
{
    if(!url.isValid() && !user.isEmpty() && !password.isEmpty())
        return QNetworkRequest();

    const QString concatenated =  QString("%1:%2").arg(user, password);
    const QByteArray data = concatenated.toLocal8Bit().toBase64();
    const QString headerData = "Basic " + data;


    // Construct new QNetworkRequest with prepared header values
    QNetworkRequest newRequest(url);

    newRequest.setRawHeader(QString("Authorization").toLocal8Bit(), headerData.toLocal8Bit());
//    newRequest.setRawHeader(QByteArrayLiteral("OCS-APIREQUEST"), QByteArrayLiteral("true"));


    qDebug() << "headers" << newRequest.rawHeaderList() << newRequest.url();

    return newRequest;
}

const QString NextMusic::API = QStringLiteral("https://PROVIDER/index.php/apps/music/api/");

NextMusic::NextMusic(QObject *parent) : AbstractMusicProvider(parent) {}

FMH::MODEL_LIST NextMusic::parseResponse(const QByteArray &array)
{
    FMH::MODEL_LIST res;
    qDebug()<< "trying to parse array" << array;
    QJsonParseError jsonParseError;
    QJsonDocument jsonResponse = QJsonDocument::fromJson(static_cast<QString>(array).toUtf8(), &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError)
    {
        qDebug()<< "ERROR PARSING";
        return res;
    }

    const auto data = jsonResponse.toVariant();

    if(data.isNull() || !data.isValid())
        return res;

    const auto list = data.toList();

    if(!list.isEmpty())
    {
        for(const auto &map : list)
            res << FMH::toModel(map.toMap());
    }
    else
        res << FMH::toModel(data.toMap());

    return res;
}

void NextMusic::getCollection(const std::initializer_list<QString> &parameters)
{
    auto url = QString(NextMusic::API).replace("PROVIDER", this->m_provider).append("collection");

    qDebug()<< "QQQQQQQQQQ" << url;
    QString concatenated = this->m_user + ":" + this->m_password;
    QByteArray data = concatenated.toLocal8Bit().toBase64();
    QString headerData = "Basic " + data;

    QMap<QString, QString> header {{"Authorization", headerData.toLocal8Bit()}};

    const auto downloader = new FMH::Downloader;
    connect(downloader, &FMH::Downloader::dataReady, [&, downloader = std::move(downloader)](QByteArray array)
    {
        qDebug()<< array;
        this->parseResponse(array);
    });

    downloader->getArray(url, header);
}

void NextMusic::getTracks()
{

}

void NextMusic::getTrack(const QString &id)
{

}

void NextMusic::getArtists()
{

}

void NextMusic::getArtist(const QString &id)
{

}

void NextMusic::getAlbums()
{

}

void NextMusic::getAlbum(const QString &id)
{

}

void NextMusic::getPlaylists()
{

}

void NextMusic::getPlaylist(const QString &id)
{

}

void NextMusic::getFolders()
{

}

void NextMusic::getFolder(const QString &id)
{

}

