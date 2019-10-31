#include "albumsmodel.h"
#include "db/collectionDB.h"
#include "utils/brain.h"
#include <QtConcurrent>

AlbumsModel::AlbumsModel(QObject *parent) : MauiList(parent),
    db(CollectionDB::getInstance())
{}

void AlbumsModel::componentComplete()
{
    connect(this, &AlbumsModel::queryChanged, this, &AlbumsModel::setList);
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
}

AlbumsModel::QUERY AlbumsModel::getQuery() const
{
    return this->query;
}

void AlbumsModel::setSortBy(const SORTBY &sort)
{
    if(this->sort == sort)
        return;

    this->sort = sort;

    emit this->preListChanged();
    this->sortList();
    emit this->postListChanged();
    emit this->sortByChanged();
}

AlbumsModel::SORTBY AlbumsModel::getSortBy() const
{
    return this->sort;
}

void AlbumsModel::sortList()
{
    const auto key = static_cast<FMH::MODEL_KEY>(this->sort);
    qDebug()<< "SORTING LIST BY"<< this->sort;
    std::sort(this->list.begin(), this->list.end(), [key](const FMH::MODEL &e1, const FMH::MODEL &e2) -> bool
    {
        const auto role = key;
        switch(role)
        {
            case FMH::MODEL_KEY::RELEASEDATE:
            {
                if(e1[role].toDouble() > e2[role].toDouble())
                    return true;
                break;
            }

            case FMH::MODEL_KEY::ADDDATE:
            {
                const auto date1 = QDateTime::fromString(e1[role], Qt::TextDate);
                const auto date2 = QDateTime::fromString(e2[role], Qt::TextDate);

                if(date1.secsTo(QDateTime::currentDateTime()) <  date2.secsTo(QDateTime::currentDateTime()))
                    return true;
                break;
            }

            case FMH::MODEL_KEY::ARTIST:
            case FMH::MODEL_KEY::ALBUM:
            {
                const auto str1 = QString(e1[role]).toLower();
                const auto str2 = QString(e2[role]).toLower();

                if(str1 < str2)
                    return true;
                break;
            }

            default:
                if(e1[role] < e2[role])
                    return true;
        }

        return false;
    });
}

void AlbumsModel::setList()
{
    emit this->preListChanged();

    QString m_Query;
    if(this->query == AlbumsModel::QUERY::ALBUMS)
        m_Query = "select * from albums order by album asc";
    else if(this->query == AlbumsModel::QUERY::ARTISTS)
        m_Query = "select * from artists order by artist asc";

    //get albums data with modifier for missing images for artworks
    this->list = this->db->getDBData(m_Query, [&](FMH::MODEL &item)
    {
            if(item[FMH::MODEL_KEY::ARTWORK].isEmpty())
            return;

    if(!FMH::fileExists(item[FMH::MODEL_KEY::ARTWORK]))
    {
        const auto table = this->query == AlbumsModel::QUERY::ALBUMS ?  "albums" : "artists";
        this->db->removeArtwork(table, FMH::toMap(item));
        item[FMH::MODEL_KEY::ARTWORK] = "";
    }});

this->sortList();
emit this->postListChanged();

if(this->query == AlbumsModel::QUERY::ALBUMS)
this->fetchInformation();
}

void AlbumsModel::fetchInformation()
{
    qDebug() << "RNUNGING BRAIN EFFORRTS";
    QFutureWatcher<void> *watcher = new QFutureWatcher<void>;
    QObject::connect(watcher, &QFutureWatcher<void>::finished,
                     watcher, &QFutureWatcher<void>::deleteLater);

    //    QObject::connect(this, &AlbumsModel::destroyed, watcher, &QFutureWatcher<void>::waitForFinished);

    auto func = [&, stop = bool()]() mutable
    {
        stop = false;
        QList<PULPO::REQUEST> requests;
        int index = -1;
        for(auto &album : this->list)
        {
            index++;
            if(!album[FMH::MODEL_KEY::ARTWORK].isEmpty())
                continue;

            if(BAE::artworkCache(album, FMH::MODEL_KEY::ALBUM))
            {
                this->db->insertArtwork(album);
                emit this->updateModel(index, {FMH::MODEL_KEY::ARTWORK});
                continue;
            }

            PULPO::REQUEST request;
            request.track = album;
            request.ontology = this->query == AlbumsModel::QUERY::ALBUMS ? PULPO::ONTOLOGY::ALBUM : PULPO::ONTOLOGY::ARTIST;
            request.services = {PULPO::SERVICES::LastFm, PULPO::SERVICES::Spotify, PULPO::SERVICES::MusicBrainz};
            request.info = {PULPO::INFO::ARTWORK};
            request.callback = [&, index](PULPO::REQUEST request, PULPO::RESPONSES responses)
            {
                qDebug() << "DONE WITH " << request.track ;

                for(const auto &res : responses)
                {
                    if(res.context == PULPO::CONTEXT::IMAGE && !res.value.toString().isEmpty())
                    {
                        auto downloader = new FMH::Downloader;
                        QObject::connect(downloader, &FMH::Downloader::fileSaved, [&, index, request, _downloader = std::move(downloader)](QString path)
                        {
                            FMH::MODEL newTrack = request.track;
                            newTrack[FMH::MODEL_KEY::ARTWORK] = QUrl::fromLocalFile(path).toString();
                            this->db->insertArtwork(newTrack);
                            //                            this->updateArtwork(index, path);

                            album[FMH::MODEL_KEY::ARTWORK] = newTrack[FMH::MODEL_KEY::ARTWORK];
                            emit this->updateModel(index, {FMH::MODEL_KEY::ARTWORK});

                            _downloader->deleteLater();
                        });

                        QStringList filePathList = res.value.toString().split('/');
                        const auto format = "." + filePathList.at(filePathList.count() - 1).split(".").last();
                        QString name = !request.track[FMH::MODEL_KEY::ALBUM].isEmpty() ? request.track[FMH::MODEL_KEY::ARTIST] + "_" + request.track[FMH::MODEL_KEY::ALBUM] : request.track[FMH::MODEL_KEY::ARTIST];
                        name.replace("/", "-");
                        name.replace("&", "-");
                        downloader->setFile(res.value.toString(),  BAE::CachePath + name + format);
                        qDebug()<<"SAVING ARTWORK FOR: " << request.track[FMH::MODEL_KEY::ALBUM]<< BAE::CachePath + name + format;

                    }
                }
            };

            requests << request;
        }

        Pulpo pulpo;
        QEventLoop loop;
        QObject::connect(&pulpo, &Pulpo::finished, &loop, &QEventLoop::quit);
        QObject::connect(this, &AlbumsModel::destroyed, [&pulpo, &loop, &stop]()
        {
            qDebug()<< stop << &stop;
            pulpo.disconnect();
            stop = true;
            if(loop.isRunning())
                loop.quit();
            qDebug()<< stop << &stop;
        });

        for(const auto &req : requests)
        {
            if(stop)
            {
                qDebug()<< "TRYING EXITING THREAD LOADINFO" << loop.isRunning();
                qDebug()<< "EXITING THREAD LOADINFO" << loop.isRunning();
                break;
            }else {
                pulpo.request(req);
                loop.exec();
            }
        }

        qDebug()<< "DISCONNET SIGNAL";
        disconnect(this, SIGNAL(destroyed()));
    };

    QFuture<void> t1 = QtConcurrent::run(func);
    watcher->setFuture(t1);
}

void AlbumsModel::updateArtwork(const int index, const QString &artwork)
{
    if(index >= this->list.size() || index < 0)
        return;

    this->list[index][FMH::MODEL_KEY::ARTWORK] = artwork;
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
