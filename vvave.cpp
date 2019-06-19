#include "vvave.h"

#include "db/collectionDB.h"
#include "settings/fileloader.h"
#include "utils/brain.h"

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
#include "kde/notify.h"
#endif

#include <QtConcurrent>
#include <QFuture>

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
    });


    auto func = [=]()
    {
        // the album artworks package
        BRAIN::PACKAGE albumPackage;
        albumPackage.ontology = PULPO::ONTOLOGY::ALBUM;
        albumPackage.info = PULPO::INFO::ARTWORK;
        albumPackage.callback = [=]()
        {
            emit this->refreshAlbums();
        };

        BRAIN::PACKAGE artistPackage;
        artistPackage.ontology = PULPO::ONTOLOGY::ARTIST;
        artistPackage.info = PULPO::INFO::ARTWORK;
        artistPackage.callback = [=]()
        {
            emit this->refreshArtists();
        };

        BRAIN::synapse(BRAIN::PACKAGES() << albumPackage << artistPackage);
    };

    QFuture<void> t1 = QtConcurrent::run(func);
    watcher->setFuture(t1);
}

void vvave::postActions()
{
    this->checkCollection(BAE::defaultSources, [this](uint size)
    {
        emit this->refreshTables(size);
        runBrain();
    });
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

    const auto func = [&paths]() -> uint
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

QVariantList vvave::sourceFolders() const
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

void vvave::scanDir(const QString &path)
{
    this->checkCollection(QStringList() << path);
}

QStringList vvave::getSourceFolders()
{
    return this->db->getSourcesFolders();
}



