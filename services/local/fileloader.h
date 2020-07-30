/***
Pix  Copyright (C) 2018  Camilo Higuita
This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
This is free software, and you are welcome to redistribute it
under certain conditions; type `show c' for details.

 This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
***/

#ifndef FILELOADER_H
#define FILELOADER_H

#include <QObject>
#include <QDirIterator>
#include <QFileInfo>
#include <QThread>

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
#include <MauiKit/fmh.h>
#else
#include "fmh.h"
#endif

#include "services/local/taginfo.h"
#include "utils/bae.h"


class FileLoader : public QObject
{
    Q_OBJECT

public:
    FileLoader(QObject *parent = nullptr) : QObject(parent)
    {
        this->moveToThread(&t);
        connect(this, &FileLoader::start, this, &FileLoader::fetch);
        this->t.start();
    }

    ~FileLoader()
    {
        t.quit();
        t.wait();
    }

    inline void requestPath(const QList<QUrl> &urls, const bool &recursive)
    {
        qDebug()<<"FROM file loader"<< urls;
        emit this->start(urls, recursive);
    }

private slots:
    inline void fetch(QList<QUrl> paths, bool recursive)
    {

        qDebug()<<"GETTING TRACKS";
        const uint m_bsize = 5000;
        uint i = 0;
        uint batch = 0;
        FMH::MODEL_LIST res;
        FMH::MODEL_LIST res_batch;
        QList<QUrl> urls;

        for(const auto &path : paths)
        {
            if (QFileInfo(path.toLocalFile()).isDir() && path.isLocalFile() && FMH::fileExists(path))
            {
                QDirIterator it(path.toLocalFile(), QStringList() << FMH::FILTER_LIST[FMH::FILTER_TYPE::AUDIO] << "*.m4a", QDir::Files, recursive ? QDirIterator::Subdirectories : QDirIterator::NoIteratorFlags);

                while (it.hasNext())
                {
                    const auto url = QUrl::fromLocalFile(it.next());
                    urls << url;

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

                    FMH::MODEL map =
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

                    BAE::artworkCache(map, FMH::MODEL_KEY::ALBUM);

                    emit itemReady(map);
                    res << map;
                    res_batch << map;
                    i++;

                    if(i == m_bsize) //send a batch
                    {
                        emit itemsReady(res_batch);
                        res_batch.clear ();
                        batch++;
                        i = 0;
                    }
                }
            }
        }
        emit itemsReady(res_batch);
        emit finished(res);
    }

signals:
    void finished(FMH::MODEL_LIST items);
    void start(QList<QUrl> urls, bool recursive);

    void itemsReady(FMH::MODEL_LIST items);
    void itemReady(FMH::MODEL item);

private:
    QThread t;
};


#endif // FILELOADER_H
