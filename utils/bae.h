#ifndef BAE_H
#define BAE_H

#include "string"
#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QFileInfo>
#include <QImage>
#include <QTime>
#include <QSettings>
#include <QDirIterator>
#include <QScreen>
#include <QtNetwork>
#include <QEventLoop>
#include "../mauikit/src/fm/fmh.h"

#include <cmath>


#define BABE_MAJOR_VERSION 0
#define BABE_MINOR_VERSION 1
#define BABE_PATCH_VERSION 0

#define BABE_VERSION_STR "0.1.0"

#define BABE_VERSION KDE_MAKE_VERSION(0,1,0)

using namespace std;

namespace BAE
{
Q_NAMESPACE

inline bool isMobile()
{
#if defined(Q_OS_ANDROID)
    return true;
#elif defined(Q_OS_LINUX)
    return false;
#elif defined(Q_OS_WIN32)
    return false;
#elif defined(Q_OS_WIN64)
    return false;
#elif defined(Q_OS_MACOS)
    return false;
#elif defined(Q_OS_IOS)
    return true;
#elif defined(Q_OS_HAIKU)
    return false;
#endif
}

inline bool isAndroid()
{
#if defined(Q_OS_ANDROID)
    return true;
#elif defined(Q_OS_LINUX)
    return false;
#elif defined(Q_OS_WIN32)
    return false;
#elif defined(Q_OS_WIN64)
    return false;
#elif defined(Q_OS_MACOS)
    return false;
#elif defined(Q_OS_IOS)
    return false;
#elif defined(Q_OS_HAIKU)
    return false;
#endif
}


enum SEG
{
    HALF = 500,
    ONE = 1000,
    ONEHALF = 1500,
    TWO = 2000,
    THREE = 3000
};

enum SearchT
{
    LIKE,
    SIMILAR
};

typedef QMap<BAE::SearchT,QString> SEARCH;

static const SEARCH SearchTMap
{
    { BAE::SearchT::LIKE, "like" },
    { BAE::SearchT::SIMILAR, "similar" }
};

enum class W : uint_fast8_t
{
    ALL,
    NONE,
    LIKE,
    TAG,
    SIMILAR,
    UNKNOWN,
    DONE,
    DESC,
    ASC,
    CODE,
    MSG
};

static const QMap<W,QString> SLANG =
{
    {W::ALL, "ALL"},
    {W::NONE, "NONE"},
    {W::LIKE, "LIKE"},
    {W::SIMILAR, "SIMILAR"},
    {W::UNKNOWN, "UNKNOWN"},
    {W::DONE, "DONE"},
    {W::DESC, "DESC"},
    {W::ASC, "ASC"},
    {W::TAG, "TAG"},
    {W::MSG, "MSG"},
    {W::CODE, "CODE"}
};

enum class TABLE : uint8_t
{
    ALBUMS,
    ARTISTS,
    MOODS,
    PLAYLISTS,
    SOURCES,
    SOURCES_TYPES,
    TRACKS,
    TRACKS_MOODS,
    TRACKS_PLAYLISTS,
    TAGS,
    ALBUMS_TAGS,
    ARTISTS_TAGS,
    TRACKS_TAGS,
    LOGS,
    FOLDERS,
    ALL,
    NONE
};

static const QMap<TABLE,QString> TABLEMAP =
{
    {TABLE::ALBUMS,"albums"},
    {TABLE::ARTISTS,"artists"},
    {TABLE::MOODS,"moods"},
    {TABLE::PLAYLISTS,"playlists"},
    {TABLE::SOURCES,"sources"},
    {TABLE::SOURCES_TYPES,"sources_types"},
    {TABLE::TRACKS,"tracks"},
    {TABLE::TRACKS_MOODS,"tracks_moods"},
    {TABLE::TRACKS_PLAYLISTS,"tracks_playlists"},
    {TABLE::TAGS,"tags"},
    {TABLE::ALBUMS_TAGS,"albums_tags"},
    {TABLE::ARTISTS_TAGS,"artists_tags"},
    {TABLE::TRACKS_TAGS,"tracks_tags"},
    {TABLE::LOGS,"logs"},
    {TABLE::FOLDERS,"folders"}

};

enum class KEY :uint8_t
{
    URL = 0,
    SOURCES_URL = 1,
    TRACK = 2,
    TITLE = 3,
    ARTIST = 4,
    ALBUM = 5,
    DURATION = 6,
    PLAYED = 7,
    BABE = 8,
    STARS = 9,
    RELEASE_DATE = 10,
    ADD_DATE = 11,
    LYRICS = 12,
    GENRE = 13,
    ART = 14,
    TAG = 15,
    MOOD = 16,
    PLAYLIST = 17,
    ARTWORK = 18,
    WIKI = 19,
    SOURCE_TYPE = 20,
    CONTEXT = 21,
    RETRIEVAL_DATE = 22,
    COMMENT = 23,
    ID = 24,
    SQL = 25,
    NONE = 26
};

typedef QMap<BAE::KEY, QString> DB;
typedef QList<DB> DB_LIST;

static const DB KEYMAP =
{
    {KEY::URL, "url"},
    {KEY::SOURCES_URL, "sources_url"},
    {KEY::TRACK, "track"},
    {KEY::TITLE, "title"},
    {KEY::ARTIST, "artist"},
    {KEY::ALBUM, "album"},
    {KEY::DURATION, "duration"},
    {KEY::PLAYED, "played"},
    {KEY::BABE, "babe"},
    {KEY::STARS, "stars"},
    {KEY::RELEASE_DATE, "releaseDate"},
    {KEY::ADD_DATE, "addDate"},
    {KEY::LYRICS, "lyrics"},
    {KEY::GENRE, "genre"},
    {KEY::ART, "art"},
    {KEY::TAG, "tag"},
    {KEY::MOOD, "mood"},
    {KEY::PLAYLIST, "playlist"},
    {KEY::ARTWORK, "artwork"},
    {KEY::WIKI, "wiki"},
    {KEY::SOURCE_TYPE, "source_types_id"},
    {KEY::CONTEXT, "context"},
    {KEY::RETRIEVAL_DATE, "retrieval_date"},
    {KEY::ID, "id"},
    {KEY::COMMENT, "comment"},
    {KEY::SQL, "sql"}
};

static const DB TracksColsMap =
{
    {KEY::URL, KEYMAP[KEY::URL]},
    {KEY::SOURCES_URL, KEYMAP[KEY::SOURCES_URL]},
    {KEY::TRACK, KEYMAP[KEY::TRACK]},
    {KEY::TITLE, KEYMAP[KEY::TITLE]},
    {KEY::ARTIST, KEYMAP[KEY::ARTIST]},
    {KEY::ALBUM, KEYMAP[KEY::ALBUM]},
    {KEY::DURATION, KEYMAP[KEY::DURATION]},
    {KEY::PLAYED, KEYMAP[KEY::PLAYED]},
    {KEY::BABE, KEYMAP[KEY::BABE]},
    {KEY::STARS, KEYMAP[KEY::STARS]},
    {KEY::RELEASE_DATE, KEYMAP[KEY::RELEASE_DATE]},
    {KEY::ADD_DATE, KEYMAP[KEY::ADD_DATE]},
    {KEY::LYRICS, KEYMAP[KEY::LYRICS]},
    {KEY::GENRE, KEYMAP[KEY::GENRE]},
    {KEY::ART, KEYMAP[KEY::ART]}
};

inline QString transformTime(const qint64 &value)
{
    QString tStr;
    if (value)
    {
        QTime time((value/3600)%60, (value/60)%60, value%60, (value*1000)%1000);
        QString format = "mm:ss";
        if (value > 3600)
            format = "hh:mm:ss";
        tStr = time.toString(format);
    }

    return tStr.isEmpty() ? "00:00" : tStr;
}

inline QString getNameFromLocation(const QString &str)
{
    QString ret;
    int index = 0;

    for(int i = str.size() - 1; i >= 0; i--)
        if(str[i] == '/')
        {
            index = i + 1;
            i = -1;
        }

    for(; index < str.size(); index++)
        ret.push_back(str[index]);

    return ret;
}

const QString SettingPath = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)+"/vvave/";
const QString ArtworkPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/vvave/artwork/";
const QString CollectionDBPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/vvave/";
const QString CachePath = BAE::isMobile() ? BAE::ArtworkPath : QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation)+"/vvave/";
const QString YoutubeCachePath = QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation)+"/vvave/youtube/";
const QString NotifyDir = QStandardPaths::writableLocation(QStandardPaths::ConfigLocation);

const QStringList MusicPaths = QStandardPaths::standardLocations(QStandardPaths::MusicLocation);
const QStringList DownloadsPaths = QStandardPaths::standardLocations(QStandardPaths::DownloadLocation);

const QString MusicPath = FMH::MusicPath;
const QString HomePath = FMH::HomePath;
const QString DownloadsPath = FMH::DownloadsPath;

const QString BabePort = "8483";
const QString LinkPort = "3333";

const QString App = "vvave";
const QString Description = "vvave music player";
const QString Version = BABE_VERSION_STR;
const QString DBName = "collection.db";

const QStringList MoodColors = {"#F0FF01","#01FF5B","#3DAEFD","#B401FF","#E91E63"};
const QStringList formats {"*.mp4","*.mp3","*.wav","*.flac","*.ogg","*.m4a"};
const QStringList defaultSources = QStringList() << BAE::MusicPath
                                                 << BAE::DownloadsPath
                                                 << BAE::MusicPaths
                                                 << BAE::DownloadsPaths
                                                 << BAE::YoutubeCachePath;

inline QString fixTitle(const QString &title,const QString &s,const QString &e)
{
    QString newTitle;
    for(int i=0; i<title.size();i++)
        if(title.at(i)==s)
        {
            while(title.at(i)!=e)
                if(i==title.size()-1) break;
                else i++;

        }else newTitle+=title.at(i);

    return newTitle.simplified();
}

inline QString removeSubstring(const QString &newTitle, const QString &subString)
{
    const int indexFt = newTitle.indexOf(subString, 0, Qt::CaseInsensitive);

    if (indexFt != -1)
        return newTitle.left(indexFt).simplified();
    else
        return newTitle;
}

inline QString ucfirst(const QString &str)/*uppercase first letter*/
{
    if (str.isEmpty()) return "";

    QStringList tokens;
    QStringList result;
    QString output;

    if(str.contains(" "))
    {
        tokens = str.split(" ");

        for(auto str : tokens)
        {
            str = str.toLower();
            str[0] = str[0].toUpper();
            result<<str;
        }

        output = result.join(" ");
    }else output = str;

    return output.simplified();
}

inline QString fixString (const QString &str)
{
    //title.remove(QRegExp(QString::fromUtf8("[·-`~!@#$%^&*()_—+=|:;<>«»,.?/{}\'\"\\\[\\\]\\\\]")));
    QString title = str;
    title = title.remove(QChar::Null);
    title = title.contains(QChar('\u0000')) ? title.replace(QChar('\u0000'),"") : title;
    title = title.contains("(") && title.contains(")") ? fixTitle(title, "(",")") : title;
    title = title.contains("[") && title.contains("]") ? fixTitle(title, "[","]") : title;
    title = title.contains("{") && title.contains("}") ? fixTitle(title, "{","}") : title;
    title = title.contains("ft", Qt::CaseInsensitive) ? removeSubstring(title, "ft") : title;
    title = title.contains("ft.", Qt::CaseInsensitive) ? removeSubstring(title, "ft.") : title;
    title = title.contains("featuring", Qt::CaseInsensitive) ? removeSubstring(title, "featuring"):title;
    title = title.contains("feat", Qt::CaseInsensitive) ? removeSubstring(title, "feat") : title;
    title = title.contains("official video", Qt::CaseInsensitive) ? removeSubstring(title, "official video"):title;
    title = title.contains("live", Qt::CaseInsensitive) ? removeSubstring(title, "live") : title;
    title = title.contains("...") ? title.replace("..." ,"") : title;
    title = title.contains("|") ? title.replace("|", "") : title;
    title = title.contains("|") ? removeSubstring(title, "|") : title;
    title = title.contains('"') ? title.replace('"', "") : title;
    title = title.contains(":") ? title.replace(":", "") : title;
    //    title=title.contains("&")? title.replace("&", "and"):title;
    //qDebug()<<"fixed string:"<<title;

    return ucfirst(title).simplified();
}

inline bool fileExists(const QString &url)
{
    return FMH::fileExists(url);
}

inline BAE::TABLE albumType(const BAE::DB &albumMap)
{
    if(albumMap[BAE::KEY::ALBUM].isEmpty() && !albumMap[BAE::KEY::ARTIST].isEmpty())
        return BAE::TABLE::ARTISTS;
    else if(!albumMap[BAE::KEY::ALBUM].isEmpty() && !albumMap[BAE::KEY::ARTIST].isEmpty())
        return BAE::TABLE::ALBUMS;

    return BAE::TABLE::NONE;
}

inline void saveArt(DB &track, const QByteArray &array, const QString &path)
{
    if(!array.isNull()&&!array.isEmpty())
    {
        // qDebug()<<"tryna save array: "<< array;

        QImage img;
        img.loadFromData(array);
        QString name = !track[BAE::KEY::ALBUM].isEmpty() ? track[BAE::KEY::ARTIST] + "_" + track[BAE::KEY::ALBUM] : track[BAE::KEY::ARTIST];
        name.replace("/", "-");
        name.replace("&", "-");
        QString format = "JPEG";
        if (img.save(path + name + ".jpg", format.toLatin1(), 100))
            track.insert(BAE::KEY::ARTWORK,path + name + ".jpg");
        else  qDebug() << "couldn't save artwork";
    }else qDebug()<<"array is empty";
}

inline void saveSettings(const QString &key, const QVariant &value, const QString &group)
{
    QSettings setting("vvave","vvave");
    setting.beginGroup(group);
    setting.setValue(key,value);
    setting.endGroup();
}

inline QVariant loadSettings(const QString &key, const QString &group, const QVariant &defaultValue)
{
    QVariant variant;
    QSettings setting("vvave","vvave");
    setting.beginGroup(group);
    variant = setting.value(key, defaultValue);
    setting.endGroup();

    return variant;
}

inline bool artworkCache(DB &track, const KEY &type = KEY::NONE)
{
    QDirIterator it(CachePath, QDir::Files, QDirIterator::NoIteratorFlags);
    while (it.hasNext())
    {
        auto file = it.next();
        auto fileName = QFileInfo(file).fileName();
        switch(type)
        {
        case KEY::ALBUM:
            if(fileName == track[KEY::ARTIST]+"_"+track[KEY::ALBUM]+".jpg")
            {
                track.insert(KEY::ARTWORK,file);
                return true;
            }
            break;

        case KEY::ARTIST:
            if(fileName == track[KEY::ARTIST]+".jpg")
            {
                track.insert(KEY::ARTWORK,file);
                return true;
            }
            break;
        default: break;
        }
    }
    return false;
}

inline bool internetConnection()
{
    QNetworkAccessManager nam;
    QNetworkRequest req(QUrl("http://google.com"));
    QNetworkReply *reply = nam.get(req);
    QEventLoop loop;
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    loop.exec();

    if(reply->bytesAvailable())
        return true;
    else
        return false;
}
}



#endif // BAE_H
