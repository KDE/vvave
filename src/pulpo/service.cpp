#include "service.h"
#include <MauiKit3/FileBrowsing/downloader.h>

Service::Service(QObject *parent)
    : QObject(parent)
{
}

void Service::set(const PULPO::REQUEST &request)
{
    this->request = request;
}

void Service::parse(const QByteArray &array)
{
    switch (this->request.ontology) {
    case PULPO::ONTOLOGY::ALBUM:
        this->parseAlbum(array);
        break;
    case PULPO::ONTOLOGY::ARTIST:
        this->parseArtist(array);
        break;
    case PULPO::ONTOLOGY::TRACK:
        this->parseTrack(array);
        break;
    }
}

void Service::retrieve(const QString &url, const QMap<QString, QString> &headers)
{
    if (!url.isEmpty()) {
        auto downloader = new FMH::Downloader;
        connect(downloader, &FMH::Downloader::dataReady, [this, downloader](QByteArray array) {
            emit this->arrayReady(array);
            downloader->deleteLater();
        });
        downloader->getArray(url, headers);
    }
}

bool Service::scopePass()
{
    auto info = this->request.info;
    for (const auto inf : info) {
        if (!this->scope[this->request.ontology].contains(inf)) {
            info.removeAll(inf);
        }
    }

    return !info.isEmpty();
}
