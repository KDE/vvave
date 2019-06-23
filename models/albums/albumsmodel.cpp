#include "albumsmodel.h"
#include "db/collectionDB.h"
#include "utils/brain.h"
#include <QtConcurrent>

AlbumsModel::AlbumsModel(QObject *parent) : BaseList(parent)
{
    this->db = CollectionDB::getInstance();
    connect(this, &AlbumsModel::queryChanged, this, &AlbumsModel::setList);
}

AlbumsModel::~AlbumsModel()
{

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
    qDebug()<< "setting query"<< this->query;

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

    this->preListChanged();
    this->sortList();
    this->postListChanged();
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
    qSort(this->list.begin(), this->list.end(), [key](const FMH::MODEL &e1, const FMH::MODEL &e2) -> bool
    {
        auto role = key;

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
            auto currentTime = QDateTime::currentDateTime();

            auto date1 = QDateTime::fromString(e1[role], Qt::TextDate);
            auto date2 = QDateTime::fromString(e2[role], Qt::TextDate);

            if(date1.secsTo(currentTime) <  date2.secsTo(currentTime))
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

    this->list = this->db->getDBData(m_Query);


    qDebug()<< "my LIST" ;
    this->sortList();
    emit this->postListChanged();


}

void AlbumsModel::fetchInformation()
{
    qDebug() << "RNUNGING BRAIN EFFORRTS";
    QFutureWatcher<void> *watcher = new QFutureWatcher<void>;

    QObject::connect(watcher, &QFutureWatcher<void>::finished, [=]()
    {
        watcher->deleteLater();
    });

    auto func = [=]()
    {
        QList<PULPO::REQUEST> requests;
        int index = -1;
        for(auto &album : this->list)
        {
            index++;
            if(!album[FMH::MODEL_KEY::ARTWORK].isEmpty())
                continue;

            if(BAE::artworkCache(album, FMH::MODEL_KEY::ALBUM))
            {
                db->insertArtwork(album);
                this->updateArtwork(index, album[FMH::MODEL_KEY::ARTWORK]);
                continue;
            }

            PULPO::REQUEST request;
            request.track = album;
            request.ontology = this->query == AlbumsModel::QUERY::ALBUMS ? PULPO::ONTOLOGY::ALBUM : PULPO::ONTOLOGY::ARTIST;
            request.services = {PULPO::SERVICES::LastFm, PULPO::SERVICES::Spotify, PULPO::SERVICES::MusicBrainz};
            request.info = {PULPO::INFO::ARTWORK};
            request.callback = [=](PULPO::REQUEST request, PULPO::RESPONSES responses)
            {
                qDebug() << "DONE WITH " << request.track ;

                for(const auto &res : responses)
                {
                    if(res.context == PULPO::CONTEXT::IMAGE && !res.value.toString().isEmpty())
                    {
                        qDebug()<<"SAVING ARTWORK FOR: " << request.track[FMH::MODEL_KEY::ALBUM];
                        auto downloader = new FMH::Downloader;
                        QObject::connect(downloader, &FMH::Downloader::fileSaved, [=](QString path)
                        {
                            qDebug()<< "Saving artwork file to" << path;
                            FMH::MODEL newTrack = request.track;
                            newTrack[FMH::MODEL_KEY::ARTWORK] = path;
                            db->insertArtwork(newTrack);
                            this->updateArtwork(index, path);
                            downloader->deleteLater();
                        });

                        QStringList filePathList = res.value.toString().split('/');
                        const auto format = "." + filePathList.at(filePathList.count() - 1).split(".").last();
                        QString name = !request.track[FMH::MODEL_KEY::ALBUM].isEmpty() ? request.track[FMH::MODEL_KEY::ARTIST] + "_" + request.track[FMH::MODEL_KEY::ALBUM] : request.track[FMH::MODEL_KEY::ARTIST];
                        name.replace("/", "-");
                        name.replace("&", "-");
                        downloader->setFile(res.value.toString(),  BAE::CachePath + name + format);
                    }
                }
            };

            requests << request;
        }

        Pulpo pulpo;
        QEventLoop loop;
        QObject::connect(&pulpo, &Pulpo::finished, &loop, &QEventLoop::quit);
        bool stop = false;
//        QObject::connect(qApp, &QCoreApplication::aboutToQuit, [&]()
//        {
//            stop = true;
//            loop.quit();
//        });
        QObject::connect(this, &AlbumsModel::destroyed, [&]()
        {

            stop = true;
        });

        for(auto i = 0; i < requests.size(); i++)
        {
            pulpo.request(requests.at(i));
            loop.exec();
            if(stop)
            {
                loop.quit();
                return;
            }
        }
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

    QVariantMap res;
    const auto item = this->list.at(index);

    for(auto key : item.keys())
        res.insert(FMH::MODEL_NAME[key], item[key]);

    return res;
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


