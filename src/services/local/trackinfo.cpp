#include "trackinfo.h"
#include "pulpo/pulpo.h"


TrackInfo::TrackInfo(QObject *parent) : QObject(parent)
{
    connect(this, &TrackInfo::trackChanged, this, &TrackInfo::getInfo);
}

QString TrackInfo::albumWiki() const
{
    return m_albumWiki;
}

QString TrackInfo::artistWiki() const
{
    return m_artistWiki;
}

QString TrackInfo::trackWiki() const
{
    return m_trackWiki;
}

QString TrackInfo::lyrics() const
{
    return m_lyrics;
}

QVariantMap TrackInfo::track() const
{
    return m_track;
}

void TrackInfo::setTrack(QVariantMap track)
{
    if (m_track == track)
        return;

    m_track = track;
    emit trackChanged(m_track);
}

void TrackInfo::getInfo()
{
    if(m_track.isEmpty())
        return;

    auto artist = m_track.value("artist").toString();
    auto album = m_track.value("album").toString();
    auto title = m_track.value("title").toString();

    if(artist!= m_artist)
    {
        m_artist = artist;
        getArtistInfo();
    }

    if(album != m_album)
    {
        m_album = album;
        getAlbumInfo();
    }

    if(title != m_title)
    {
        m_title = title;
        getTrackInfo();
    }

}

void TrackInfo::getAlbumInfo()
{
    PULPO::REQUEST request;
    request.track = FMH::toModel(m_track);
    request.ontology = PULPO::ONTOLOGY::ALBUM;
    request.services = {PULPO::SERVICES::LastFm, PULPO::SERVICES::Spotify};
    request.info = {PULPO::INFO::WIKI};
    request.callback = [&](PULPO::REQUEST request, PULPO::RESPONSES responses) {
        qDebug() << "DONE WITH " << request.track;

        for (const auto &res : responses) {
            if (res.context == PULPO::PULPO_CONTEXT::WIKI) {
                m_albumWiki = res.value.toString();
                emit this->albumWikiChanged(m_albumWiki);
            }
        }
    };

    auto pulpo = new Pulpo;
    QObject::connect(pulpo, &Pulpo::finished, pulpo, &Pulpo::deleteLater);
    QObject::connect(pulpo, &Pulpo::error, [pulpo]() {
        pulpo->deleteLater();
    });

    pulpo->request(request);
}

void TrackInfo::getArtistInfo()
{
    PULPO::REQUEST request;
    request.track = FMH::toModel(m_track);
    request.ontology = PULPO::ONTOLOGY::ARTIST;
    request.services = {PULPO::SERVICES::LastFm, PULPO::SERVICES::Spotify};
    request.info = {PULPO::INFO::WIKI};
    request.callback = [&](PULPO::REQUEST request, PULPO::RESPONSES responses) {
        qDebug() << "DONE WITH " << request.track;

        for (const auto &res : responses) {
            if (res.context == PULPO::PULPO_CONTEXT::WIKI) {
                m_artistWiki = res.value.toString();
                emit this->artistWikiChanged(m_artistWiki);
            }
        }
    };

    auto pulpo = new Pulpo;
    QObject::connect(pulpo, &Pulpo::finished, pulpo, &Pulpo::deleteLater);
    QObject::connect(pulpo, &Pulpo::error, [pulpo]() {
        pulpo->deleteLater();
    });

    pulpo->request(request);
}

void TrackInfo::getTrackInfo()
{
    PULPO::REQUEST request;
    request.track = FMH::toModel(m_track);
    request.ontology = PULPO::ONTOLOGY::TRACK;
    request.services = {PULPO::SERVICES::LyricWikia, PULPO::SERVICES::WikiLyrics};
    request.info = {PULPO::INFO::LYRICS};
    request.callback = [&](PULPO::REQUEST request, PULPO::RESPONSES responses) {
        qDebug() << "DONE WITH " << request.track;

        for (const auto &res : responses) {
            if (res.context == PULPO::PULPO_CONTEXT::LYRIC) {
                m_lyrics = res.value.toString();
                emit this->lyricsChanged(m_lyrics);
            }
        }
    };

    auto pulpo = new Pulpo;
    QObject::connect(pulpo, &Pulpo::finished, pulpo, &Pulpo::deleteLater);
    QObject::connect(pulpo, &Pulpo::error, [pulpo]() {
        pulpo->deleteLater();
    });

    pulpo->request(request);
}
