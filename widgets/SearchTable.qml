import QtQuick 2.9
import "../view_models"
import "../db/Queries.js" as Q

BabeTable
{
    id: searchTable
    trackNumberVisible: false
    function populate(tracks)
    {
        searchTable.clearTable()
        for(var i in tracks)
            searchTable.model.append(tracks[i])
    }

    Component.onCompleted: populate()
}


