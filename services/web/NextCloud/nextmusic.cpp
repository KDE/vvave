#include "nextmusic.h"
#include <QUrl>
#include <QDomDocument>
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariantMap>
#include <QNetworkReply>
#include <QNetworkRequest>

#ifdef STATIC_MAUIKIT
#include "fm.h"
#include "downloader.h"
#else
#include <MauiKit/fm.h>
#include <MauiKit/downloader.h>
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

const QString NextMusic::API = QStringLiteral("/index.php/apps/music/api/");

NextMusic::NextMusic(QObject *parent) : AbstractMusicProvider(parent) {}

QVariantList NextMusic::getAlbumsList() const
{
    return this->m_albums;
}

QVariantList NextMusic::getArtistsList() const
{
    qDebug () << "ASKING FOR ARISTS" << this->m_artists;
    return this->m_artists;
}

FMH::MODEL_LIST NextMusic::parseCollection(const QByteArray &array)
{
    FMH::MODEL_LIST res;
    //  qDebug()<< "trying to parse array" << array;
    QJsonParseError jsonParseError;
    QJsonDocument jsonResponse = QJsonDocument::fromJson(static_cast<QString>(array).toUtf8(), &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError)
    {
        qDebug()<< "ERROR PARSING" << array;
        return res;
    }

    const auto data = jsonResponse.toVariant();

    if(data.isNull() || !data.isValid())
        return res;

    const auto list = data.toList();
    qDebug()<< "SOFAR GOOD PARSING";

    if(!list.isEmpty())
    {
        for(const auto &item : list)
        {
            const auto map = item.toMap();
            const auto artist = map.value("name").toString();
            const auto artistId = map.value("id").toString();

            this->m_artists.append(QVariantMap{{"artist", artist}, {"id", artistId}});

            qDebug()<< "ARTIST" << artist << artistId;

            const auto albumsList = map.value("albums").toList();
            for(const auto &albumItem : albumsList)
            {
                const auto albumMap = albumItem.toMap();
                const auto album = albumMap.value("name").toString();
                const auto albumId = albumMap.value("id").toString();
                const auto albumYear = albumMap.value("year").toString();
                const auto albumCover = albumMap.value("cover").toString();

                this->m_albums.append(QVariantMap {{"album", album}, {"artist", artist}, {"release_date", albumYear}, {"artwork", albumCover}, {"id", albumId}});


                qDebug()<< "ARTIST && ALBUM" << artist << album << artistId;

                const auto tracksList = albumMap.value("tracks").toList();
                for(const auto &trackItem : tracksList)
                {
                    const auto trackMap = trackItem.toMap();

                    const auto title = trackMap.value("title").toString();
                    const auto track = trackMap.value("number").toString();
                    const auto id = trackMap.value("id").toString();

                    const auto filesMap = trackMap.value("files").toMap();
                    for(const auto &fileKey : filesMap.keys())
                    {
                        const auto mime = fileKey;
                        const auto url = filesMap[fileKey].toString();

                        const auto trackModel = FMH::MODEL({
                                              {FMH::MODEL_KEY::ID, url},
                                              {FMH::MODEL_KEY::TITLE, title},
                                              {FMH::MODEL_KEY::TRACK, track},
                                              {FMH::MODEL_KEY::ALBUM, album},
                                              {FMH::MODEL_KEY::ARTIST, artist},
                                              {FMH::MODEL_KEY::ARTWORK, albumCover},
                                              {FMH::MODEL_KEY::RELEASEDATE, albumYear},
                                              {FMH::MODEL_KEY::SOURCE, this->m_provider}
                                          });

                        this->m_tracks.insert(url, trackModel);
                        res << trackModel;
                    }
                }
            }
        }
    }

    qDebug()<< res;
    return res;
}

FMH::MODEL NextMusic::getTrackItem(const QString &id)
{
    return this->m_tracks.value(id);
}

void NextMusic::getTrackPath(const QString &id)
{  
    QUrl relativeUrl("../.."+NextMusic::API+QString("file/%1/path").arg(id));
    auto url = QUrl(this->m_provider).resolved(relativeUrl);

    QString concatenated = this->m_user + ":" + this->m_password;
    QByteArray data = concatenated.toLocal8Bit().toBase64();
    QString headerData = "Basic " + data;

    QMap<QString, QString> header {{"Authorization", headerData.toLocal8Bit()}};

    const auto downloader = new FMH::Downloader;
    connect(downloader, &FMH::Downloader::dataReady, [this, id, _downloader = std::move(downloader)](QByteArray array)
    {
        QJsonParseError jsonParseError;
        QJsonDocument jsonResponse = QJsonDocument::fromJson(static_cast<QString>(array).toUtf8(), &jsonParseError);

        if (jsonParseError.error != QJsonParseError::NoError)
        {
            qDebug()<< "ERROR PARSING";
            return;
        }

        const auto data = jsonResponse.toVariant();

        if(data.isNull() || !data.isValid())
            return;

        const auto map = data.toMap();
        auto path = map["path"].toString();
        const auto url = this->provider() + (path.startsWith("/") ? path.remove(0,1) : path);
       emit this->trackPathReady(id, url);
    });

    downloader->getArray(url, header);
}

void NextMusic::getCollection(const std::initializer_list<QString> &parameters)
{
    QUrl relativeUrl("../.."+NextMusic::API+"collection");
    auto url = QUrl(this->m_provider).resolved(relativeUrl);

    QString concatenated = this->m_user + ":" + this->m_password;
    QByteArray data = concatenated.toLocal8Bit().toBase64();
    QString headerData = "Basic " + data;

    QMap<QString, QString> header {{"Authorization", headerData.toLocal8Bit()}};

    const auto downloader = new FMH::Downloader;
    connect(downloader, &FMH::Downloader::dataReady, [&, _downloader = std::move(downloader)](QByteArray array)
    {
        qDebug()<< "FINISHED REQUEST WITH RESPONSEC : " << array;

        const auto data = this->parseCollection(array);
        emit this->collectionReady(data);
        _downloader->deleteLater();
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

