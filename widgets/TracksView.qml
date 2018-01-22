import QtQuick 2.9
import "../view_models"
import "../db/Queries.js" as Q

BabeTable
{
    id: tracksViewTable
    trackNumberVisible: false
    trackDuration: true
    trackRating: true
    headerBar: true
    headerTitle: count + " tracks"
    coverArtVisible: false

    function populate()
    {
        var map = bae.get(Q.Query.allTracks)
        for(var i in map)
            tracksViewTable.model.append(map[i])
    }

    Rectangle
    {
        anchors.fill: parent
        color: bae.altColor()
        z: -999
    }

    Component.onCompleted: populate()
}


