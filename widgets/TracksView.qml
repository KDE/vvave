import QtQuick 2.9
import org.kde.maui 1.0 as Maui
import "../view_models/BabeTable"
import "../view_models"
import "../db/Queries.js" as Q

BabeTable
{
    id: tracksViewTable
    trackNumberVisible: false
    trackDuration: true
    trackRating: true
    headBarVisible: true
    headBarTitle: count + " tracks"
    headBarExit: false
    coverArtVisible: false
    sortBy: "album"

    function populate()
    {
        var map = bae.get(Q.GET.allTracks)

        if(map.length > 0)
            for(var i in map)
                tracksViewTable.model.append(map[i])
    }
}


