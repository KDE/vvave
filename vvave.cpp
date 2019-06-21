#include "vvave.h"

#include "db/collectionDB.h"
#include "settings/fileloader.h"
#include "utils/brain.h"

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
#include "kde/notify.h"
#endif

#include <QtConcurrent>
#include <QFuture>

#ifdef STATIC_MAUIKIT
#include "fm.h"
#else
#include <MauiKit/fm.h>
#endif

/*
 * Sets upthe app default config paths
 * BrainDeamon to get collection information
 * YoutubeFetcher ?
 *
 * */


vvave::vvave(QObject *parent) : QObject(parent)
{
    this->db = CollectionDB::getInstance();
    for(const auto &path : {BAE::CachePath, BAE::YoutubeCachePath})
    {
        QDir dirPath(path);

        if (!dirPath.exists())
            dirPath.mkpath(".");
    }

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    if(!FMH::fileExists(BAE::NotifyDir+"/vvave.notifyrc"))
        QFile::copy(":/assets/vvave.notifyrc", BAE::NotifyDir+"/vvave.notifyrc");

    this->notify = new Notify(this);
    connect(this->notify, &Notify::babeSong, [this]()
    {
        //        emit this->babeIt();
    });

    connect(this->notify, &Notify::skipSong, [this]()
    {
        //        emit this->skipTrack();
    });

#endif
}

vvave::~vvave() {}


void vvave::runBrain()
{
    QFutureWatcher<void> *watcher = new QFutureWatcher<void>;

    QObject::connect(watcher, &QFutureWatcher<void>::finished, [=]()
    {
        watcher->deleteLater();
        emit this->refreshAlbums();
    });

    //    QObject::connect(qApp, &QCoreApplication::aboutToQuit, [=]()
    //    {
    //        if(watcher != nullptr)
    //            watcher->future().waitForFinished();
    //    });

//    auto func = [=]()
//    {
        // the album artworks package
//        BRAIN::PACKAGE albumPackage;
//        albumPackage.ontology = PULPO::ONTOLOGY::ALBUM;
//        albumPackage.info = PULPO::INFO::ARTWORK;
//        albumPackage.callback = [=]()
//        {
//            emit this->refreshAlbums();
//        };

//        BRAIN::PACKAGE artistPackage;
//        artistPackage.ontology = PULPO::ONTOLOGY::ARTIST;
//        artistPackage.info = PULPO::INFO::ARTWORK;
//        artistPackage.callback = [=]()
//        {
//            emit this->refreshArtists();
//        };

//        BRAIN::synapse(BRAIN::PACKAGES() << albumPackage /*<< artistPackage*/);
//    };

//    QFuture<void> t1 = QtConcurrent::run(func);
//    watcher->setFuture(t1);
}


void vvave::checkCollection(const QStringList &paths, std::function<void(uint)> cb)
{
    QFutureWatcher<uint> *watcher = new QFutureWatcher<uint>;
    connect(watcher, &QFutureWatcher<uint>::finished, [=]()
    {
        const uint newTracks = watcher->future().result();
        if(cb)
            cb(newTracks);
        watcher->deleteLater();
    });
    const auto func = [=]() -> uint
    {
        auto newPaths = paths;

        for(auto path : newPaths)
            if(path.startsWith("file://"))
                path.replace("file://", "");

        return FLoader::getTracks(newPaths);
    };

    QFuture<uint> t1 = QtConcurrent::run(func);
    watcher->setFuture(t1);
}


//// PUBLIC SLOTS

QVariantList vvave::sourceFolders()
{
    const auto sources = this->db->getDBData("select * from sources");

    QVariantList res;
    for(const auto &item : sources)
        res << FMH::getDirInfo(item[FMH::MODEL_KEY::URL]);
    return res;
}

QString vvave::moodColor(const int &index)
{
    if(index < BAE::MoodColors.size() && index > -1)
        return BAE::MoodColors.at(index);
    else return "";
}

void vvave::scanDir(const QStringList &paths)
{
    this->checkCollection(paths, [=](uint size)
    {
        emit this->refreshTables(size);
//        this->runBrain();
    });
}

QStringList vvave::getSourceFolders()
{
    return this->db->getSourcesFolders();
}

void vvave::openUrls(const QStringList &urls)
{
    if(urls.isEmpty()) return;

    QVariantList data;
    TagInfo info;

    for(QString url : urls)
        if(db->check_existance(BAE::TABLEMAP[BAE::TABLE::TRACKS], FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url))
        {
            const auto value = this->db->getDBData(QStringList() << url).first();
            data << FM::toMap(value);
        }
        else
        {
            if(info.feed(url))
            {
                auto album = BAE::fixString(info.getAlbum());
                auto track= info.getTrack();
                auto title = BAE::fixString(info.getTitle()); /* to fix*/
                auto artist = BAE::fixString(info.getArtist());
                auto genre = info.getGenre();
                auto sourceUrl = QFileInfo(url).dir().path();
                auto duration = info.getDuration();
                auto year = info.getYear();

                data << QVariantMap({
                                        {FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url},
                                        {FMH::MODEL_NAME[FMH::MODEL_KEY::TRACK], QString::number(track)},
                                        {FMH::MODEL_NAME[FMH::MODEL_KEY::TITLE], title},
                                        {FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST], artist},
                                        {FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM], album},
                                        {FMH::MODEL_NAME[FMH::MODEL_KEY::DURATION],QString::number(duration)},
                                        {FMH::MODEL_NAME[FMH::MODEL_KEY::GENRE], genre},
                                        {FMH::MODEL_NAME[FMH::MODEL_KEY::SOURCE], sourceUrl},
                                        {FMH::MODEL_NAME[FMH::MODEL_KEY::FAV],"0"},
                                        {FMH::MODEL_NAME[FMH::MODEL_KEY::RELEASEDATE], QString::number(year)}
                                    });
            }
        }

    qDebug()<<"opening urls " << urls << data;

    emit this->openFiles(data);
}



