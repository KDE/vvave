import QtQuick 2.0

import "../../view_models"
import "../../db/Queries.js" as Q

BabePopup
{
    id: searchSuggestionsRoot
    property alias model : suggestionsList.model

    leftPadding: 1
    rightPadding: 1
    topPadding: contentMargins
    bottomPadding: contentMargins

    BabeList
    {
        id: suggestionsList
        anchors.fill: parent
        headerBarVisible: false
        model: ListModel {id: suggestionsModel}

        delegate: BabeDelegate
        {
            id: delegate
            label: suggestion

            Connections
            {
                target: delegate

                onClicked:
                {
                    suggestionsList.currentIndex = index
                    runSearch(suggestionsList.model.get(index).suggestion)
                    close()
                }
            }
        }
    }

    onOpened: updateSuggestions()

    function updateSuggestions()
    {
        suggestionsList.clearTable()

        var qq = bae.loadSetting("QUERIES", "BABE", {})
        savedQueries = qq.split(",")

        if(searchInput.text.length>3 && searchInput.text.indexOf(":") < 0)
        {
            //            var similar = bae.get('select distinct * from tracks where title LIKE "%'+searchInput.text+'%" or artist LIKE "%'+searchInput.text+'%" or album LIKE "%'+searchInput.text+'%" limit 5')

            var similarArtist = bae.get('select distinct * from tracks where artist LIKE "%'+searchInput.text+'%" limit 3')
            var similarAlbum= bae.get('select distinct * from tracks where album LIKE "%'+searchInput.text+'%" limit 3')
            var similarTracks = bae.get('select distinct * from tracks where title LIKE "%'+searchInput.text+'%" limit 3')

            var checkList = []


            for(var i in similarArtist)
                if(checkList.indexOf("artist: "+similarArtist[i].artist) < 0)
                {
                    checkList.push("artist: "+similarArtist[i].artist)
                    suggestionsList.model.append({suggestion: "artist: "+similarArtist[i].artist})
                }

            for(i in similarAlbum)
                if(checkList.indexOf("album: "+similarAlbum[i].album) < 0)
                {
                    checkList.push("album: "+similarAlbum[i].album)
                    suggestionsList.model.append({suggestion: "album: "+similarAlbum[i].album})
                }

            for(i in similarTracks)
                if(checkList.indexOf("title: "+similarTracks[i].title) < 0)
                {
                    checkList.push("title: "+similarTracks[i].title)
                    suggestionsList.model.append({suggestion: "title: "+similarTracks[i].title})
                }
        }

        if(savedQueries.length>0)
            for(i=0; i < 3; i++)
                if(i < savedQueries.length )
                    suggestionsList.model.append({suggestion: savedQueries[i]})

    }
}
