#include "babe.h"

#include <QPalette>
#include <QWidget>
#include <QColor>
#include <QIcon>
#include "db/collectionDB.h"
#include "settings/settings.h"
#include "pulpo/pulpo.h"
#include <QApplication>
#include <QDesktopWidget>
#include <QDirIterator>
#include <QtQml>
#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
#include "kde/notify.h"
#endif

using namespace BAE;

Babe::Babe(QObject *parent) : QObject(parent)
{    
    qDebug()<<"CONSTRUCTING ABE INTERFACE";
    this->con = new CollectionDB(this);

    this->set = new settings(this);

    connect(set, &settings::refreshTables, [this](QVariantMap tables)
    {
        emit this->refreshTables(tables);
    });

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    this->nof = new Notify(this);
    connect(this->nof,&Notify::babeSong,[this](const BAE::DB &track)
    {
        qDebug()<<"BABETRACKKKK";
        Q_UNUSED(track);
        emit this->babeIt();
    });

    connect(this->nof,&Notify::skipSong,[this]()
    {
        emit this->skipTrack();
    });
#endif

}

Babe::~Babe()
{

}

QVariantList Babe::get(const QString &queryTxt)
{
    return this->con->getDBDataQML(queryTxt);
}

QVariantList Babe::getList(const QStringList &urls)
{
    return Babe::transformData(this->con->getDBData(urls));
}

void Babe::trackLyrics(const QString &url)
{
    auto track = this->con->getDBData(QString("SELECT * FROM %1 WHERE %2 = \"%3\"").arg(TABLEMAP[TABLE::TRACKS],
                                      KEYMAP[KEY::URL], url));

    if(track.isEmpty()) return;
    this->fetchTrackLyrics(track.first());
}

bool Babe::trackBabe(const QString &path)
{
    auto babe = this->con->getDBData(QString("SELECT %1 FROM %2 WHERE %3 = \"%4\"").arg(KEYMAP[KEY::BABE],
                                     TABLEMAP[TABLE::TRACKS],
            KEYMAP[KEY::URL],path));

    if(!babe.isEmpty())
        return babe.first()[KEY::BABE].toInt();

    return false;
}

QString Babe::artistArt(const QString &artist)
{
    auto artwork = this->con->getDBData(QString("SELECT %1 FROM %2 WHERE %3 = \"%4\"").arg(KEYMAP[KEY::ARTWORK],
                                        TABLEMAP[TABLE::ARTISTS],
            KEYMAP[KEY::ARTIST],artist));

    if(!artwork.isEmpty())
        if(!artwork.first()[KEY::ARTWORK].isEmpty() && artwork.first()[KEY::ARTWORK] != SLANG[W::NONE])
            return artwork.first()[KEY::ARTWORK];

    return "";
}

QString Babe::artistWiki(const QString &artist)
{
    auto wiki = this->con->getDBData(QString("SELECT %1 FROM %2 WHERE %3 = \"%4\"").arg(KEYMAP[KEY::WIKI],
                                     TABLEMAP[TABLE::ARTISTS],
            KEYMAP[KEY::ARTIST],artist));

    if(!wiki.isEmpty())
        return wiki.first()[KEY::WIKI];

    return "";
}

QString Babe::albumArt(const QString &album, const QString &artist)
{
    auto queryStr = QString("SELECT %1 FROM %2 WHERE %3 = \"%4\" AND %5 = \"%6\"").arg(KEYMAP[KEY::ARTWORK],
            TABLEMAP[TABLE::ALBUMS],
            KEYMAP[KEY::ALBUM],album,
            KEYMAP[KEY::ARTIST],artist);
    auto albumCover = this->con->getDBData(queryStr);

    if(!albumCover.isEmpty())
        if(!albumCover.first()[KEY::ARTWORK].isEmpty() && albumCover.first()[KEY::ARTWORK] != SLANG[W::NONE])
            return albumCover.first()[KEY::ARTWORK];

    return "";
}

void Babe::fetchTrackLyrics(DB &song)
{
    Pulpo pulpo;
    pulpo.registerServices({SERVICES::LyricWikia, SERVICES::Genius});
    pulpo.setOntology(PULPO::ONTOLOGY::TRACK);
    pulpo.setInfo(PULPO::INFO::LYRICS);

    connect(&pulpo, &Pulpo::infoReady, [&](const BAE::DB &track, const PULPO::RESPONSE  &res)
    {
        if(!res[PULPO::ONTOLOGY::TRACK][PULPO::INFO::LYRICS].isEmpty())
        {
            auto lyrics = res[PULPO::ONTOLOGY::TRACK][PULPO::INFO::LYRICS][PULPO::CONTEXT::LYRIC].toString();
            this->con->lyricsTrack(track, lyrics);
            song.insert(KEY::LYRICS, lyrics);
            emit this->trackLyricsReady(song[KEY::LYRICS], song[KEY::URL]);
        }
    });

    pulpo.feed(song, PULPO::RECURSIVE::OFF);


}

QString Babe::albumWiki(const QString &album, const QString &artist)
{
    auto queryStr = QString("SELECT %1 FROM %2 WHERE %3 = \"%4\" AND %5 = \"%6\"").arg(KEYMAP[KEY::WIKI],
            TABLEMAP[TABLE::ALBUMS],
            KEYMAP[KEY::ALBUM],album,
            KEYMAP[KEY::ARTIST],artist);
    auto wiki = this->con->getDBData(queryStr);

    if(!wiki.isEmpty())
        return wiki.first()[KEY::WIKI];

    return "";
}

bool Babe::babeTrack(const QString &path, const bool &value)
{
    if(this->con->update(TABLEMAP[TABLE::TRACKS],
                         KEYMAP[KEY::BABE],
                         value ? 1 : 0,
                         KEYMAP[KEY::URL],
                         path)) return true;

    return false;
}

bool Babe::rateTrack(const QString &path, const int &value)
{
    return this->con->rateTrack(path, value);
}

int Babe::trackRate(const QString &path)
{
    return this->con->getTrackStars(path);
}

bool Babe::moodTrack(const QString &path, const QString &color)
{
    qDebug()<<path<<color;
    return this->con->artTrack(path, color);
}

void Babe::notify(const QString &title, const QString &body)
{

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    Babe::nof->notify(title, body);
#else
    Q_UNUSED(title);
    Q_UNUSED(body);
#endif

}

void Babe::notifySong(const QString &url)
{
#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    auto query = QString("select t.*, al.artwork from tracks t inner join albums al on al.album = t.album and al.artist = t.artist where url = \"%1\"").arg(url);
    auto track = this->con->getDBData(query);
    Babe::nof->notifySong(track.first());
#else
    Q_UNUSED(url);
#endif
}

void Babe::scanDir(const QString &url)
{
    emit this->set->collectionPathChanged({url});
}

void Babe::brainz(const bool &on)
{
    this->set->checkCollectionBrainz(on);
}

QVariant Babe::loadSetting(const QString &key, const QString &group, const QVariant &defaultValue)
{
    auto res = BAE::loadSettings(key, group, defaultValue);
    qDebug()<<res<<"LOADSET RES";
    return res;
}

void Babe::saveSetting(const QString &key, const QVariant &value, const QString &group)
{
    qDebug()<<key<<value<<group;
    BAE::saveSettings(key, value, group);
}

void Babe::savePlaylist(const QStringList &list)
{
    BAE::saveSettings("PLAYLIST", list, "MAINWINDOW");
}

QStringList Babe::lastPlaylist()
{
    return BAE::loadSettings("PLAYLIST","MAINWINDOW",{}).toStringList();
}

void Babe::savePlaylistPos(const int &pos)
{
    BAE::saveSettings("PLAYLIST_POS", pos, "MAINWINDOW");
}

int Babe::lastPlaylistPos()
{
    return BAE::loadSettings("PLAYLIST_POS","MAINWINDOW",QVariant(0)).toInt();
}

QString Babe::baseColor()
{
#if defined(Q_OS_ANDROID)
    return "#24282c";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Base).name();
#elif defined(Q_OS_WIN32)
    return "#24282c";
#endif
}

QString Babe::darkColor()
{
#if defined(Q_OS_ANDROID)
    return "#24282c";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Dark).name();
#elif defined(Q_OS_WIN32)
    return "#24282c";
#endif
}

QString Babe::backgroundColor()
{
#if defined(Q_OS_ANDROID)
    return "#31363b";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Background).name();
#elif defined(Q_OS_WIN32)
    return "#31363b";
#endif
}

QString Babe::foregroundColor()
{
#if defined(Q_OS_ANDROID)
    return "#FFF";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Foreground).name();
#elif defined(Q_OS_WIN32)
    return "#FFF";
#endif
}

QString Babe::textColor()
{
#if defined(Q_OS_ANDROID)
    return "#FFF";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Text).name();
#elif defined(Q_OS_WIN32)
    return "#FFF";
#endif
}

QString Babe::hightlightColor()
{
#if defined(Q_OS_ANDROID)
    return "";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Highlight).name();
#elif defined(Q_OS_WIN32)
    return "";
#endif
}

QString Babe::midColor()
{
#if defined(Q_OS_ANDROID)
    return "#3e444b";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Mid).name();
#elif defined(Q_OS_WIN32)
    return "#3e444b";
#endif
}

QString Babe::midLightColor()
{
#if defined(Q_OS_ANDROID)
    return "#3e444b";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Midlight).name();
#elif defined(Q_OS_WIN32)
    return "#3e444b";
#endif
}

QString Babe::shadowColor()
{
#if defined(Q_OS_ANDROID)
    return "#3e444b";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Shadow).name();
#elif defined(Q_OS_WIN32)
    return "#3e444b";
#endif
}

QString Babe::altColor()
{
#if defined(Q_OS_ANDROID)
    return "#232629";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Base).name();
#elif defined(Q_OS_WIN32)
    return "#232629";
#endif
}

QString Babe::babeColor()
{
    return "#E91E63";
}

bool Babe::isMobile()
{
    return BAE::isMobile();
}

int Babe::screenGeometry(QString &side)
{
    side = side.toLower();
    auto geo = QApplication::desktop()->screenGeometry();

    if(side == "width")
        return geo.width();
    else if(side == "height")
        return geo.height();
    else return 0;
}

int Babe::cursorPos(QString &axis)
{
    axis = axis.toLower();
    auto pos = QCursor::pos();
    if(axis == "x")
        return pos.x();
    else if(axis == "y")
        return pos.y();
    else return 0;
}

QString Babe::moodColor(const int &pos)
{
    if(pos < BAE::MoodColors.size())
        return BAE::MoodColors.at(pos);
    else return "";
}

QString Babe::homeDir()
{
    return BAE::MusicPath;
}

QVariantList Babe::getDirs(const QString &pathUrl)
{
    auto path = pathUrl;
    if(path.startsWith("file://"))
        path.replace("file://", "");
    qDebug()<<"DIRECTRORY"<<path;
    QVariantList paths;

    if (QFileInfo(path).isDir())
    {
        QDirIterator it(path, QDir::Dirs, QDirIterator::NoIteratorFlags);
        while (it.hasNext())
        {
            auto url = it.next();
            auto name = QDir(url).dirName();
            qDebug()<<name<<url;
            QVariantMap map = { {"url", url }, {"name", name} };
            paths << map;
        }
    }

    return paths;
}

QVariantMap Babe::getParentDir(const QString &path)
{
    auto dir = QDir(path);
    dir.cdUp();
    auto dirPath = dir.absolutePath();

    if(dir.isReadable() && !dir.isRoot() && dir.exists())
        return {{"url", dirPath}, {"name", dir.dirName()}};
    else
        return {{"url", path}, {"name", QFileInfo(path).dir().dirName()}};
}

void Babe::registerTypes()
{
    qmlRegisterUncreatableType<Babe>("Babe", 1, 0, "Babe", "ERROR ABE");
}


uint Babe::sizeHint(const uint &hint)
{
    if(hint>=BAE::BIG_ALBUM_FACTOR)
        return BAE::getWidgetSizeHint(BAE::AlbumSizeHint::BIG_ALBUM);
    else if(hint>=BAE::MEDIUM_ALBUM_FACTOR)
        return BAE::getWidgetSizeHint(BAE::AlbumSizeHint::MEDIUM_ALBUM);
    else if(hint>=BAE::SMALL_ALBUM_FACTOR)
        return BAE::getWidgetSizeHint(BAE::AlbumSizeHint::SMALL_ALBUM);
    else return hint;
}

QString Babe::icon(const QString &icon, const int &size)
{
   auto pix = QIcon::fromTheme(icon).pixmap(QSize(size, size), QIcon::Mode::Normal, QIcon::State::On);

   return "";
}

QString Babe::loadCover(const QString &url)
{
    auto map = this->con->getDBData(QStringList() << url);

    if(map.isEmpty()) return "";

    auto track = map.first();
    auto artist = track[KEY::ARTIST];
    auto album = track[KEY::ALBUM];
    auto title = track[KEY::TITLE];

    auto artistImg = this->artistArt(artist);
    auto albumImg = this->albumArt(album, artist);

    if(!albumImg.isEmpty() && albumImg != BAE::SLANG[W::NONE])
        return albumImg;
    else if (!artistImg.isEmpty() && artistImg != BAE::SLANG[W::NONE])
        return artistImg;
    else
        return this->fetchCoverArt(track);
}

QVariantList Babe::searchFor(const QStringList &queries)
{
    QVariantList mapList;
    bool hasKey = false;

    for(auto searchQuery : queries)
    {
        if(searchQuery.contains(BAE::SearchTMap[BAE::SearchT::LIKE]+":") || searchQuery.startsWith("#"))
        {
            if(searchQuery.startsWith("#"))
                searchQuery=searchQuery.replace("#","").trimmed();
            else
                searchQuery=searchQuery.replace(BAE::SearchTMap[BAE::SearchT::LIKE]+":","").trimmed();


            searchQuery = searchQuery.trimmed();
            if(!searchQuery.isEmpty())
            {
                mapList += this->con->getSearchedTracks(BAE::KEY::WIKI, searchQuery);
                mapList += this->con->getSearchedTracks(BAE::KEY::TAG, searchQuery);
                mapList += this->con->getSearchedTracks(BAE::KEY::LYRICS, searchQuery);
            }

        }else if(searchQuery.contains((BAE::SearchTMap[BAE::SearchT::SIMILAR]+":")))
        {
            searchQuery=searchQuery.replace(BAE::SearchTMap[BAE::SearchT::SIMILAR]+":","").trimmed();
            searchQuery=searchQuery.trimmed();
            if(!searchQuery.isEmpty())
                mapList += this->con->getSearchedTracks(BAE::KEY::TAG, searchQuery);

        }else
        {
            BAE::KEY key;

            QMapIterator<BAE::KEY, QString> k(BAE::KEYMAP);
            while (k.hasNext())
            {
                k.next();
                if(searchQuery.contains(QString(k.value()+":")))
                {
                    hasKey=true;
                    key=k.key();
                    searchQuery = searchQuery.replace(k.value()+":","").trimmed();
                }
            }

            searchQuery = searchQuery.trimmed();
            qDebug()<<"Searching for: "<<searchQuery;

            if(!searchQuery.isEmpty())
            {
                if(hasKey)
                    mapList += this->con->getSearchedTracks(key, searchQuery);
                else
                {
                    auto queryTxt = QString("SELECT * FROM tracks WHERE title LIKE \"%"+searchQuery+"%\" OR artist LIKE \"%"+searchQuery+"%\" OR album LIKE \"%"+searchQuery+"%\"OR genre LIKE \"%"+searchQuery+"%\"OR url LIKE \"%"+searchQuery+"%\" LIMIT 1000");
                    mapList += this->con->getDBDataQML(queryTxt);
                }
            }
        }
    }

    return  mapList;
}

QString Babe::fetchCoverArt(DB &song)
{
    if(BAE::artworkCache(song, KEY::ALBUM)) return song[KEY::ARTWORK];
    if(BAE::artworkCache(song, KEY::ARTIST)) return song[KEY::ARTWORK];

    Pulpo pulpo;
    pulpo.registerServices({SERVICES::LastFm, SERVICES::Spotify});
    pulpo.setOntology(PULPO::ONTOLOGY::ALBUM);
    pulpo.setInfo(PULPO::INFO::ARTWORK);

    QEventLoop loop;

    QTimer timer;
    timer.setSingleShot(true);
    timer.setInterval(1000);

    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);

    connect(&pulpo, &Pulpo::infoReady, [&](const BAE::DB &track,const PULPO::RESPONSE  &res)
    {
        Q_UNUSED(track);
        if(!res[PULPO::ONTOLOGY::ALBUM][PULPO::INFO::ARTWORK].isEmpty())
        {
            auto artwork = res[PULPO::ONTOLOGY::ALBUM][PULPO::INFO::ARTWORK][PULPO::CONTEXT::IMAGE].toByteArray();
            BAE::saveArt(song, artwork, BAE::CachePath);
        }
        loop.quit();
    });

    pulpo.feed(song, PULPO::RECURSIVE::OFF);

    timer.start();
    loop.exec();
    timer.stop();

    return  song[KEY::ARTWORK];
}

QVariantList Babe::transformData(const DB_LIST &dbList)
{
    QVariantList res;

    for(auto data : dbList)
    {
        QVariantMap map;
        for(auto key : data.keys())
            map[BAE::KEYMAP[key]] = data[key];

        res << map;
    }

    return res;
}

