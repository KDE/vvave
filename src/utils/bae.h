#ifndef BAE_H
#define BAE_H

#include <QDirIterator>
#include <QFileInfo>
#include <QStandardPaths>
#include <QString>

#include <MauiKit4/Core/fmh.h>
#include <MauiKit4/FileBrowsing/fmstatic.h>

namespace BAE
{
enum class W : uint_fast8_t { ALL, NONE, LIKE, TAG, SIMILAR, UNKNOWN, DONE, DESC, ASC, CODE, MSG };

static const QMap<W, QString> SLANG =
    {{W::ALL, "ALL"}, {W::NONE, "NONE"}, {W::LIKE, "LIKE"}, {W::SIMILAR, "SIMILAR"}, {W::UNKNOWN, "UNKNOWN"}, {W::DONE, "DONE"}, {W::DESC, "DESC"}, {W::ASC, "ASC"}, {W::TAG, "TAG"}, {W::MSG, "MSG"}, {W::CODE, "CODE"}};

enum class TABLE : uint8_t { ALBUMS, ARTISTS, SOURCES, SOURCES_TYPES, TRACKS, FOLDERS, ALL, NONE };

static const QMap<TABLE, QString> TABLEMAP = {{TABLE::ALBUMS, "albums"}, {TABLE::ARTISTS, "artists"}, {TABLE::SOURCES, "sources"}, {TABLE::SOURCES_TYPES, "sources_types"}, {TABLE::TRACKS, "tracks"}, {TABLE::FOLDERS, "folders"}

};

enum class KEY : uint8_t {
    URL = 0,
    SOURCES_URL = 1,
    TRACK = 2,
    TITLE = 3,
    ARTIST = 4,
    ALBUM = 5,
    DURATION = 6,
    PLAYED = 7,
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

static const DB KEYMAP = {{KEY::URL, "url"},
                          {KEY::SOURCES_URL, "sources_url"},
                          {KEY::TRACK, "track"},
                          {KEY::TITLE, "title"},
                          {KEY::ARTIST, "artist"},
                          {KEY::ALBUM, "album"},
                          {KEY::DURATION, "duration"},
                          {KEY::PLAYED, "played"},
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
                          {KEY::SQL, "sql"}};

static const QString CollectionDBPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/vvave/").toLocalFile();

#ifdef Q_OS_ANDROID
const static QUrl CachePath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + "/vvave/");
#else
const static QUrl CachePath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation) + "/vvave/");
#endif

const static QString DBName = QStringLiteral("collection_v2.db");
const static QStringList defaultSources = QStringList() << FMStatic::MusicPath << FMStatic::DownloadsPath;

static inline BAE::TABLE albumType(const FMH::MODEL &albumMap)
{
    if (albumMap[FMH::MODEL_KEY::ALBUM].isEmpty() && !albumMap[FMH::MODEL_KEY::ARTIST].isEmpty())
        return BAE::TABLE::ARTISTS;
    else if (!albumMap[FMH::MODEL_KEY::ALBUM].isEmpty() && !albumMap[FMH::MODEL_KEY::ARTIST].isEmpty())
        return BAE::TABLE::ALBUMS;

    return BAE::TABLE::NONE;
}

static inline void fixArtworkImageFileName(QString &title)
{
    title.replace("/", "_");
    title.replace(".", "_");
    title.replace("+", "_");
    title.replace("&", "_");
}

static inline bool artworkCache(FMH::MODEL &track, const FMH::MODEL_KEY &type = FMH::MODEL_KEY::ID)
{
    QDirIterator it(CachePath.toLocalFile(), QDir::Files, QDirIterator::NoIteratorFlags);
    while (it.hasNext()) {
        const auto file = QUrl::fromLocalFile(it.next());
        const auto fileName = QFileInfo(file.toLocalFile()).baseName();
        switch (type) {
        case FMH::MODEL_KEY::ALBUM: {
            QString name = track[FMH::MODEL_KEY::ARTIST] + "_" + track[FMH::MODEL_KEY::ALBUM];
            fixArtworkImageFileName(name);

            if (fileName == name) {
                track.insert(FMH::MODEL_KEY::ARTWORK, file.toString());
                return true;
            } else
                continue;
            break;
        }

        case FMH::MODEL_KEY::ARTIST: {
            auto name = track[FMH::MODEL_KEY::ARTIST];
            fixArtworkImageFileName(name);

            if (fileName == name) {
                track.insert(FMH::MODEL_KEY::ARTWORK, file.toString());
                return true;
            } else
                continue;
            break;
        }
        default:
            break;
        }
    }
    return false;
}

}

#endif // BAE_H
