#ifndef BAE_H
#define BAE_H

#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QFileInfo>
#include <QImage>
#include <QTime>
#include <QSettings>
#include <QDirIterator>
#include <QScreen>


#ifdef STATIC_MAUIKIT
#include "fmh.h"
#else
#include "vvave_version.h"
#include <MauiKit/fmh.h>
#endif

namespace BAE
{
Q_NAMESPACE

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

const static inline QString transformTime(const qint64 &value)
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

const static inline QString getNameFromLocation(const QString &str)
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

const static QString SettingPath =  QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation)+"/vvave/").toLocalFile();
const QString CollectionDBPath =  QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/vvave/").toLocalFile();

#ifdef Q_OS_ANDROID
const static QString CachePath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/vvave/").toString();
#else
const static QString CachePath =  QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation)+"/vvave/").toString();
#endif

const static QString YoutubeCachePath =  QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation)+"/vvave/youtube/").toLocalFile();
const static QString NotifyDir = SettingPath;

const static QString MusicPath = FMH::MusicPath;
const static QString HomePath = FMH::HomePath;
const static QString DownloadsPath = FMH::DownloadsPath;

const static QString BabePort = "8483";
const static QString LinkPort = "3333";

const static QString appName = QStringLiteral("vvave");
const static QString displayName = QStringLiteral("Vvave");
const static QString version = VVAVE_VERSION_STRING;
const static QString description = QStringLiteral("Music player");
const static QString orgName = QStringLiteral("Maui");
const static QString orgDomain = QStringLiteral("org.maui.vvave");

const static QString DBName = "collection.db";

const static QStringList MoodColors = {"#F0FF01","#01FF5B","#3DAEFD","#B401FF","#E91E63"};
const static QStringList defaultSources = QStringList() << BAE::MusicPath
                                                 << BAE::DownloadsPath
                                                 << BAE::YoutubeCachePath;

const static inline QString fixTitle(const QString &title,const QString &s,const QString &e)
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

const static inline QString removeSubstring(const QString &newTitle, const QString &subString)
{
    const int indexFt = newTitle.indexOf(subString, 0, Qt::CaseInsensitive);

    if (indexFt != -1)
        return newTitle.left(indexFt).simplified();
    else
        return newTitle;
}

const static inline QString ucfirst(const QString &str)/*uppercase first letter*/
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

const static inline QString fixString (const QString &str)
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

 static inline bool fileExists(const QString &url)
{
    return FMH::fileExists(QUrl::fromLocalFile(url));
}

 static inline BAE::TABLE albumType(const FMH::MODEL &albumMap)
{
    if(albumMap[FMH::MODEL_KEY::ALBUM].isEmpty() && !albumMap[FMH::MODEL_KEY::ARTIST].isEmpty())
        return BAE::TABLE::ARTISTS;
    else if(!albumMap[FMH::MODEL_KEY::ALBUM].isEmpty() && !albumMap[FMH::MODEL_KEY::ARTIST].isEmpty())
        return BAE::TABLE::ALBUMS;

    return BAE::TABLE::NONE;
}

static inline void saveArt(FMH::MODEL &track, const QByteArray &array, const QString &path)
{
    if(!array.isNull()&&!array.isEmpty())
    {
        // qDebug()<<"tryna save array: "<< array;

        QImage img;
        img.loadFromData(array);
        QString name = !track[FMH::MODEL_KEY::ALBUM].isEmpty() ? track[FMH::MODEL_KEY::ARTIST] + "_" + track[FMH::MODEL_KEY::ALBUM] : track[FMH::MODEL_KEY::ARTIST];
        name.replace("/", "-");
        name.replace("&", "-");
        QString format = "PNG";
        qDebug()<< "SAVER TO "<< path + name + ".png";
        if (img.save(path + name + ".png", format.toLatin1(), 100))
            track.insert(FMH::MODEL_KEY::ARTWORK,path + name + ".png");
        else  qDebug() << "couldn't save artwork";
    }else qDebug()<<"array is empty";
}

static inline void saveSettings(const QString &key, const QVariant &value, const QString &group)
{
    QSettings setting("vvave","vvave");
    setting.beginGroup(group);
    setting.setValue(key,value);
    setting.endGroup();
}

static inline QVariant loadSettings(const QString &key, const QString &group, const QVariant &defaultValue)
{
    QVariant variant;
    QSettings setting("vvave","vvave");
    setting.beginGroup(group);
    variant = setting.value(key, defaultValue);
    setting.endGroup();

    return variant;
}

static inline bool artworkCache(FMH::MODEL &track, const FMH::MODEL_KEY &type = FMH::MODEL_KEY::ID)
{
    QDirIterator it(QUrl(CachePath).toLocalFile(), QDir::Files, QDirIterator::NoIteratorFlags);
    while (it.hasNext())
    {
        const auto file = QUrl::fromLocalFile(it.next());
        const auto fileName = QFileInfo(file.toLocalFile()).baseName();
        switch(type)
        {
        case FMH::MODEL_KEY::ALBUM:
            if(fileName == (track[FMH::MODEL_KEY::ARTIST]+"_"+track[FMH::MODEL_KEY::ALBUM]))
            {
                track.insert(FMH::MODEL_KEY::ARTWORK, file.toString());
                return true;
            }
            break;

        case FMH::MODEL_KEY::ARTIST:
            if(fileName == (track[FMH::MODEL_KEY::ARTIST]))
            {
                track.insert(FMH::MODEL_KEY::ARTWORK, file.toString());
                return true;
            }
            break;
        default: break;
        }
    }
    return false;
}

}



#endif // BAE_H
