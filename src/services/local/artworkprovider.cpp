#include "artworkprovider.h"
#include "../../utils/bae.h"
#include "taginfo.h"
#include "vvave.h"
#include <MauiKit/FileBrowsing/downloader.h>
#include <QImage>

AsyncImageResponse::AsyncImageResponse(const QString &id, const QSize &requestedSize)
    : m_id(id)
    , m_requestedSize(requestedSize)
{
    auto parts = id.split(":");

    if (parts.isEmpty()) {
        m_image = QImage(":/assets/cover.png");
        emit this->finished();
        return;
    }

    auto type = parts[0];

    QString artist, album;

    if (parts.length() >= 2)
        artist = parts[1];

    if (parts.length() >= 3)
        album = parts[2];

    FMH::MODEL_KEY m_type = FMH::MODEL_KEY::ID;
    if (type == "artist") {
        m_type = FMH::MODEL_KEY::ARTIST;
    } else {
        m_type = FMH::MODEL_KEY::ALBUM;
    }

    FMH::MODEL data = {{FMH::MODEL_KEY::ARTIST, artist}, {FMH::MODEL_KEY::ALBUM, album}};

    if (BAE::artworkCache(data, m_type)) {
        qDebug() << "ARTWORK CACHED" << album << artist;
        m_image = QImage(QUrl(data[FMH::MODEL_KEY::ARTWORK]).toLocalFile());
        emit this->finished();
    } else if (vvave::instance()->fetchArtwork()) {
        auto m_artworkFetcher = new ArtworkFetcher;
        connect(m_artworkFetcher, &ArtworkFetcher::finished, m_artworkFetcher, &ArtworkFetcher::deleteLater);

        connect(m_artworkFetcher, &ArtworkFetcher::artworkReady, [this, m_artworkFetcher](QUrl url) {
            qDebug() << "FILE ARTWORK READY" << url;
            if (url.isEmpty() || !url.isLocalFile()) {
                m_image = QImage(":/assets/cover.png");
            } else {
                this->m_image = QImage(url.toLocalFile());
            }

            emit this->finished();
            m_artworkFetcher->deleteLater();
        });

        m_artworkFetcher->fetch(data, m_type == FMH::MODEL_KEY::ALBUM ? PULPO::ONTOLOGY::ALBUM : PULPO::ONTOLOGY::ARTIST);
    } else {
        m_image = QImage(":/assets/cover.png");
        emit this->finished();
    }
}

QQuickTextureFactory *AsyncImageResponse::textureFactory() const
{
    return QQuickTextureFactory::textureFactoryForImage(m_image);
}

QQuickImageResponse *ArtworkProvider::requestImageResponse(const QString &id, const QSize &requestedSize)
{
    AsyncImageResponse *response = new AsyncImageResponse(id, requestedSize);
    return response;
}

void ArtworkFetcher::fetch(FMH::MODEL data, PULPO::ONTOLOGY ontology)
{
    qDebug() << "FETCHING ARTWORKS FROM THREAD";
    PULPO::REQUEST request;
    request.track = data;
    request.ontology = ontology;
    request.services = {PULPO::SERVICES::LastFm, PULPO::SERVICES::Spotify};
    request.info = {PULPO::INFO::ARTWORK};
    request.callback = [&](PULPO::REQUEST request, PULPO::RESPONSES responses) {
        qDebug() << "DONE WITH " << request.track;

        for (const auto &res : responses) {
            if (res.context == PULPO::PULPO_CONTEXT::IMAGE) {
                auto imageUrl = res.value.toString();

                if (!imageUrl.isEmpty()) {
                    auto downloader = new FMH::Downloader;
                    QObject::connect(downloader, &FMH::Downloader::fileSaved, [&, downloader](QString path) mutable {
                        downloader->deleteLater();
                        emit this->artworkReady(QUrl::fromLocalFile(path));
                    });

                    const auto format = res.value.toUrl().fileName().endsWith(".png") ? ".png" : ".jpg";
                    QString name = !request.track[FMH::MODEL_KEY::ALBUM].isEmpty() ? request.track[FMH::MODEL_KEY::ARTIST] + "_" + request.track[FMH::MODEL_KEY::ALBUM] : request.track[FMH::MODEL_KEY::ARTIST];

                    BAE::fixArtworkImageFileName(name);

                    downloader->downloadFile(imageUrl, BAE::CachePath.toString() + name + format);
                    qDebug() << "SAVING ARTWORK FOR: " << request.track[FMH::MODEL_KEY::ALBUM] << BAE::CachePath.toString() + name + format;

                } else {
                    emit this->artworkReady(QUrl(":/assets/cover.png"));
                }
            }
        }
    };

    auto pulpo = new Pulpo;
    QObject::connect(pulpo, &Pulpo::finished, pulpo, &Pulpo::deleteLater);
    QObject::connect(pulpo, &Pulpo::error, [this, pulpo]() {
        emit this->artworkReady(QUrl(":/assets/cover.png"));
        pulpo->deleteLater();
    });

    pulpo->request(request);
}
