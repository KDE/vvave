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
#include "../utils/brain.h"
#include "../services/local/socket.h"
#include "../services/local/youtubedl.h"
#include "../utils/babeconsole.h"

BabeSettings::BabeSettings(QObject *parent) : QObject(parent)
{
    this->connection = CollectionDB::getInstance();
    this->brainDeamon = new Brain;
    this->ytFetch = new youtubedl(this);
    this->babeSocket = new Socket(static_cast<quint16>(BAE::BabePort.toInt()), this);

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    if(!BAE::fileExists(BAE::NotifyDir+"/vvave.notifyrc"))
    {
        QFile knotify(":/assets/vvave.notifyrc");

        if(knotify.copy(BAE::NotifyDir+"/vvave.notifyrc"))
            bDebug::Instance()->msg("the knotify file got copied");
    }
#endif    

    QDir cachePath_dir(BAE::CachePath);
    QDir youtubeCache_dir(BAE::YoutubeCachePath);

    if (!cachePath_dir.exists())
        cachePath_dir.mkpath(".");
    if (!youtubeCache_dir.exists())
        youtubeCache_dir.mkpath(".");

    connect(this->ytFetch, &youtubedl::done, [this]()
    {
        this->startBrainz(true, BAE::SEG::THREE);
    });

    connect(this->babeSocket, &Socket::message, this, &BabeSettings::fetchYoutubeTrack);
    connect(this->babeSocket, &Socket::connected, [this](const int &index)
    {
        auto playlists = this->connection->getPlaylistsList();
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

    connect(&this->fileLoader, &FileLoader::finished, [this](int size)
    {
//        if(size > 0)
//            this->startBrainz(true, BAE::SEG::HALF);
//        else
//            this->startBrainz(BAE::loadSettings("AUTO", "BRAINZ", true).toBool(), BAE::SEG::TWO);

        emit refreshTables(size);
    });

    connect(this, &BabeSettings::collectionPathChanged, this, &BabeSettings::populateDB);
}

BabeSettings::~BabeSettings()
{
    qDebug()<<"DELETING SETTINGS";
    delete brainDeamon;
}

void BabeSettings::refreshCollection()
{    
    if(this->connection->getSourcesFolders().isEmpty())
        this->populateDB(BAE::defaultSources);
    else
        this->populateDB(this->connection->getSourcesFolders());
}

void BabeSettings::fetchYoutubeTrack(const QString &message)
{
    this->ytFetch->fetch(message);
}

void BabeSettings::startBrainz(const bool &on, const uint &speed)
{
    qDebug()<< "Starting Brainz with interval: "<< speed << on;
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

    this->fileLoader.requestPaths(newPaths);
}
