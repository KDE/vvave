import QtQuick 2.9
import "../view_models/BabeTable"
import "../db/Queries.js" as Q

BabeTable
{
    id: searchTable
    property var searchRes
    trackNumberVisible: false
    headerBar: true
    headerClose: true
    holder.message: "No search results!"
    coverArtVisible: true
    trackDuration: true
    trackRating: true
    function populate(tracks)
    {
        searchTable.clearTable()
        for(var i in tracks)
            searchTable.model.append(tracks[i])
    }
    Rectangle
    {
        anchors.fill: parent
        color: bae.altColor()
        z: -999
    }

    Component.onCompleted: populate()
}


