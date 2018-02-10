import QtQuick 2.9
import "../view_models/BabeTable"
import "../db/Queries.js" as Q

BabeTable
{
    id: tracksViewTable
    trackNumberVisible: false
    trackDuration: true
    trackRating: true
    headerBarVisible: true
    headerBarTitle: count + " tracks"
    headerBarExit: false
    coverArtVisible: false

    function populate()
    {
        var map = bae.get(Q.GET.allTracks)

        if(map.length > 0)
            for(var i in map)
                tracksViewTable.model.append(map[i])
    }

    Rectangle
    {
        anchors.fill: parent
        color: altColor
        z: -999
    }

    Component.onCompleted: populate()
}


