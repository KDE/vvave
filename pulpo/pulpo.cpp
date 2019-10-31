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
//#include "services/spotifyService.h"
//#include "services/lyricwikiaService.h"
//#include "services/geniusService.h"
//#include "services/musicbrainzService.h"
//#include "services/deezerService.h"

//#include "qgumbodocument.h"p
//#include "qgumbonode.h"

Pulpo::Pulpo(QObject *parent): QObject(parent) {}

Pulpo::~Pulpo()
{
    qDebug()<< "DELETING PULPO INSTANCE";
}

void Pulpo::request(const PULPO::REQUEST &request)
{
    this->req = request;

    if(this->req.track.isEmpty())
    {
        emit this->error();
        return;
    }

    if(this->req.services.isEmpty())
    {
        qWarning()<< "Please register at least one Pulpo Service";
        emit this->error();
        return;
    }

    this->start();
}


void Pulpo::start()
{
    for(const auto &service : this->req.services)
        switch (service)
        {
        case SERVICES::LastFm:
        {
            auto lastfm  = new class lastfm();
            connect(lastfm, &lastfm::responseReady,[&, _lastfm = std::move(lastfm)](PULPO::REQUEST request, PULPO::RESPONSES responses)
            {
                this->passSignal(request, responses);
                _lastfm->deleteLater();
            });
            lastfm->set(this->req);
            break;
        }

            default: continue;
        }
}

void Pulpo::passSignal(const REQUEST &request, const RESPONSES &responses)
{
    if(request.callback)
        request.callback(request, responses);
    else
        emit this->infoReady(request, responses);
    emit this->finished();
}
