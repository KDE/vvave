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
#include "../services/local/youtubedl.h"
#include "../utils/babeconsole.h"

BabeSettings::BabeSettings(QObject *parent) : QObject(parent)
{

    this->connection = new CollectionDB(this);
    this->fileLoader = new FileLoader;
    this->brainDeamon = new Brain;
    this->ytFetch = new youtubedl(this);
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

    connect(this->ytFetch, &youtubedl::done, [this]()
    {
        this->startBrainz(true, BAE::SEG::THREE);
    });

    connect(this->babeSocket, &Socket::message, this->ytFetch, &youtubedl::fetch);
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
        emit this->refreshATable(type);
    });

    connect(this->fileLoader, &FileLoader::finished,[this](int size)
    {
        if(size > 0)
        {
            bDebug::Instance()->msg("Finished inserting into DB "+QString::number(size)+" tracks");
            bDebug::Instance()->msg("Starting Brainz with interval: " + QString::number(BAE::SEG::ONEHALF));
            this->startBrainz(true, BAE::SEG::ONEHALF);

        }else
            this->startBrainz(BAE::loadSettings("BRAINZ", "BABE", false).toBool(), BAE::SEG::THREE);

        emit refreshTables(size);
    });

    connect(this, &BabeSettings::collectionPathChanged, this, &BabeSettings::populateDB);
}

BabeSettings::~BabeSettings()
{
    qDebug()<<"DELETING SETTINGS";
    delete fileLoader;
    delete brainDeamon;
}

void BabeSettings::refreshCollection()
{    
    if(this->connection->getSourcesFolders().isEmpty())
        this->populateDB(BAE::defaultSources);
    else
        this->populateDB(this->connection->getSourcesFolders());
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
