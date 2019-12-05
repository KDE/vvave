#ifndef BRAIN_H
#define BRAIN_H

/* This deamon keeps on running while there are missing information about a track,
 *  it should have the option to turn it off, but the main idea is to here have the
 * brains of the app and collection. so this must be a very good a neat implementation */

#include <QObject>
#include <QThread>

#include "bae.h"
#include "../pulpo/pulpo.h"
#include "../db/collectionDB.h"
#include "downloader.h"

using namespace BAE;
using namespace PULPO;

namespace BRAIN
{
struct QUEUE
{
private:
    QList<PULPO::REQUEST> requests;
    int index = -1;

public:
    PULPO::REQUEST next()
    {
        index++;
        if(index < 0 || index >= requests.size())
            return PULPO::REQUEST{};

        const auto res = requests.at(index);
        return res;
    }

    int currentIndex()
    {
        return index;
    }

    bool hasNext() const
    {
        return index + 1 < requests.size();
    }

    int size() const
    {
        return requests.size();
    }

    void append(const PULPO::REQUEST &request)
    {
        requests << request;
    }

    void operator<< (const PULPO::REQUEST &request)
    {
        append(request);
    }

    void operator<< (const QUEUE &request)
    {
        requests << request.requests;
    }

};


inline static QUEUE artistArtworks()
{
    QUEUE requests;

    auto services = {PULPO::SERVICES::LastFm, PULPO::SERVICES::Spotify, PULPO::SERVICES::MusicBrainz, PULPO::SERVICES::Genius};
    auto ontology = PULPO::ONTOLOGY::ARTIST;

    qDebug() << ("Getting missing artists artworks");
    auto queryTxt = QString("SELECT %1 FROM %2 WHERE %3 = ''").arg(KEYMAP[KEY::ARTIST],
            TABLEMAP[TABLE::ARTISTS], KEYMAP[KEY::ARTWORK]);

    auto db = CollectionDB::getInstance();
    auto artworks = db->getDBData(queryTxt);


    /* BEFORE FETCHING ONLINE LOOK UP IN THE CACHE FOR THE IMAGE */
    for(auto artist : artworks)
        if(BAE::artworkCache(artist, FMH::MODEL_KEY::ARTIST))
            db->insertArtwork(artist);

    artworks = db->getDBData(queryTxt);
    //    this->setInfo(artworks, ontology, services, PULPO::INFO::ARTWORK, PULPO::RECURSIVE::OFF, nullptr);
    qDebug()<< "MISSING ARTIST IMAGES"<< artworks.size() << queryTxt;
    for(const auto &item : artworks)
    {
        REQUEST request;
        request.track = item;
        request.ontology =  ontology;
        request.services = services;
        request.info = {PULPO::INFO::ARTWORK};
        request.callback = [=](PULPO::REQUEST request, PULPO::RESPONSES responses)
        {
            qDebug() << "DONE WITH " << request.track ;

            for(const auto &res : responses)
            {
                if(res.context == PULPO::CONTEXT::IMAGE && !res.value.toString().isEmpty())
                {
                    qDebug()<<"SAVING ARTWORK FOR: " << request.track[FMH::MODEL_KEY::ARTIST];
                    auto downloader = new FMH::Downloader;
                    QObject::connect(downloader, &FMH::Downloader::fileSaved, [=](QString path)
                    {
                        qDebug()<< "Saving artwork file to" << path;
                        FMH::MODEL newTrack = request.track;
                        newTrack[FMH::MODEL_KEY::ARTWORK] = path;
                        db->insertArtwork(newTrack);

                        downloader->deleteLater();

                    });

                    QStringList filePathList = res.value.toString().split('/');
                    const auto format = "." + filePathList.at(filePathList.count() - 1).split(".").last();
                    QString name = !request.track[FMH::MODEL_KEY::ALBUM].isEmpty() ? request.track[FMH::MODEL_KEY::ARTIST] + "_" + request.track[FMH::MODEL_KEY::ALBUM] : request.track[FMH::MODEL_KEY::ARTIST];
                    name.replace("/", "-");
                    name.replace("&", "-");
//                    downloader->downloadFile(res.value.toString(),  BAE::CachePath + name + format);
                }
            }
        };

        requests<< request;
    }

    return requests;
}

inline static QUEUE albumArtworks()
{
    QUEUE requests;
    auto services = {PULPO::SERVICES::LastFm, PULPO::SERVICES::Spotify, PULPO::SERVICES::MusicBrainz};
    auto ontology = PULPO::ONTOLOGY::ALBUM;

    const auto queryTxt = QString("SELECT %1, %2 FROM %3 WHERE %4 = ''").arg(KEYMAP[KEY::ALBUM],
            KEYMAP[KEY::ARTIST], TABLEMAP[TABLE::ALBUMS], KEYMAP[KEY::ARTWORK]);

    auto db = CollectionDB::getInstance();
    /* BEFORE FETCHING ONLINE LOOK UP IN THE CACHE FOR THE IMAGES*/
    auto artworks = db->getDBData(queryTxt);
    for(auto album : artworks)
        if(BAE::artworkCache(album, FMH::MODEL_KEY::ALBUM))
            db->insertArtwork(album);

    artworks = db->getDBData(queryTxt);
    qDebug() << "Getting missing albums artworks"<< artworks.length();

    for(const auto &item : artworks)
    {
        REQUEST request;
        request.track = item;
        request.ontology =  ontology;
        request.services = services;
        request.info = {PULPO::INFO::ARTWORK};
        request.callback = [=](PULPO::REQUEST request, PULPO::RESPONSES responses)
        {
            qDebug() << "DONE WITH " << request.track ;

            for(const auto &res : responses)
            {
                if(res.context == PULPO::CONTEXT::IMAGE && !res.value.toString().isEmpty())
                {
                    qDebug()<<"SAVING ARTWORK FOR: " << request.track[FMH::MODEL_KEY::ALBUM];
                    auto downloader = new FMH::Downloader;
                    QObject::connect(downloader, &FMH::Downloader::fileSaved, [=](QString path)
                    {
                        qDebug()<< "Saving artwork file to" << path;
                        FMH::MODEL newTrack = request.track;
                        newTrack[FMH::MODEL_KEY::ARTWORK] = path;
                        db->insertArtwork(newTrack);

                        downloader->deleteLater();
                    });

                    QStringList filePathList = res.value.toString().split('/');
                    const auto format = "." + filePathList.at(filePathList.count() - 1).split(".").last();
                    QString name = !request.track[FMH::MODEL_KEY::ALBUM].isEmpty() ? request.track[FMH::MODEL_KEY::ARTIST] + "_" + request.track[FMH::MODEL_KEY::ALBUM] : request.track[FMH::MODEL_KEY::ARTIST];
                    name.replace("/", "-");
                    name.replace("&", "-");
//                    downloader->downloadFile(res.value.toString(),  BAE::CachePath + name + format);
                }
            }
        };

        requests<< request;
    }

    return requests;
}


struct PACKAGE
{
    PULPO::ONTOLOGY ontology;
    PULPO::INFO info;
    std::function<void(int index)> callback = nullptr;
};
typedef QList<PACKAGE> PACKAGES;

inline void synapse(const BRAIN::PACKAGES &packages)
{
    if(packages.isEmpty())
        return;

    Pulpo pulpo;
    QEventLoop loop;
    QObject::connect(&pulpo, &Pulpo::finished, &loop, &QEventLoop::quit);

    auto func = [&](QUEUE &m_requests, std::function<void(int index)> cb = nullptr)
    {
        while(m_requests.hasNext())
        {
            pulpo.request(m_requests.next());
            if(cb)
                cb(m_requests.currentIndex());
            loop.exec();
        }
    };

    for(const auto &package : packages)
    {
        switch(package.ontology)
        {
            case PULPO::ONTOLOGY::ALBUM :
            {
                switch(package.info)
                {
                    case PULPO::INFO::ARTWORK:
                    {
                        QUEUE request = BRAIN::albumArtworks();
                        func(request, package.callback);
                        break;
                    }

                    case PULPO::INFO::TAGS:
                    {
                        break;
                    }

                    case PULPO::INFO::WIKI:
                    {
                        break;
                    }
                }

                break;
            }

            case PULPO::ONTOLOGY::ARTIST :
            {
                switch(package.info)
                {
                    case PULPO::INFO::ARTWORK:
                    {
                        QUEUE request = BRAIN::artistArtworks();
                        func(request, package.callback);
                        break;
                    }

                    case PULPO::INFO::TAGS:
                    {
                        break;
                    }

                    case PULPO::INFO::WIKI:
                    {
                        break;
                    }
                }
                break;
            }

            case PULPO::ONTOLOGY::TRACK :
            {
                switch(package.info)
                {
                    case PULPO::INFO::ARTWORK:
                    {

                        break;
                    }

                    case PULPO::INFO::TAGS:
                    {
                        break;
                    }

                    case PULPO::INFO::WIKI:
                    {
                        break;
                    }
                }
                break;
            }
        }
    }
}


void parseAlbumInfo(FMH::MODEL &track, const PULPO::INFO_K &response);
void parseArtistInfo(FMH::MODEL &track, const PULPO::INFO_K &response);
void parseTrackInfo(FMH::MODEL &track, const PULPO::INFO_K &response);
void trackInfo();
void artistInfo();
void albumInfo();





void tags();
void wikis();
void albumTags();
void albumWikis();

void artistTags();
void artistWikis();

void trackArtworks();
void trackLyrics();
void trackTags();
void trackWikis();
}

#endif // BRAIN_H
