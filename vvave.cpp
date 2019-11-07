#include "vvave.h"

#include "db/collectionDB.h"
#include "services/local/fileloader.h"
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


vvave::vvave(QObject *parent) : QObject(parent),
    db(CollectionDB::getInstance())
{
    for(const auto &path : {BAE::CachePath, BAE::YoutubeCachePath})
    {
        QDir dirPath(path);
        if (!dirPath.exists())
            dirPath.mkpath(".");
    }

//#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
//    if(!FMH::fileExists(BAE::NotifyDir+"/vvave.notifyrc"))
//        QFile::copy(":/assets/vvave.notifyrc", BAE::NotifyDir+"/vvave.notifyrc");

//#endif
}

vvave::~vvave() {}

void vvave::checkCollection(const QStringList &paths, std::function<void(uint)> cb)
{
    QFutureWatcher<uint> *watcher = new QFutureWatcher<uint>;
    connect(watcher, &QFutureWatcher<uint>::finished, [cb, watcher]()
    {
        const uint newTracks = watcher->future().result();
        qDebug()<< "FINISHED SCANING CXOLLECTION";
        if(cb)
            cb(newTracks);
    });

    const auto func = [=]() -> uint
    {
        return FLoader::getTracks(QUrl::fromStringList(paths));
    };

    QFuture<uint> t1 = QtConcurrent::run(func);
    watcher->setFuture(t1);
}

void vvave::emitSignal()
{
    emit this->refreshTables(10);
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

bool vvave::removeSource(const QString &source)
{
    if(!this->getSourceFolders().contains(source))
        return false;

    return this->db->removeSource(source);
}

QString vvave::moodColor(const int &index)
{
    if(index < BAE::MoodColors.size() && index > -1)
        return BAE::MoodColors.at(index);
    else return "";
}

QStringList vvave::moodColors()
{
    return BAE::MoodColors;
}

void vvave::scanDir(const QStringList &paths)
{
    this->checkCollection(paths, [=](uint size) {emit this->refreshTables(size);});
}

QStringList vvave::getSourceFolders()
{
    return this->db->getSourcesFolders();
}

void vvave::openUrls(const QStringList &urls)
{
    if(urls.isEmpty()) return;

    QVariantList data;

    for(const auto &url : urls)
      {
        auto _url = QUrl::fromUserInput(url);
        if(db->check_existance(BAE::TABLEMAP[BAE::TABLE::TRACKS], FMH::MODEL_NAME[FMH::MODEL_KEY::URL], _url.toString()))
        {
            data << FMH::toMap(this->db->getDBData(QStringList() << _url.toString()).first());
        }else
        {
            TagInfo info;
            if(info.feed(_url.toLocalFile()))
            {
                const auto album = BAE::fixString(info.getAlbum());
                const auto track= info.getTrack();
                const auto title = BAE::fixString(info.getTitle()); /* to fix*/
                const auto artist = BAE::fixString(info.getArtist());
                const auto genre = info.getGenre();
                const auto sourceUrl = QFileInfo(_url.toLocalFile()).dir().path();
                const auto duration = info.getDuration();
                const auto year = info.getYear();

                data << QVariantMap({
                                        {FMH::MODEL_NAME[FMH::MODEL_KEY::URL], _url.toString()},
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
      }

    emit this->openFiles(data);
}



