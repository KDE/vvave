#ifndef FILELOADER_H
#define FILELOADER_H

#include <QObject>
#include <QDirIterator>
#include <QUrl>
#include "services/local/taginfo.h"
#include "db/collectionDB.h"
#include "utils/bae.h"

namespace FLoader
{

static inline QList<QUrl> getPathContents(QList<QUrl> &urls, const QUrl &url)
{
    if(!FMH::fileExists(url) && !url.isLocalFile())
        return urls;

    if (QFileInfo(url.toLocalFile()).isDir())
    {
        QDirIterator it(url.toLocalFile(), QStringList() << FMH::FILTER_LIST[FMH::FILTER_TYPE::AUDIO] << "*.m4a", QDir::Files, QDirIterator::Subdirectories);

        while (it.hasNext())
            urls << QUrl::fromLocalFile(it.next());

    }else if (QFileInfo(url.toLocalFile()).isFile())
        urls << url.toString();

    return urls;
}

// returns the number of new items added to the collection db
static inline uint getTracks(const QList<QUrl>& paths)
{
    const auto db = CollectionDB::getInstance();
    const auto urls = std::accumulate(paths.begin(), paths.end(), QList<QUrl>(), getPathContents);

    for(const auto &path : paths)
        if(path.isLocalFile() && FMH::fileExists(path))
            db->addFolder(path.toString());

    uint newTracks = 0;

    if(urls.isEmpty())
        return newTracks;

    for(const auto &url : urls)
    {
        if(db->check_existance(BAE::TABLEMAP[BAE::TABLE::TRACKS], FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url.toString()))
            continue;

        TagInfo info(url.toLocalFile());
        if(info.isNull())
            continue;

        qDebug()<< url << "HHH";

        const auto track = info.getTrack();
        const auto genre = info.getGenre();
        const auto album = BAE::fixString(info.getAlbum());
        const auto title = BAE::fixString(info.getTitle()); /* to fix*/
        const auto artist = BAE::fixString(info.getArtist());
        const auto sourceUrl = FMH::parentDir(url).toString();
        const auto duration = info.getDuration();
        const auto year = info.getYear();

        FMH::MODEL trackMap =
        {
            {FMH::MODEL_KEY::URL, url.toString()},
            {FMH::MODEL_KEY::TRACK, QString::number(track)},
            {FMH::MODEL_KEY::TITLE, title},
            {FMH::MODEL_KEY::ARTIST, artist},
            {FMH::MODEL_KEY::ALBUM, album},
            {FMH::MODEL_KEY::DURATION,QString::number(duration)},
            {FMH::MODEL_KEY::GENRE, genre},
            {FMH::MODEL_KEY::SOURCE, sourceUrl},
            {FMH::MODEL_KEY::FAV, "0"},
            {FMH::MODEL_KEY::RELEASEDATE, QString::number(year)}
        };

        BAE::artworkCache(trackMap, FMH::MODEL_KEY::ALBUM);

        if(db->addTrack(trackMap))
            newTracks++;
    }
    return newTracks;
}
}

#endif // FILELOADER_H
