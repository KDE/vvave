import QtQuick.Controls 2.2
import QtQuick 2.9

Pane
{
    property int albumSize : 150
    property int albumSpacing: 20
    property int borderRadius : 4
    property alias gridModel: gridModel
    signal albumCoverClicked(string album, string artist)

    width: 500
    height: 400

    ListModel
    {
        id: gridModel
    }

    GridView
    {
        id: grid

        //        anchors.leftMargin: gridMargin
        width: Math.min(model.count, Math.floor(parent.width/cellWidth))*cellWidth
        height: parent.height

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20

        cellWidth: albumSize+albumSpacing
        cellHeight:  parseInt(albumSize+(albumSize*0.6))
        focus: true
        model: gridModel
        highlight: Rectangle
        {
            id: highlight
            width: albumSize;
            height: albumSize;
            color: "lightsteelblue"
            radius: borderRadius
        }

        onWidthChanged:
        {
//            var amount = parseInt(grid.width/(albumSize+albumSpacing),10)
//            var leftSpace = parseInt(grid.width-(amount*albumSize), 10)
//            var size = parseInt(albumSize+(parseInt(leftSpace/amount, 10)), 10)

//            size = size > albumSize+albumSpacing ? size : albumSize+albumSpacing

//            grid.cellWidth = size
//            //            grid.cellHeight = size

//            console.log(parseInt(size,10))
        }

        delegate: BabeAlbum
        {
            id: delegate
            albumSize: albumSize
            borderRadius: borderRadius

            Connections
            {
                target: delegate
                onAlbumClicked:
                {
                    var album = grid.model.get(index).album
                    var artist = grid.model.get(index).artist
                    albumCoverClicked(album, artist)
                }

            }
        }

    }
}
