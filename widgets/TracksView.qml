import QtQuick 2.9
import "../view_models"


BabeTable
{
    id: tracksViewTable
    trackNumberVisible: false

    function populate()
    {
        var map = con.get("select * from tracks")
        for(var i in map)
            tracksViewTable.model.append(map[i])
    }

    Component.onCompleted: populate()
}


