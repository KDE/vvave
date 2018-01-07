import QtQuick.Controls 2.2
import QtQuick 2.9

Pane
{
    property int albumSize : 150
    property int albumSpacing: 20
    property int borderRadius : 4
    property alias gridModel: gridModel
    property alias grid: grid
    signal albumCoverClicked(string album, string artist)

    width: 500
    height: 400

    id: gridPage

    ListModel {id: gridModel}

    GridView
    {
        id: grid

        width: Math.min(model.count, Math.floor(parent.width/cellWidth))*cellWidth
        height: parent.height

        anchors.horizontalCenter: parent.horizontalCenter

        cellWidth: albumSize + albumSpacing
        cellHeight:  parseInt(albumSize+(albumSize*0.6))

        focus: true
        model: gridModel

//        highlight: Rectangle
//        {
//            id: highlight
//            width: albumSize
//            height: albumSize
//            color: "lightsteelblue"
//            radius: borderRadius
//        }

        //        onWidthChanged:
        //        {
        //            var amount = parseInt(grid.width/(albumSize+albumSpacing),10)
        //            var leftSpace = parseInt(grid.width-(amount*albumSize), 10)
        //            var size = parseInt(albumSize+(parseInt(leftSpace/amount, 10)), 10)

        //            size = size > albumSize+albumSpacing ? size : albumSize+albumSpacing

        //            grid.cellWidth = size
        //            //            grid.cellHeight = size
        //        }

        delegate: BabeAlbum
        {
            id: delegate

            Connections
            {
                target: delegate
                onAlbumClicked:
                {
                    var album = grid.model.get(index).album
                    var artist = grid.model.get(index).artist
                    albumCoverClicked(album, artist)
                    grid.currentIndex = index
                    console.log("current index is: ", grid.currentIndex)
                }
            }
        }

//        ScrollBar.vertical: ScrollBar{}
    }

}
