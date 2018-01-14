#include "babe.h"

#include <QPalette>
#include <QWidget>
#include <QColor>

#include "db/collectionDB.h"
#include "settings/settings.h"
#include "pulpo/pulpo.h"

using namespace BAE;

Babe::Babe(QObject *parent) : QObject(parent)
{    
    this->con = new CollectionDB(this);

    this->set = new settings(this);

    connect(set, &settings::refreshTables, [this](QVariantMap tables)
    {
        emit this->refreshTables(tables);
    });
}

QVariantList Babe::get(const QString &queryTxt)
{
    QVariantList res;
    for(auto data : this->con->getDBData(queryTxt))
    {
        QVariantMap map;
        for(auto key : data.keys())
            map[BAE::KEYMAP[key]] = data[key];

        res << map;
    }

    return res;
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

void Babe::scanDir(const QString &url)
{
    emit this->set->collectionPathChanged(url);
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
    return "#31363b";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Midlight).name();
#elif defined(Q_OS_WIN32)
    return "#31363b";
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

    if(!albumImg.isEmpty())
        return albumImg;
    else if (!artistImg.isEmpty())

        return artistImg;
    else
        return this->fetchCoverArt(track);
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

