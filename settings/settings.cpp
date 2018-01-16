/*
   Babe - tiny music player
   Copyright (C) 2017  Camilo Higuita
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

   */


#include "settings.h"
#include "../db/collectionDB.h"
#include "fileloader.h"
#include "../utils/brain.h"
#include "../services/local/socket.h"
#include "../services/web/youtube.h"

settings::settings(QObject *parent) : QObject(parent)
{

    this->connection = new CollectionDB(this);
    this->fileLoader = new FileLoader;
    this->brainDeamon = new Brain;
    
    //    connect(connection, &CollectionDB::initDB, [this] ()
    //    {
    //        this->populateDB(BAE::MusicPath);
    //    });

    qDebug() << "Getting collectionDB info from: " << BAE::CollectionDBPath;
    qDebug() << "Getting settings info from: " << BAE::SettingPath;
    qDebug() << "Getting artwork files from: " << BAE::CachePath;

#if defined(Q_OS_LINUX)
    const auto notifyDir = BAE::NotifyDir;

    if(!BAE::fileExists(notifyDir+"/Babe.notifyrc"))
    {
        qDebug()<<"The Knotify file does not exists, going to create it";
        QFile knotify(":/assets/Babe.notifyrc");

        if(knotify.copy(notifyDir+"/Babe.notifyrc"))
            qDebug()<<"the knotify file got copied";
    }
#endif

    QDir collectionDBPath_dir(BAE::CollectionDBPath);
    QDir cachePath_dir(BAE::isMobile() ? BAE::ArtworkPath :  BAE::CachePath);
    QDir youtubeCache_dir(BAE::YoutubeCachePath);

    if (!collectionDBPath_dir.exists())
        collectionDBPath_dir.mkpath(".");
    if (!cachePath_dir.exists())
        cachePath_dir.mkpath(".");
    if (!youtubeCache_dir.exists())
        youtubeCache_dir.mkpath(".");

    //    if(!connection->check_existance(TABLEMAP[TABLE::SOURCES], KEYMAP[KEY::URL], BAE::MusicPath))

    if(BAE::isMobile())
        this->populateDB({BAE::MusicPath, BAE::DownloadsPath});
    else
        checkCollection();

    connect(this->brainDeamon, &Brain::finished, [this]()
    {
        emit this->brainFinished();
    });

    connect(this->brainDeamon, &Brain::done, [this](const TABLE type)
    {
        emit this->refreshTables({{BAE::TABLEMAP[type], true}});
    });


    //    connect(this->fileLoader, &FileLoader::trackReady, [this]()
    //    {
    //        this->ui->progressBar->setValue(this->ui->progressBar->value()+1);
    //    });

    connect(this->fileLoader, &FileLoader::finished,[this](int size)
    {
        this->brainzOn = true;

        if(size>0)
        {
            this->collectionWatcher();
            emit refreshTables({{BAE::TABLEMAP[TABLE::TRACKS], true},
                                {BAE::TABLEMAP[TABLE::ALBUMS], true},
                                {BAE::TABLEMAP[TABLE::ARTISTS], true},
                                {BAE::TABLEMAP[TABLE::PLAYLISTS], true}});


            this->startBrainz(500);
        }else
        {
            this->dirs.clear();
            this->collectionWatcher();
            this->watcher->removePaths(watcher->directories());
            this->startBrainz(1500);
        }


    });

    connect(this, &settings::collectionPathChanged, this, &settings::populateDB);

    this->watcher = new QFileSystemWatcher(this);
    connect(this->watcher, &QFileSystemWatcher::directoryChanged, this, &settings::handleDirectoryChanged);
}

settings::~settings()
{
    qDebug()<<"DELETING SETTINGS";
    delete fileLoader;
    delete brainDeamon;
}

void settings::on_remove_clicked()
{
    qDebug() << this->pathToRemove;
    if (!this->pathToRemove.isEmpty())
    {
        if(this->connection->removeSource(this->pathToRemove))
        {
            this->refreshCollectionPaths();
            this->dirs.clear();
            this->collectionWatcher();
            this->watcher->removePaths(watcher->directories());
            emit refreshTables({{TABLEMAP[TABLE::TRACKS], true},
                                {TABLEMAP[TABLE::PLAYLISTS], true}});
        }
    }
}

void settings::refreshCollectionPaths()
{
    //    auto queryTxt = QString("SELECT %1 FROM %2").arg(BAE::KEYMAP[BAE::KEY::URL], BAE::TABLEMAP[BAE::TABLE::SOURCES]);

    //    for (auto track : this->connection->getDBData(queryTxt))
    //    {
    //    }
}

void settings::addToWatcher(QStringList paths)
{
    qDebug()<<"duplicated paths in watcher removd: "<<paths.removeDuplicates();

    if(!paths.isEmpty()) watcher->addPaths(paths);
}

void settings::collectionWatcher()
{
    auto queryTxt = QString("SELECT %1 FROM %2").arg(BAE::KEYMAP[BAE::KEY::URL], BAE::TABLEMAP[BAE::TABLE::TRACKS]);

    for (auto track : this->connection->getDBData(queryTxt))
    {
        auto location = track[BAE::KEY::URL];
        if(!location.startsWith(BAE::YoutubeCachePath,Qt::CaseInsensitive)) //exclude the youtube cache folder
        {
            if (!this->dirs.contains(QFileInfo(location).dir().path()) && BAE::fileExists(location)) //check if parent dir isn't already in list and it exists
            {
                QString dir = QFileInfo(location).dir().path();
                this->dirs << dir;

                QDirIterator it(dir, QDir::Dirs | QDir::NoDotAndDotDot, QDirIterator::Subdirectories); // get all the subdirectories to watch
                while (it.hasNext())
                {
                    QString subDir = QFileInfo(it.next()).path();

                    if(QFileInfo(subDir).isDir() && !this->dirs.contains(subDir) && BAE::fileExists(subDir))
                        this->dirs <<subDir;
                }

            }
        }
    }
    this->addToWatcher(this->dirs);
}

void settings::handleDirectoryChanged(const QString &dir)
{
    qDebug()<<"directory changed:"<<dir;

    auto wait = new QTimer(this);
    wait->setSingleShot(true);
    wait->setInterval(1000);

    connect(wait, &QTimer::timeout,[=]()
    {
        emit collectionPathChanged({dir});
        wait->deleteLater();
    });

    wait->start();

}

void settings::checkCollection()
{
    //    this->refreshCollectionPaths();
    //    this->collectionWatcher();
    this->brainzOn = true;
    this->startBrainz(1500);
}

void settings::startBrainz(const int &speed)
{
    if(this->brainzOn)
    {
        this->brainDeamon->setInterval(speed);
        this->brainDeamon->start();
    }

}

void settings::populateDB(const QStringList &paths)
{
    qDebug() << "Function Name: " << Q_FUNC_INFO
             << "new path for database action: " << paths;
    auto newPaths = paths;
    for(auto path : newPaths)
        if(path.startsWith("file://"))
            path.replace("file://", "");
    fileLoader->requestPaths(newPaths);
}
