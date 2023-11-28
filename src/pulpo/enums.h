#pragma once

#include <MauiKit3/Core/fmh.h>

#include <QMap>
#include <QVariant>

#include <functional>

namespace PULPO
{
enum class SERVICES : uint8_t { LastFm, Spotify, iTunes, MusicBrainz, Genius, LyricWikia, Wikipedia, WikiLyrics, Deezer, ALL, NONE };

enum class ONTOLOGY : uint8_t { ARTIST, ALBUM, TRACK };

enum class INFO : uint8_t { ARTWORK, WIKI, TAGS, METADATA, LYRICS, ALL, NONE };

/*Generic context names. It's encouraged to use these instead of a unkown string*/
enum class PULPO_CONTEXT : uint8_t {
    TRACK_STAT,
    TRACK_NUMBER,
    TRACK_TITLE,
    TRACK_DATE,
    TRACK_TEAM,
    TRACK_AUTHOR,
    TRACK_LANGUAGE,
    TRACK_SIMILAR,

    ALBUM_TEAM,
    ALBUM_STAT,
    ALBUM_TITLE,
    ALBUM_DATE,
    ALBUM_LANGUAGE,
    ALBUM_SIMILAR,
    ALBUM_LABEL,

    ARTIST_STAT,
    ARTIST_TITLE,
    ARTIST_DATE,
    ARTIST_LANGUAGE,
    ARTIST_PLACE,
    ARTIST_SIMILAR,
    ARTIST_TEAM,
    ARTIST_ALIAS,
    ARTIST_GENDER,

    GENRE,
    TAG,
    WIKI,
    IMAGE,
    LYRIC,
    SOURCE

};

static const QMap<PULPO_CONTEXT, QString> CONTEXT_MAP = {{PULPO_CONTEXT::ALBUM_STAT, "album_stat"},
                                                   {PULPO_CONTEXT::ALBUM_TITLE, "album_title"},
                                                   {PULPO_CONTEXT::ALBUM_DATE, "album_date"},
                                                   {PULPO_CONTEXT::ALBUM_LANGUAGE, "album_language"},
                                                   {PULPO_CONTEXT::ALBUM_SIMILAR, "album_similar"},
                                                   {PULPO_CONTEXT::ALBUM_LABEL, "album_label"},
                                                   {PULPO_CONTEXT::ALBUM_TEAM, "album_team"},

                                                   {PULPO_CONTEXT::ARTIST_STAT, "artist_stat"},
                                                   {PULPO_CONTEXT::ARTIST_TITLE, "artist_title"},
                                                   {PULPO_CONTEXT::ARTIST_DATE, "artist_date"},
                                                   {PULPO_CONTEXT::ARTIST_LANGUAGE, "artist_language"},
                                                   {PULPO_CONTEXT::ARTIST_PLACE, "artist_place"},
                                                   {PULPO_CONTEXT::ARTIST_SIMILAR, "artist_similar"},
                                                   {PULPO_CONTEXT::ARTIST_ALIAS, "artist_alias"},
                                                   {PULPO_CONTEXT::ARTIST_GENDER, "artist_gender"},
                                                   {PULPO_CONTEXT::ARTIST_TEAM, "artist_team"},

                                                   {PULPO_CONTEXT::TRACK_STAT, "track_stat"},
                                                   {PULPO_CONTEXT::TRACK_DATE, "track_date"},
                                                   {PULPO_CONTEXT::TRACK_TITLE, "track_title"},
                                                   {PULPO_CONTEXT::TRACK_NUMBER, "track_number"},
                                                   {PULPO_CONTEXT::TRACK_TEAM, "track_team"},
                                                   {PULPO_CONTEXT::TRACK_AUTHOR, "track_author"},
                                                   {PULPO_CONTEXT::TRACK_LANGUAGE, "track_language"},
                                                   {PULPO_CONTEXT::TRACK_SIMILAR, "track_similar"},

                                                   {PULPO_CONTEXT::GENRE, "genre"},
                                                   {PULPO_CONTEXT::TAG, "tag"},
                                                   {PULPO_CONTEXT::WIKI, "wiki"},
                                                   {PULPO_CONTEXT::IMAGE, "image"},
                                                   {PULPO_CONTEXT::LYRIC, "lyric"},
                                                   {PULPO_CONTEXT::SOURCE, "source"}

};

enum class RECURSIVE : bool { ON = true, OFF = false };

typedef QMap<PULPO_CONTEXT, QVariant> VALUE;
typedef QMap<INFO, VALUE> INFO_K;
//    typedef QMap<ONTOLOGY, INFO_K> RESPONSE;

typedef QMap<ONTOLOGY, QList<INFO>> SCOPE;

struct RESPONSE {
    PULPO_CONTEXT context;
    QVariant value;
};
typedef QList<PULPO::RESPONSE> RESPONSES;

struct REQUEST {
    FMH::MODEL track;

    PULPO::ONTOLOGY ontology;
    QList<PULPO::INFO> info;
    QList<PULPO::SERVICES> services;

    std::function<void(REQUEST request, RESPONSES responses)> callback = nullptr;
};
}

