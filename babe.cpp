#include "babe.h"

#include "db/collectionDB.h"
#include "db/conthread.h"
#include "settings/BabeSettings.h"
#include "pulpo/pulpo.h"

#include <QPalette>
#include <QColor>
#include <QIcon>
#include <QGuiApplication>
#include <QDirIterator>
#include <QtQml>
#include <QDesktopServices>
#include <QCursor>
#include "services/local/taginfo.h"
//#include "Python.h"

#ifdef STATIC_MAUIKIT
#include "fm.h"
#else
#include <MauiKit/fm.h>
#endif

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
#include <QWidget>
#include "kde/notify.h"
#endif

using namespace BAE;

Babe::Babe(QObject *parent) : QObject(parent)
{    
    this->settings = new BabeSettings(this);

    /*use another thread for the db to perfom heavy dutty actions*/
    this->thread = new ConThread;
    this->pulpo = new Pulpo(this);
    this->db = CollectionDB::getInstance();

    connect(pulpo, &Pulpo::infoReady, [&](const FMH::MODEL &track, const PULPO::RESPONSE  &res)
    {
        qDebug()<<"GOT THE LYRICS";

        if(!res[PULPO::ONTOLOGY::TRACK][PULPO::INFO::LYRICS].isEmpty())
        {
            auto lyrics = res[PULPO::ONTOLOGY::TRACK][PULPO::INFO::LYRICS][PULPO::CONTEXT::LYRIC].toString();

            this->db->lyricsTrack(track, lyrics);
            emit this->trackLyricsReady(lyrics, track[FMH::MODEL_KEY::URL]);
        }
    });


    connect(settings, &BabeSettings::refreshTables, [this](int size)
    {
        emit this->refreshTables(size);
    });

    connect(settings, &BabeSettings::refreshATable, [this](BAE::TABLE table)
    {
        switch(table)
        {
        case BAE::TABLE::TRACKS: emit this->refreshTracks(); break;
        case BAE::TABLE::ALBUMS: emit this->refreshAlbums(); break;
        case BAE::TABLE::ARTISTS: emit this->refreshArtists(); break;
        default: break;
        }

    });

    /*The local streaming connection still unfinished*/
    connect(&link, &Linking::parseAsk, this, &Babe::linkDecoder);
//    connect(&link, &Linking::bytesFrame, [this](QByteArray array)
//    {
//        this->player.appendBuffe(array);

//    });
//    connect(&link, &Linking::arrayReady, [this](QByteArray array)
//    {
//        qDebug()<<"trying to play the array";
//        Q_UNUSED(array);
//        this->player.playBuffer();
//    });

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    this->nof = new Notify(this);
    connect(this->nof,&Notify::babeSong,[this]()
    {
        emit this->babeIt();
    });

    connect(this->nof,&Notify::skipSong,[this]()
    {
        emit this->skipTrack();
    });
#elif defined (Q_OS_ANDROID)

#endif

}

Babe::~Babe()
{
    delete this->thread;
}


//void Babe::runPy()
//{

//    QFile cat (BAE::CollectionDBPath+"cat");
//    qDebug()<<cat.exists()<<cat.permissions();
//    if(!cat.setPermissions(QFile::ExeGroup | QFile::ExeOther | QFile::ExeOther | QFile::ExeUser))
//        qDebug()<<"Faile dot give cat permissionsa";
//    qDebug()<<cat.exists()<<cat.permissions();

//    QProcess process;
//    process.setWorkingDirectory(BAE::CollectionDBPath);
//    process.start("./cat", QStringList());

//    bool finished = process.waitForFinished(-1);
//    QString p_stdout = process.readAll();
//    qDebug()<<p_stdout<<finished<<process.workingDirectory()<<process.errorString();
//}

QVariantList Babe::get(const QString &queryTxt)
{
    return this->db->getDBDataQML(queryTxt);
}

QVariantList Babe::getList(const QStringList &urls)
{
    return Babe::transformData(this->db->getDBData(urls));
}

void Babe::set(const QString &table, const QVariantList &wheres)
{
    this->thread->start(table, wheres);
}

void Babe::trackPlaylist(const QStringList &urls, const QString &playlist)
{
    QVariantList data;
    for(auto url : urls)
    {
        QVariantMap map {{FMH::MODEL_NAME[FMH::MODEL_KEY::PLAYLIST],playlist},
                         {FMH::MODEL_NAME[FMH::MODEL_KEY::URL],url},
                         {FMH::MODEL_NAME[FMH::MODEL_KEY::ADDDATE],QDateTime::currentDateTime()}};

        data << map;
    }

    this->thread->start(BAE::TABLEMAP[TABLE::TRACKS_PLAYLISTS], data);
}

void Babe::trackLyrics(const QString &url)
{
    auto track = this->db->getDBData(QString("SELECT * FROM %1 WHERE %2 = \"%3\"").arg(TABLEMAP[TABLE::TRACKS],
                                     FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url));

    if(track.isEmpty()) return;

    qDebug()<< "Getting lyrics for track"<< track.first()[FMH::MODEL_KEY::TITLE];
    if(!track.first()[FMH::MODEL_KEY::LYRICS].isEmpty() && track.first()[FMH::MODEL_KEY::LYRICS] != SLANG[W::NONE])
        emit this->trackLyricsReady(track.first()[FMH::MODEL_KEY::LYRICS], url);
    else
        this->fetchTrackLyrics(track.first());
}

bool Babe::trackBabe(const QString &path)
{
    auto babe = this->db->getDBData(QString("SELECT %1 FROM %2 WHERE %3 = \"%4\"").arg(FMH::MODEL_NAME[FMH::MODEL_KEY::FAV],
                                    TABLEMAP[TABLE::TRACKS],
            FMH::MODEL_NAME[FMH::MODEL_KEY::URL],path));

    if(!babe.isEmpty())
        return babe.first()[FMH::MODEL_KEY::FAV].toInt();

    return false;
}

QString Babe::artistArt(const QString &artist)
{
    auto artwork = this->db->getDBData(QString("SELECT %1 FROM %2 WHERE %3 = \"%4\"").arg(FMH::MODEL_NAME[FMH::MODEL_KEY::ARTWORK],
                                       TABLEMAP[TABLE::ARTISTS],
            FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],artist));

    if(!artwork.isEmpty())
        if(!artwork.first()[FMH::MODEL_KEY::ARTWORK].isEmpty() && artwork.first()[FMH::MODEL_KEY::ARTWORK] != SLANG[W::NONE])
            return artwork.first()[FMH::MODEL_KEY::ARTWORK];

    return "";
}

QString Babe::artistWiki(const QString &artist)
{
    auto wiki = this->db->getDBData(QString("SELECT %1 FROM %2 WHERE %3 = \"%4\"").arg(FMH::MODEL_NAME[FMH::MODEL_KEY::WIKI],
                                    TABLEMAP[TABLE::ARTISTS],
            FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],artist));

    if(!wiki.isEmpty())
        return wiki.first()[FMH::MODEL_KEY::WIKI];

    return "";
}

QString Babe::albumArt(const QString &album, const QString &artist)
{
    auto queryStr = QString("SELECT %1 FROM %2 WHERE %3 = \"%4\" AND %5 = \"%6\"").arg(FMH::MODEL_NAME[FMH::MODEL_KEY::ARTWORK],
            TABLEMAP[TABLE::ALBUMS],
            FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM], album,
            FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST], artist);

    auto albumCover = this->db->getDBData(queryStr);

    if(!albumCover.isEmpty())
        if(!albumCover.first()[FMH::MODEL_KEY::ARTWORK].isEmpty() && albumCover.first()[FMH::MODEL_KEY::ARTWORK] != SLANG[W::NONE])
            return albumCover.first()[FMH::MODEL_KEY::ARTWORK];

    return "";
}

void Babe::fetchTrackLyrics(FMH::MODEL &song)
{
    pulpo->registerServices({SERVICES::LyricWikia, SERVICES::Genius});
    pulpo->setOntology(PULPO::ONTOLOGY::TRACK);
    pulpo->setInfo(PULPO::INFO::LYRICS);

    qDebug()<<"STARTED FETCHING LYRICS";
    pulpo->feed(song, PULPO::RECURSIVE::OFF);

    qDebug()<<"DONE FETCHING LYRICS";
}

void Babe::linkDecoder(QString json)
{

    qDebug()<<"DECODING LINKER MSG"<<json;
    auto ask = link.decode(json);

    auto code = ask[BAE::SLANG[BAE::W::CODE]].toInt();
    auto msg = ask[BAE::SLANG[BAE::W::MSG]].toString();

    switch(static_cast<LINK::CODE>(code))
    {
    case LINK::CODE::CONNECTED :
    {
        this->link.deviceName = msg;
        emit this->link.serverConReady(msg);
        break;
    }
    case LINK::CODE::QUERY :
    case LINK::CODE::FILTER :
    case LINK::CODE::PLAYLISTS :
    {
        auto res = this->db->getDBDataQML(msg);
        link.sendToClient(link.packResponse(static_cast<LINK::CODE>(code), res));
        break;
    }
    case LINK::CODE::SEARCHFOR :
    {
//        auto res = this->searchFor(msg.split(","));
//        link.sendToClient(link.packResponse(static_cast<LINK::CODE>(code), res));
        break;
    }
    case LINK::CODE::PLAY :
    {
        QFile file(msg);    // sound dir
        file.open(QIODevice::ReadOnly);
        QByteArray arr = file.readAll();
        qDebug()<<"Preparing track array"<<msg<<arr.size();
        link.sendArrayToClient(arr);
        break;
    }
    case LINK::CODE::COLLECT :
    {
        //            auto devices = getDevices();
        //            qDebug()<<"DEVICES:"<< devices;
        //            if(!devices.isEmpty())
        //                sendToDevice(devices.first().toMap().value("name").toString(),
        //                             devices.first().toMap().value("id").toString(), msg);
        break;

    }
    default: break;

    }
}

QString Babe::albumWiki(const QString &album, const QString &artist)
{
    auto queryStr = QString("SELECT %1 FROM %2 WHERE %3 = \"%4\" AND %5 = \"%6\"").arg(FMH::MODEL_NAME[FMH::MODEL_KEY::WIKI],
            TABLEMAP[TABLE::ALBUMS],
            FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM],album,
            FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],artist);
    auto wiki = this->db->getDBData(queryStr);

    if(!wiki.isEmpty())
        return wiki.first()[FMH::MODEL_KEY::WIKI];

    return "";
}

QVariantList Babe::getFolders()
{
    auto sources = this->db->getDBData("select * from sources");

    QVariantList res;

    for(auto item : sources)
        res << FMH::getDirInfo(item[FMH::MODEL_KEY::URL]);

    qDebug()<<"FOLDERS:"<< res;
    return res;
}

QStringList Babe::getSourceFolders()
{
    return this->db->getSourcesFolders();
}


void Babe::notify(const QString &title, const QString &body)
{
#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    this->nof->notify(title, body);
#elif defined (Q_OS_ANDROID)
    Q_UNUSED(title);
    Q_UNUSED(body);
#endif
}

void Babe::notifySong(const QString &url)
{
#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))    
    if(!this->db->check_existance(BAE::TABLEMAP[BAE::TABLE::TRACKS], FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url))
        return;

    auto query = QString("select t.*, al.artwork from tracks t inner join albums al on al.album = t.album and al.artist = t.artist where url = \"%1\"").arg(url);
    auto track = this->db->getDBData(query);
    this->nof->notifySong(track.first());

#else
    Q_UNUSED(url);
#endif
}

void Babe::scanDir(const QString &url)
{
    emit this->settings->collectionPathChanged({url});
}

void Babe::brainz(const bool &on)
{    
    qDebug()<< "Changed vvae brainz state"<< on;
    this->settings->startBrainz(on);
}

bool Babe::brainzState()
{
    return loadSetting("AUTO", "BRAINZ", false).toBool();
}

void Babe::refreshCollection()
{
    this->settings->refreshCollection();
}

void Babe::getYoutubeTrack(const QString &message)
{
    this->settings->fetchYoutubeTrack(message);
}

QVariant Babe::loadSetting(const QString &key, const QString &group, const QVariant &defaultValue)
{
    return BAE::loadSettings(key, group, defaultValue);
}

void Babe::saveSetting(const QString &key, const QVariant &value, const QString &group)
{
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

bool Babe::fileExists(const QString &url)
{
    return BAE::fileExists(url);
}

void Babe::showFolder(const QStringList &urls)
{
    for(auto url : urls)
        QDesktopServices::openUrl(QUrl::fromLocalFile(QFileInfo(url).dir().absolutePath()));
}

QString Babe::babeColor()
{
    return "#f84172";
}

void Babe::openUrls(const QStringList &urls)
{
    if(urls.isEmpty()) return;

    QVariantList data;
    TagInfo info;

    for(auto url : urls)
        if(this->db->check_existance(BAE::TABLEMAP[BAE::TABLE::TRACKS], FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url))
            data << this->getList({url}).first().toMap();
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

    qDebug()<< data;

    emit this->openFiles(data);
}

QString Babe::moodColor(const int &pos)
{
    if(pos < BAE::MoodColors.size())
        return BAE::MoodColors.at(pos);
    else return "";
}

QString Babe::homeDir()
{
    return BAE::HomePath;
}

QString Babe::musicDir()
{
    return BAE::MusicPath;
}

QStringList Babe::defaultSources()
{
    return BAE::defaultSources;
}

QString Babe::loadCover(const QString &url)
{
    auto map = this->db->getDBData(QStringList() << url);

    if(map.isEmpty()) return "";

    auto track = map.first();
    auto artist = track[FMH::MODEL_KEY::ARTIST];
    auto album = track[FMH::MODEL_KEY::ALBUM];
    auto title = track[FMH::MODEL_KEY::TITLE];

    auto artistImg = this->artistArt(artist);
    auto albumImg = this->albumArt(album, artist);

    if(!albumImg.isEmpty() && albumImg != BAE::SLANG[W::NONE])
        return albumImg;
    else if (!artistImg.isEmpty() && artistImg != BAE::SLANG[W::NONE])
        return artistImg;
    else
        return this->fetchCoverArt(track);
}


QString Babe::fetchCoverArt(FMH::MODEL &song)
{
    Pulpo pulpo;

    if(BAE::artworkCache(song, FMH::MODEL_KEY::ALBUM)) return song[FMH::MODEL_KEY::ARTWORK];
    if(BAE::artworkCache(song, FMH::MODEL_KEY::ARTIST)) return song[FMH::MODEL_KEY::ARTWORK];

    pulpo.registerServices({SERVICES::LastFm, SERVICES::Spotify});
    pulpo.setOntology(PULPO::ONTOLOGY::ALBUM);
    pulpo.setInfo(PULPO::INFO::ARTWORK);

    QEventLoop loop;

    QTimer timer;
    timer.setSingleShot(true);
    timer.setInterval(1000);

    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);

    connect(&pulpo, &Pulpo::infoReady, [&](const FMH::MODEL &track,const PULPO::RESPONSE  &res)
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

    return song[FMH::MODEL_KEY::ARTWORK];
}

QVariantList Babe::transformData(const FMH::MODEL_LIST &dbList)
{
    QVariantList res;

//    for(FMH::MODEL data : dbList)
//    {
//        FMH::MODEL copy = data;
//        res << FM::toMap(copy);
//    }

    return res;
}

