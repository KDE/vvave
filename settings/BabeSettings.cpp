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


#include "BabeSettings.h"
#include "../db/collectionDB.h"
#include "fileloader.h"
#include "../utils/brain.h"
#include "../services/local/socket.h"
#include "../services/web/youtube.h"
#include "../utils/babeconsole.h"

BabeSettings::BabeSettings(QObject *parent) : QObject(parent)
{

    this->connection = new CollectionDB(this);
    this->fileLoader = new FileLoader;
    this->brainDeamon = new Brain;
    this->ytFetch = new YouTube(this);
    this->babeSocket = new Socket(static_cast<quint16>(BAE::BabePort.toInt()),this);


    qDebug() << "Getting collectionDB info from: " << BAE::CollectionDBPath;
    qDebug() << "Getting settings info from: " << BAE::SettingPath;
    qDebug() << "Getting artwork files from: " << BAE::CachePath;

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    const auto notifyDir = BAE::NotifyDir;

    if(!BAE::fileExists(notifyDir+"/Babe.notifyrc"))
    {
        bDebug::Instance()->msg("The Knotify file does not exists, going to create it");
        QFile knotify(":/assets/Babe.notifyrc");

        if(knotify.copy(notifyDir+"/Babe.notifyrc"))
            bDebug::Instance()->msg("the knotify file got copied");
    }
#endif    

    QDir collectionDBPath_dir(BAE::CollectionDBPath);
    QDir cachePath_dir(BAE::CachePath);
    QDir youtubeCache_dir(BAE::YoutubeCachePath);

    if (!collectionDBPath_dir.exists())
        collectionDBPath_dir.mkpath(".");
    if (!cachePath_dir.exists())
        cachePath_dir.mkpath(".");
    if (!youtubeCache_dir.exists())
        youtubeCache_dir.mkpath(".");

    //    if(!connection->check_existance(TABLEMAP[TABLE::SOURCES], KEYMAP[KEY::URL], BAE::MusicPath))

    if(BAE::isMobile())
        this->populateDB(QStringList()<<BAE::MusicPath<<BAE::DownloadsPath<<BAE::MusicPaths<<BAE::DownloadsPaths);
    else
        this->populateDB({BAE::MusicPath, BAE::YoutubeCachePath});
    //        checkCollectionBrainz(BAE::loadSettings("BRAINZ", "BABE", false).toBool());


    connect(this->ytFetch, &YouTube::done, [this]()
    {
        this->startBrainz(true, BAE::SEG::THREE);
    });

    connect(this->babeSocket, &Socket::message, this->ytFetch, &YouTube::fetch);
    connect(this->babeSocket, &Socket::connected, [this](const int &index)
    {
        auto playlists = this->connection->getPlaylists();
        bDebug::Instance()->msg("Sending playlists to socket: "+playlists.join(", "));
        this->babeSocket->sendMessageTo(index, playlists.join(","));
    });

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
        if(size > 0)
        {
            this->collectionWatcher();
            emit refreshTables({{BAE::TABLEMAP[TABLE::TRACKS], true},
                                {BAE::TABLEMAP[TABLE::ALBUMS], true},
                                {BAE::TABLEMAP[TABLE::ARTISTS], true},
                                {BAE::TABLEMAP[TABLE::PLAYLISTS], true}});


            //            this->startBrainz(true, BAE::SEG::ONEHALF);

            bDebug::Instance()->msg("Finished inserting into DB");
        }else
        {
            this->dirs.clear();
            this->collectionWatcher();
            this->watcher->removePaths(watcher->directories());
            this->startBrainz(BAE::loadSettings("BRAINZ", "BABE", false).toBool(), BAE::SEG::THREE);
        }
    });

    connect(this, &BabeSettings::collectionPathChanged, this, &BabeSettings::populateDB);

    this->watcher = new QFileSystemWatcher(this);
    connect(this->watcher, &QFileSystemWatcher::directoryChanged, this, &BabeSettings::handleDirectoryChanged);
}

BabeSettings::~BabeSettings()
{
    qDebug()<<"DELETING SETTINGS";
    delete fileLoader;
    delete brainDeamon;
}

void BabeSettings::on_remove_clicked()
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

void BabeSettings::refreshCollectionPaths()
{
    //    auto queryTxt = QString("SELECT %1 FROM %2").arg(BAE::KEYMAP[BAE::KEY::URL], BAE::TABLEMAP[BAE::TABLE::SOURCES]);

    //    for (auto track : this->connection->getDBData(queryTxt))
    //    {
    //    }
}

void BabeSettings::addToWatcher(QStringList paths)
{
    bDebug::Instance()->msg("Removed duplicated paths in watcher: "+paths.removeDuplicates());

    if(!paths.isEmpty()) watcher->addPaths(paths);
}

void BabeSettings::collectionWatcher()
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

void BabeSettings::handleDirectoryChanged(const QString &dir)
{
    bDebug::Instance()->msg("directory changed:"+dir);

    auto wait = new QTimer(this);
    wait->setSingleShot(true);
    wait->setInterval(1500);

    connect(wait, &QTimer::timeout,[=]()
    {
        emit collectionPathChanged({dir});
        wait->deleteLater();
    });

    wait->start();

}

void BabeSettings::checkCollectionBrainz(const bool &state)
{
    bDebug::Instance()->msg("BRAINZ STATE<<"+state);
    this->startBrainz(state, BAE::SEG::THREE);
}

void BabeSettings::startBrainz(const bool &on, const uint &speed)
{
    this->brainDeamon->setInterval(speed);

    if(on)
        this->brainDeamon->start();
    else
        this->brainDeamon->pause();

}

void BabeSettings::populateDB(const QStringList &paths)
{   
    auto newPaths = paths;

    for(auto path : newPaths)
        if(path.startsWith("file://"))
            path.replace("file://", "");
    fileLoader->requestPaths(newPaths);
}
