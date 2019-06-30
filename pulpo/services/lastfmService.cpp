#include "lastfmService.h"

using namespace PULPO;

lastfm::lastfm()
{    
    this->scope.insert(ONTOLOGY::ALBUM, {INFO::ARTWORK, INFO::WIKI, INFO::TAGS});
    this->scope.insert(ONTOLOGY::ARTIST, {INFO::ARTWORK, INFO::WIKI, INFO::TAGS});
    this->scope.insert(ONTOLOGY::TRACK, {INFO::TAGS, INFO::WIKI, INFO::ARTWORK, INFO::METADATA});

    connect(this, &lastfm::arrayReady, this, &lastfm::parse);
}

lastfm::~lastfm()
{
    qDebug()<< "DELETING LASTFM INSTANCE";
}

void lastfm::set(const PULPO::REQUEST &request)
{
    this->request = request;

    //    if(!this->scope[this->request.ontology].contains(this->request.info))
    //    {
    //        qWarning()<< "Requested info is not in the ontology scope of lastfm service";
    //        emit this->responseReady(this->request, {});
    //        return;
    //    }

    auto url = this->API;

    QUrl encodedArtist(this->request.track[FMH::MODEL_KEY::ARTIST]);
    encodedArtist.toEncoded(QUrl::FullyEncoded);

    switch(this->request.ontology)
    {
        case PULPO::ONTOLOGY::ARTIST:
        {
            url.append("?method=artist.getinfo");
            url.append(KEY);
            url.append("&artist=" + encodedArtist.toString());
            break;
        }

        case PULPO::ONTOLOGY::ALBUM:
        {
            QUrl encodedAlbum(this->request.track[FMH::MODEL_KEY::ALBUM]);
            encodedAlbum.toEncoded(QUrl::FullyEncoded);

            url.append("?method=album.getinfo");
            url.append(KEY);
            url.append("&artist=" + encodedArtist.toString());
            url.append("&album=" + encodedAlbum.toString());
            break;
        }

        case PULPO::ONTOLOGY::TRACK:
        {
            QUrl encodedTrack(this->request.track[FMH::MODEL_KEY::TITLE]);
            encodedTrack.toEncoded(QUrl::FullyEncoded);

            url.append("?method=track.getinfo");
            url.append(KEY);
            url.append("&artist=" + encodedArtist.toString());
            url.append("&track=" + encodedTrack.toString());
            url.append("&format=json");
            break;
        }
    }

    qDebug()<< "[lastfm service]: "<< url;

    this->retrieve(url);
}


void lastfm::parseArtist(const QByteArray &array)
{
    QString xmlData(array);
    QDomDocument doc;

    if (!doc.setContent(xmlData))
    {
        qDebug()<< "LASTFM XML FAILED 1" << this->request.track;
        emit this->responseReady(this->request, this->responses);

        return;
    }

    if (doc.documentElement().toElement().attributes().namedItem("status").nodeValue()!="ok")
    {
        qDebug()<< "LASTFM XML FAILED 2" << this->request.track;
        emit this->responseReady(this->request, this->responses);

        return;
    }


    QStringList artistTags;
    QByteArray artistSimilarArt;
    QStringList artistSimilar;
    QStringList artistStats;

    const QDomNodeList nodeList = doc.documentElement().namedItem("artist").childNodes();

    for (int i = 0; i < nodeList.count(); i++)
    {
        QDomNode n = nodeList.item(i);

        if (n.isElement())
        {
            //Here retrieve the artist image
            if(n.nodeName() == "image" && n.hasAttributes())
            {
                if(this->request.info.contains(INFO::ARTWORK))
                {
                    const auto imgSize = n.attributes().namedItem("size").nodeValue();
                    if (imgSize == "large" && n.isElement())
                    {
                        const auto artistArt_url = n.toElement().text();
                        this->responses << PULPO::RESPONSE {CONTEXT::IMAGE, artistArt_url};

                        if(this->request.info.size() == 1) break;
                        else continue;

                    }else continue;

                }else continue;
            }
        }
    }


    //            //Here retrieve the artist wiki (bio)
    //            if(this->info == INFO::WIKI || this->info == INFO::ALL)
    //            {
    //                if (n.nodeName() == "bio")
    //                {
    //                    auto artistWiki = n.childNodes().item(2).toElement().text();
    //                    //qDebug()<<"Fetching ArtistWiki LastFm[]";

    //                    emit this->infoReady(this->track, this->packResponse(ONTOLOGY::ARTIST, INFO::WIKI,CONTEXT::WIKI,artistWiki));

    //                    if(this->info == INFO::WIKI) return true;
    //                    else continue;
    //                }else if(this->info == INFO::WIKI) continue;
    //            }


    //            //Here retrieve the artist similar artists
    //            if(this->info == INFO::TAGS || this->info == INFO::ALL)
    //            {
    //                if(n.nodeName() == "similar")
    //                {
    //                    auto similarList = n.toElement().childNodes();

    //                    for(int i=0; i<similarList.count(); i++)
    //                    {
    //                        QDomNode m = similarList.item(i);

    //                        auto artistSimilarName = m.childNodes().item(0).toElement().text();
    //                        artistSimilar<<artistSimilarName;
    //                    }

    //                    emit this->infoReady(this->track,this->packResponse(ONTOLOGY::ARTIST, INFO::TAGS,CONTEXT::ARTIST_SIMILAR,artistSimilar));

    //                }else if(n.nodeName() == "tags")
    //                {
    //                    auto tagsList = n.toElement().childNodes();
    //                    //qDebug()<<"Fetching ArtistTags LastFm[]";

    //                    for(int i=0; i<tagsList.count(); i++)
    //                    {
    //                        QDomNode m = tagsList.item(i);
    //                        artistTags<<m.childNodes().item(0).toElement().text();
    //                    }

    //                    emit this->infoReady(this->track,this->packResponse(ONTOLOGY::ARTIST, INFO::TAGS,CONTEXT::TAG,artistTags));


    //                }else if(n.nodeName() == "stats")
    //                {
    //                    QVariant stat;
    //                    auto stats = n.toElement().childNodes();
    //                    //qDebug()<<"Fetching ArtistTags LastFm[]";

    //                    for(int i=0; i<stats.count(); i++)
    //                    {
    //                        QDomNode m = stats.item(i);
    //                        artistStats<<m.toElement().text();
    //                    }

    //                    emit this->infoReady(this->track,this->packResponse(ONTOLOGY::ARTIST, INFO::TAGS, CONTEXT::ARTIST_STAT,artistStats));

    //                }else if(this->info == INFO::TAGS) continue;
    //            }

    //        }
    //    }


    //    /*********NOW WE WANT TO PARSE SIMILAR ARTISTS***********/
    //    if(this->info == INFO::TAGS || this->info == INFO::ALL)
    //    {
    //        auto url = this->API;
    //        QUrl encodedTrack(this->track[FMH::MODEL_KEY::TITLE]);
    //        encodedTrack.toEncoded(QUrl::FullyEncoded);
    //        QUrl encodedArtist(this->track[FMH::MODEL_KEY::ARTIST]);
    //        encodedArtist.toEncoded(QUrl::FullyEncoded);
    //        url.append("?method=artist.getSimilar");
    //        url.append(KEY);
    //        url.append("&artist=" + encodedArtist.toString());
    //        url.append("&format=json");


    //        qDebug()<< "[lastfm service]: "<< url;

    //        this->array = this->startConnection(url);

    //        if(!this->array.isEmpty())
    //            this->parseSimilar();
    //    }

    //    return true;
    emit this->responseReady(this->request, this->responses);

}

void lastfm::parseAlbum(const QByteArray &array)
{
    QString xmlData(array);
    QDomDocument doc;

    if (!doc.setContent(xmlData))
    {
        qDebug()<< "LASTFM XML FAILED 1" << this->request.track;
        emit this->responseReady(this->request, this->responses);

        return;
    }

    if (doc.documentElement().toElement().attributes().namedItem("status").nodeValue()!="ok")
    {
        qDebug()<< "LASTFM XML FAILED 2" << this->request.track;
        emit this->responseReady(this->request, this->responses);

        return;
    }

    const auto nodeList = doc.documentElement().namedItem("album").childNodes();

    for (int i = 0; i < nodeList.count(); i++)
    {
        QDomNode n = nodeList.item(i);

        if (n.isElement())
        {
            //Here retrieve the artist image
            if(n.nodeName() == "image" && n.hasAttributes())
            {
                if(this->request.info.contains(INFO::ARTWORK))
                {
                    const auto imgSize = n.attributes().namedItem("size").nodeValue();

                    if (imgSize == "large" && n.isElement())
                    {
                        const auto albumArt_url = n.toElement().text();
                        this->responses << PULPO::RESPONSE {CONTEXT::IMAGE, albumArt_url};

                        if(this->request.info.size() == 1) break;
                        else continue;

                    }else continue;

                }else continue;
            }

            if (n.nodeName() == "wiki")
            {
                if(this->request.info.contains(INFO::WIKI))
                {
                   const auto albumWiki = n.childNodes().item(1).toElement().text();
                    //qDebug()<<"Fetching AlbumWiki LastFm[]";

                    this->responses << PULPO::RESPONSE {CONTEXT::WIKI, albumWiki};

                    if(this->request.info.size() == 1) break;
                    else continue;

                }else continue;
            }

            if (n.nodeName() == "tags")
            {
                if(this->request.info.contains(INFO::TAGS))
                {
                    auto tagsList = n.toElement().childNodes();
                    QStringList albumTags;
                    for(int i=0; i<tagsList.count(); i++)
                    {
                        QDomNode m = tagsList.item(i);
                        albumTags<<m.childNodes().item(0).toElement().text();
                    }

                    this->responses << PULPO::RESPONSE {CONTEXT::TAG, albumTags};

                    if(this->request.info.size() == 1) break;
                    else continue;

                }else continue;
            }
        }
    }

    emit this->responseReady(this->request, this->responses);
}

//void lastfm::parseTrack(const QByteArray &array)
//{
//QJsonParseError jsonParseError;
//QJsonDocument jsonResponse = QJsonDocument::fromJson(static_cast<QString>(array).toUtf8(), &jsonParseError);

//if (jsonParseError.error != QJsonParseError::NoError)
//return false;

//if (!jsonResponse.isObject())
//return false;

//QJsonObject mainJsonObject(jsonResponse.object());
//auto data = mainJsonObject.toVariantMap();
//auto itemMap = data.value("track").toMap();

//if(itemMap.isEmpty()) return false;

//if(this->info == INFO::TAGS || this->info == INFO::ALL)
//{

//    auto listeners = itemMap.value("listeners").toString();
//    auto playcount = itemMap.value("playcount").toString();
//    QStringList stats = {listeners,playcount};


//    QStringList tags;
//    for(auto tag : itemMap.value("toptags").toMap().value("tag").toList())
//        tags<<tag.toMap().value("name").toString();

//    PULPO::VALUE contexts = {{ CONTEXT::TRACK_STAT,stats},{ CONTEXT::TAG,tags}};

//    emit this->infoReady(this->track, this->packResponse(ONTOLOGY::TRACK, INFO::TAGS, contexts));

//    if(this->info == INFO::TAGS ) return true;
//}

//if(this->info == INFO::METADATA || this->info == INFO::ALL)
//{
//    auto albumTitle = itemMap.value("album").toMap().value("title").toString();
//    auto trackNumber = itemMap.value("album").toMap().value("@attr").toMap().value("position").toString();

//    emit this->infoReady(this->track, this->packResponse(ONTOLOGY::TRACK, INFO::METADATA, {{CONTEXT::TRACK_NUMBER,trackNumber}, {CONTEXT::ALBUM_TITLE,albumTitle}}));

//    if(this->info == INFO::METADATA ) return true;
//}


//if(this->info == INFO::WIKI || this->info == INFO::ALL)
//{
//    auto wiki = itemMap.value("wiki").toMap().value("content").toString();
//    emit this->infoReady(this->track, this->packResponse(ONTOLOGY::TRACK, INFO::WIKI, CONTEXT::WIKI,wiki));
//    if(wiki.isEmpty() && this->info == INFO::WIKI) return false;
//}

//if(this->info == INFO::ARTWORK || this->info == INFO::ALL)
//{
//    auto images = itemMap.value("album").toMap().value("image").toList();

//    QString artwork;

//    for(auto image : images)
//        if(image.toMap().value("size").toString()=="extralarge")
//            artwork = image.toMap().value("#text").toString();


//    emit this->infoReady(this->track, this->packResponse(ONTOLOGY::TRACK, INFO::ARTWORK, CONTEXT::IMAGE,this->startConnection(artwork)));
//    if(artwork.isEmpty() && this->info == INFO::ARTWORK) return false;
//}

//return false;
//}

//void lastfm::parseSimilar()
//{

//QJsonParseError jsonParseError;
//QJsonDocument jsonResponse = QJsonDocument::fromJson(static_cast<QString>(array).toUtf8(), &jsonParseError);

//if (jsonParseError.error != QJsonParseError::NoError)
//return false;

//if (!jsonResponse.isObject())
//return false;

//QJsonObject mainJsonObject(jsonResponse.object());
//auto data = mainJsonObject.toVariantMap();
//auto itemMap = data.value("similarartists").toMap().value("artist");

//if(itemMap.isNull()) return false;

//QList<QVariant> items = itemMap.toList();

//if(items.isEmpty()) return false;


//if(this->info == INFO::TAGS || this->info == INFO::ALL)
//{
//    QStringList artistSimilar;

//    for(auto item : items)
//        artistSimilar<<item.toMap().value("name").toString();

//    emit this->infoReady(this->track, this->packResponse(ONTOLOGY::ARTIST, INFO::TAGS, CONTEXT::ARTIST_SIMILAR,artistSimilar));

//    if(this->info == INFO::TAGS && !artistSimilar.isEmpty() ) return true;
//}

//return false;
//}


