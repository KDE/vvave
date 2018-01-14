import QtQuick 2.9
import "../view_models"
import "../db/Queries.js" as Q

BabeTable
{
    id: tracksViewTable
    trackNumberVisible: false
    function populate()
    {
        var map = bae.get(Q.Query.allTracks)
        for(var i in map)
            tracksViewTable.model.append(map[i])
    }

    Component.onCompleted: populate()
}


