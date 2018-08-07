#include "fileloader.h"
#include "../services/local/taginfo.h"

FileLoader::FileLoader() : CollectionDB(nullptr)
{
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
            this->addFolder(path);
            QDirIterator it(path, BAE::formats, QDir::Files, QDirIterator::Subdirectories);

            while (it.hasNext())
                urls << it.next();

        }else if (QFileInfo(path).isFile())
            urls << path;
    }

    int newTracks = 0;

    if(urls.isEmpty()) return;

    //    this->execQuery("PRAGMA synchronous=OFF");
    TagInfo info;

    for(auto url : urls)
    {
        if(!go)
            break;

        if(check_existance(BAE::TABLEMAP[BAE::TABLE::TRACKS],BAE::KEYMAP[BAE::KEY::URL], url))
            continue;

        if(!info.feed(url))
            continue;

        auto track= info.getTrack();
        auto genre = info.getGenre();
        auto album = BAE::fixString(info.getAlbum());
        auto title = BAE::fixString(info.getTitle()); /* to fix*/
        auto artist = BAE::fixString(info.getArtist());
        auto sourceUrl = QFileInfo(url).dir().path();
        auto duration = info.getDuration();
        auto year = info.getYear();

        BAE::DB trackMap =
        {
            {BAE::KEY::URL, url},
            {BAE::KEY::TRACK, QString::number(track)},
            {BAE::KEY::TITLE, title},
            {BAE::KEY::ARTIST, artist},
            {BAE::KEY::ALBUM, album},
            {BAE::KEY::DURATION,QString::number(duration)},
            {BAE::KEY::GENRE, genre},
            {BAE::KEY::SOURCES_URL, sourceUrl},
            {BAE::KEY::BABE, url.startsWith(BAE::YoutubeCachePath) ? "1": "0"},
            {BAE::KEY::RELEASE_DATE, QString::number(year)}
        };

        qDebug() << url;
        BAE::artworkCache(trackMap, BAE::KEY::ALBUM);

        if(this->addTrack(trackMap))
            newTracks++;
    }

//    this->t.msleep(100);
    emit this->finished(newTracks);
    this->go = false;
}
