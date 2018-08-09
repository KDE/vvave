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

#include "pulpo.h"
#include "services/lastfmService.h"
#include "services/spotifyService.h"
#include "services/lyricwikiaService.h"
#include "services/geniusService.h"
#include "services/musicbrainzService.h"
#include "services/deezerService.h"

//#include "qgumbodocument.h"
//#include "qgumbonode.h"

Pulpo::Pulpo(const BAE::DB &song,QObject *parent)
    : QObject(parent), track(song) {}

Pulpo::Pulpo(QObject *parent): QObject(parent) {}

Pulpo::~Pulpo() {}

bool Pulpo::feed(const BAE::DB &song, const RECURSIVE &recursive)
{
    this->track = song;
    this->recursive = recursive;

    if(this->registeredServices.isEmpty()) return false;
    if(this->track.isEmpty()) return false;

    this->initServices();

    return true;
}

void Pulpo::registerServices(const QList<PULPO::SERVICES> &services)
{
    this->registeredServices = services;
}

void Pulpo::setInfo(const PULPO::INFO &info)
{
    this->info = info;
}

void Pulpo::setOntology(const PULPO::ONTOLOGY &ontology)
{
    this->ontology = ontology;
}

ONTOLOGY Pulpo::getOntology()
{
    return this->ontology;
}

void Pulpo::setRecursive(const RECURSIVE &state)
{
    this->recursive=state;
}

QStringList Pulpo::queryHtml(const QByteArray &array, const QString &className)
{
    QStringList res;

//    auto doc = QGumboDocument::parse(array);
//    auto root = doc.rootNode();

//    auto nodes = root.getElementsByTagName(HtmlTag::TITLE);
//    Q_ASSERT(nodes.size() == 1);

//    auto title = nodes.front();
//    qDebug() << "title is: " << title.innerText();

//    auto container = root.getElementsByClassName(className);
//    //    if(container.size() == 1)
//    //        return res;

//    auto children = container.front().children();
//    for(const auto &i : children)
//        res << i.innerText();


    return res;
}

void Pulpo::initServices()
{
    for(auto service : this->registeredServices)
        switch (service)
        {
        case SERVICES::LastFm:
        {
            lastfm lastfm(this->track);
            connect(&lastfm, &lastfm::infoReady, this, &Pulpo::passSignal);

            if(lastfm.setUpService(this->ontology, this->info))
            {
                if(recursive == RECURSIVE::OFF) return;

            }else qDebug()<<"Error settingUp lastfm service";

            break;
        }

        case SERVICES::Spotify:
        {
            spotify spotify(this->track);
            connect(&spotify, &spotify::infoReady, this, &Pulpo::passSignal);

            if(spotify.setUpService(this->ontology,this->info))
            {
                if(recursive== RECURSIVE::OFF) return;

            }else qDebug()<<"Error settingUp spotify service";

            break;
        }
        case SERVICES::Genius:
        {
            genius genius(this->track);
            connect(&genius, &genius::infoReady, this, &Pulpo::passSignal);

            if(genius.setUpService(this->ontology,this->info))
            {
                if(recursive== RECURSIVE::OFF) return;

            }else qDebug()<<"Error settingUp genius service";

            break;
        }
        case SERVICES::MusicBrainz:
        {
            musicBrainz musicbrainz(this->track);
            connect(&musicbrainz, &musicBrainz::infoReady, this, &Pulpo::passSignal);

            if(musicbrainz.setUpService(this->ontology,this->info))
            {
                if(recursive== RECURSIVE::OFF) return;

            }else qDebug()<<"Error settingUp musicBrainz service";

            break;
        }
        case SERVICES::iTunes:
        {
            break;
        }
        case SERVICES::WikiLyrics:
        {
            break;
        }
        case SERVICES::LyricWikia:
        {
            lyricWikia lyricwikia(this->track);
            connect(&lyricwikia, &lyricWikia::infoReady, this, &Pulpo::passSignal);

            if(lyricwikia.setUpService(this->ontology,this->info))
            {
                if(recursive== RECURSIVE::OFF) return;

            }else qDebug()<<"Error settingUp lyricwikia service";

            break;
        }
        case SERVICES::Wikipedia:
        {
            break;
        }

        case SERVICES::Deezer:
        {
            deezer deezer(this->track);
            connect(&deezer, &deezer::infoReady, this, &Pulpo::passSignal);

            if(deezer.setUpService(this->ontology, this->info))
            {
                if(recursive== RECURSIVE::OFF) return;

            }else qDebug()<<"Error settingUp deezer service";

            break;
        }
        case SERVICES::ALL:
        {
            break;
        }
        case SERVICES::NONE:
        {
            break;
        }
        }
}

void Pulpo::passSignal(const BAE::DB &track, const PULPO::RESPONSE &response)
{
    emit this->infoReady(track, response);
}

PULPO::RESPONSE Pulpo::packResponse(const PULPO::ONTOLOGY ontology, const PULPO::INFO &infoKey, const PULPO::CONTEXT &context, const QVariant &value)
{
    return {{ ontology, {{ infoKey, {{ context, value }} }} }};
}

PULPO::RESPONSE Pulpo::packResponse(const ONTOLOGY ontology, const PULPO::INFO &infoKey, const PULPO::VALUE &map)
{
    return  {{ ontology, { {infoKey, map} }} };
}

bool Pulpo::parseArray()
{
    if(this->ontology == PULPO::ONTOLOGY::NONE)
        return false;

    switch(this->ontology)
    {
    case PULPO::ONTOLOGY::ALBUM: return this->parseAlbum();
    case PULPO::ONTOLOGY::ARTIST: return this->parseArtist();
    case PULPO::ONTOLOGY::TRACK: return this->parseTrack();
    default: return false;
    }

    return false;
}

QByteArray Pulpo::startConnection(const QString &url, const QMap<QString,QString> &headers)
{
    if(!url.isEmpty())
    {
        QUrl mURL(url);
        QNetworkAccessManager manager;
        QNetworkRequest request (mURL);

        if(!headers.isEmpty())
            for(auto key: headers.keys())
                request.setRawHeader(key.toLocal8Bit(), headers[key].toLocal8Bit());

        QNetworkReply *reply =  manager.get(request);
        QEventLoop loop;
        connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);

        connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), &loop,
                SLOT(quit()));

        loop.exec();

        if(reply->error())
        {
            qDebug() << reply->error();
            return QByteArray();
        }

        if(reply->bytesAvailable())
        {
            auto data = reply->readAll();
            reply->deleteLater();

            return data;
        }
    }

    return QByteArray();
}



