#include "albumsmodel.h"
#include "db/collectionDB.h"

#include "vvave.h"

#ifdef STATIC_MAUIKIT
#include "fmstatic.h"
#include "downloader.h"
#else
#include <MauiKit/fmstatic.h>
#include <MauiKit/downloader.h>
#endif

AlbumsModel::AlbumsModel(QObject *parent) : MauiList(parent),
    db(CollectionDB::getInstance())
{
    qRegisterMetaType<FMH::MODEL_LIST>("FMH::MODEL_LIST");
    qRegisterMetaType<FMH::MODEL>("FMH::MODEL");
    qRegisterMetaType<PULPO::ONTOLOGY>("PULPO::ONTOLOGY");

    auto m_artworkFetcher = new ArtworkFetcher;
    m_artworkFetcher->moveToThread (&this->m_worker);

    connect(this, &AlbumsModel::startFetchingArtwork, m_artworkFetcher, &ArtworkFetcher::fetch);
    connect(&m_worker, &QThread::finished, m_artworkFetcher, &QObject::deleteLater);

    connect(m_artworkFetcher, &ArtworkFetcher::artworkReady, [&](FMH::MODEL item, int index)
    {
        qDebug()<< "FILE ARTWORK READY" << index << item[FMH::MODEL_KEY::ARTWORK];
        this->db->insertArtwork (item);
        this->updateArtwork (index, item[FMH::MODEL_KEY::ARTWORK]);
    });

    this->m_worker.start ();
    //    connect(this, &AlbumsModel::queryChanged, this, &AlbumsModel::setList);
}

AlbumsModel::~AlbumsModel()
{
    m_worker.quit();
    m_worker.wait();
}

void AlbumsModel::componentComplete()
{
    if(query == QUERY::ALBUMS )
    {
        connect(vvave::instance (), &vvave::albumsAdded, this, &AlbumsModel::setList);
    }else
    {
        connect(vvave::instance (), &vvave::artistsAdded, this, &AlbumsModel::setList);
    }

    connect(vvave::instance (), &vvave::sourceRemoved, this, &AlbumsModel::setList);
}

FMH::MODEL_LIST AlbumsModel::items() const
{
    return this->list;
}

void AlbumsModel::setQuery(const QUERY &query)
{
    if(this->query == query)
        return;

    this->query = query;
    emit this->queryChanged();

    setList();
}

AlbumsModel::QUERY AlbumsModel::getQuery() const
{
    return this->query;
}

bool AlbumsModel::fetchArtwork() const
{
    return m_fetchArtwork;
}

void AlbumsModel::setList()
{
    emit this->preListChanged();

    QString m_Query;
    if(this->query == AlbumsModel::QUERY::ALBUMS)
        m_Query = "select * from albums order by album asc";
    else if(this->query == AlbumsModel::QUERY::ARTISTS)
        m_Query = "select * from artists order by artist asc";
    else return;

    //get albums data with modifier for missing images for artworks
    //    const auto checker = [&](FMH::MODEL &item) -> bool
    //    {
    //        const auto artwork = item[FMH::MODEL_KEY::ARTWORK];

    //        if(artwork.isEmpty())
    //            return true;

    //        if(QUrl(artwork).isLocalFile () && !FMH::fileExists(artwork))
    //        {
    //            this->db->removeArtwork(AlbumsModel::QUERY::ALBUMS ?  "albums" : "artists", FMH::toMap(item));
    //            item[FMH::MODEL_KEY::ARTWORK] = "";
    //        }

    //        return true;
    //    };
    this->list = this->db->getDBData(m_Query);

    emit this->postListChanged();

    if(m_fetchArtwork)
    {
        this->fetchInformation();
    }
}

void AlbumsModel::fetchInformation()
{
    qDebug() << "RNUNGING BRAIN EFFORRTS";
    if(!this->list.isEmpty())
    {
        emit this->startFetchingArtwork (this->list, this->query == AlbumsModel::QUERY::ALBUMS ? PULPO::ONTOLOGY::ALBUM : PULPO::ONTOLOGY::ARTIST);
    }
}

void AlbumsModel::setFetchArtwork(bool fetchArtwork)
{
    if (m_fetchArtwork == fetchArtwork)
        return;

    m_fetchArtwork = fetchArtwork;
    emit fetchArtworkChanged(m_fetchArtwork);

    if(m_fetchArtwork)
    {
        this->fetchInformation();
    }
}

void AlbumsModel::updateArtwork(const int index, const QString &artwork)
{
    if(index >= this->list.size() || index < 0)
        return;

    this->list[index][FMH::MODEL_KEY::ARTWORK] = artwork;
    qDebug()<< "TRYIGN To UDPATE ARTWOIRK ALBUM" << index << artwork;
    emit this->updateModel(index, {FMH::MODEL_KEY::ARTWORK});
}

QVariantMap AlbumsModel::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();
    return FMH::toMap(this->list.at(index));
}

void AlbumsModel::append(const QVariantMap &item)
{
    if(item.isEmpty())
        return;

    emit this->preItemAppended();

    FMH::MODEL model;
    for(auto key : item.keys())
        model.insert(FMH::MODEL_NAME_KEY[key], item[key].toString());

    this->list << model;

    emit this->postItemAppended();
}

void AlbumsModel::append(const QVariantMap &item, const int &at)
{
    if(item.isEmpty())
        return;

    if(at > this->list.size() || at < 0)
        return;

    qDebug()<< "trying to append at" << at << item["title"];

    emit this->preItemAppendedAt(at);

    FMH::MODEL model;
    for(auto key : item.keys())
        model.insert(FMH::MODEL_NAME_KEY[key], item[key].toString());

    this->list.insert(at, model);

    emit this->postItemAppended();
}

void AlbumsModel::refresh()
{
    this->setList();
}

void ArtworkFetcher::fetch(FMH::MODEL_LIST data, PULPO::ONTOLOGY ontology)
{
    qDebug()<< "FETCHING ARTWORKS FROM THREAD";
    QList<PULPO::REQUEST> requests;
    int index = -1;
    for(auto &album : data)
    {
        index++;
        if(!album[FMH::MODEL_KEY::ARTWORK].isEmpty())
            continue;

        qDebug()<< "GETTING ARTWORK FOR << " << album[FMH::MODEL_KEY::ALBUM] << album[FMH::MODEL_KEY::ARTIST];

        if(BAE::artworkCache(album, FMH::MODEL_KEY::ALBUM))
        {
            emit this->artworkReady (album, index);
            continue;
        }

        PULPO::REQUEST request;
        request.track = album;
        request.ontology = ontology;
        request.services = {PULPO::SERVICES::LastFm, PULPO::SERVICES::Spotify};
        request.info = {PULPO::INFO::ARTWORK};
        request.callback = [&, index](PULPO::REQUEST request, PULPO::RESPONSES responses)
        {
            qDebug() << "DONE WITH " << request.track ;

            for(const auto &res : responses)
            {
                if(res.context == PULPO::CONTEXT::IMAGE)
                {
                    if(!res.value.toString().isEmpty())
                    {
                        auto downloader = new FMH::Downloader;
                        QObject::connect(downloader, &FMH::Downloader::fileSaved, [&, index, request, downloader](QString path) mutable
                        {
                            auto newTrack = request.track;
                            newTrack[FMH::MODEL_KEY::ARTWORK] = QUrl::fromLocalFile (path).toString ();
                            emit this->artworkReady (newTrack, index);
                            downloader->deleteLater();
                        });

                        const auto format = res.value.toUrl().fileName().endsWith(".png") ? ".png" : ".jpg";
                        QString name = !request.track[FMH::MODEL_KEY::ALBUM].isEmpty() ? request.track[FMH::MODEL_KEY::ARTIST] + "_" + request.track[FMH::MODEL_KEY::ALBUM] : request.track[FMH::MODEL_KEY::ARTIST];
                        name.replace("/", "-");
                        name.replace("&", "-");
                        downloader->downloadFile(res.value.toString(),  BAE::CachePath.toString() + name + format);
                        qDebug()<<"SAVING ARTWORK FOR: " << request.track[FMH::MODEL_KEY::ALBUM]<< BAE::CachePath.toString() + name + format;
                    }else
                    {
                        auto newTrack = request.track;
                        newTrack[FMH::MODEL_KEY::ARTWORK] = "qrc:/assets/cover.png";
                        emit this->artworkReady (newTrack, index);
                    }
                }
            }
        };

        requests << request;
    }

    Pulpo pulpo;
    QEventLoop loop;
    QObject::connect(&pulpo, &Pulpo::finished, &loop, &QEventLoop::quit);
    QObject::connect(&pulpo, &Pulpo::error, &loop, &QEventLoop::quit);

    for(const auto &req : requests)
    {
        pulpo.request(req);
        loop.exec();
    }

    emit this->finished();
}
