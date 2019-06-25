#ifndef FILELOADER_H
#define FILELOADER_H

#include <QObject>
#include <QDirIterator>
#include "../services/local/taginfo.h"
#include "../db/collectionDB.h"
#include "utils/bae.h"

namespace FLoader
{

inline QStringList getPathContents(QStringList urls, QString path)
{
    if(!FMH::fileExists(path))
        return urls;

    if (QFileInfo(path).isDir())
    {
        QDirIterator it(path, QStringList() << FMH::FILTER_LIST[FMH::FILTER_TYPE::AUDIO] << "*.m4a", QDir::Files, QDirIterator::Subdirectories);

        while (it.hasNext())
            urls << it.next();

    }else if (QFileInfo(path).isFile())
        urls << path;

    return urls;
}

// returns the number of new items added to the collection db
inline uint getTracks(const QStringList& paths)
{
    auto db = CollectionDB::getInstance();
    const auto urls = std::accumulate(paths.begin(), paths.end(), QStringList(), getPathContents);

    for(const auto &path : paths)
        if(FMH::fileExists(path))
            db->addFolder(path);

    uint newTracks = 0;

    if(urls.isEmpty())
        return newTracks;

    TagInfo info;
    for(const auto &url : urls)
    {
        if(db->check_existance(BAE::TABLEMAP[BAE::TABLE::TRACKS], FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url))
            continue;

        if(!info.feed(url))
            continue;

        const auto track = info.getTrack();
        const auto genre = info.getGenre();
        const auto album = BAE::fixString(info.getAlbum());
        const auto title = BAE::fixString(info.getTitle()); /* to fix*/
        const auto artist = BAE::fixString(info.getArtist());
        const auto sourceUrl = QFileInfo(url).dir().path();
        const auto duration = info.getDuration();
        const auto year = info.getYear();

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

        if(db->addTrack(trackMap))
            newTracks++;
    }
    return newTracks;
}
}

#endif // FILELOADER_H
