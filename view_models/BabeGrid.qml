import QtQuick.Controls 2.2
import QtQuick 2.9

Pane
{
    property int albumSize : 150
    property int albumSpacing: 20
    property int borderRadius : 4

    signal albumCoverClicked(string album, string artist)

    width: 500
    height: 400

    ListModel
    {
        id: appModel
        ListElement { album: "Continium"; artist:"John Mayer"; icon: "qrc:/assets/cover.png" }
        ListElement { album: "Channel Orange"; artist: "Frank Ocean"; icon: "qrc:/assets/cover.png" }
        ListElement { album: "Coloring Book"; artist: "Chance the Rapper"; icon: "qrc:/assets/cover.png" }
        ListElement { album: "The Lonely Hour"; artist: "Sam Smith"; icon: "qrc:/assets/cover.png" }
        ListElement { artist: "Sam Smith"; icon: "qrc:/assets/cover.png" }
        ListElement { album: "Lil Empire"; artist: "Petite Meller"; icon: "qrc:/assets/cover.png" }
        ListElement { album: "Lost Generation"; artist: "Unkown";icon: "qrc:/assets/cover.png" }
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
        model: appModel
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
            var amount = parseInt(grid.width/(albumSize+albumSpacing),10)
            var leftSpace = parseInt(grid.width-(amount*albumSize), 10)
            var size = parseInt(albumSize+(parseInt(leftSpace/amount, 10)), 10)

            size = size > albumSize+albumSpacing ? size : albumSize+albumSpacing

            grid.cellWidth = size
            //            grid.cellHeight = size

            console.log(parseInt(size,10))
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
