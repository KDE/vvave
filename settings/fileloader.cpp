#include "fileloader.h"
#include "../services/local/taginfo.h"
#include "../db/collectionDB.h"

FileLoader::FileLoader() : QObject(nullptr)
{
    this->db = CollectionDB::getInstance();
    qRegisterMetaType<BAE::DB>("BAE::DB");
    qRegisterMetaType<BAE::TABLE>("BAE::TABLE");
    qRegisterMetaType<QMap<BAE::TABLE, bool>>("QMap<BAE::TABLE,bool>");
    this->moveToThread(&t);
    t.start();
}

FileLoader::~FileLoader()
{
    this->go = false;
    this->t.quit();
    this->t.wait();
}


void FileLoader::requestPaths(const QStringList& paths)
{
    this->go = true;
    QMetaObject::invokeMethod(this, "getTracks", Q_ARG(QStringList, paths));
}

void FileLoader::nextTrack()
{
    this->wait = !this->wait;
}

void FileLoader::getTracks(const QStringList& paths)
{
    QStringList urls;

    for(auto path : paths)
    {
        if (QFileInfo(path).isDir())
        {
            this->db->addFolder(path);
            QDirIterator it(path, FMH::FILTER_LIST[FMH::FILTER_TYPE::AUDIO], QDir::Files, QDirIterator::Subdirectories);

            while (it.hasNext())
                urls << it.next();

        }else if (QFileInfo(path).isFile())
            urls << path;
    }

    int newTracks = 0;

    if(urls.isEmpty()) return;

    TagInfo info;
    for(auto url : urls)
    {
        if(!this->go)
            break;

        if(this->db->check_existance(BAE::TABLEMAP[BAE::TABLE::TRACKS], FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url))
            continue;

        if(!info.feed(url))
            continue;

        auto track = info.getTrack();
        auto genre = info.getGenre();
        auto album = BAE::fixString(info.getAlbum());
        auto title = BAE::fixString(info.getTitle()); /* to fix*/
        auto artist = BAE::fixString(info.getArtist());
        auto sourceUrl = QFileInfo(url).dir().path();
        auto duration = info.getDuration();
        auto year = info.getYear();

        FMH::MODEL trackMap =
        {
            {FMH::MODEL_KEY::URL, url},
            {FMH::MODEL_KEY::TRACK, QString::number(track)},
            {FMH::MODEL_KEY::TITLE, title},
            {FMH::MODEL_KEY::ARTIST, artist},
            {FMH::MODEL_KEY::ALBUM, album},
            {FMH::MODEL_KEY::DURATION,QString::number(duration)},
            {FMH::MODEL_KEY::GENRE, genre},
            {FMH::MODEL_KEY::SOURCE, sourceUrl},
            {FMH::MODEL_KEY::FAV, url.startsWith(BAE::YoutubeCachePath) ? "1": "0"},
            {FMH::MODEL_KEY::RELEASEDATE, QString::number(year)}
        };

        qDebug() << url;
        BAE::artworkCache(trackMap, FMH::MODEL_KEY::ALBUM);

        if(this->db->addTrack(trackMap))
            newTracks++;
    }

//    this->t.msleep(100);
    emit this->finished(newTracks);
    this->go = false;
}
