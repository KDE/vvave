import QtQuick.Controls 2.2
import QtQuick 2.9
import ".."

Pane
{
    id: gridPage
    padding: 20
    readonly property int screenSize : bae.screenGeometry("width")*bae.screenGeometry("height");

    property int albumSize:
    {
        if(!isMobile)
        {
            Math.sqrt(screenSize)*0.15
        }else
        {

            var hintSize = Math.sqrt(root.width*root.height)*0.25

            if(hintSize > 150)
                150
            else
                hintSize
        }
    }
    property int albumSpacing: 20
    property int albumRadius : 0
    property bool albumCardVisible : true
    property alias gridModel: gridModel
    property alias grid: grid
    signal albumCoverClicked(string album, string artist)
    signal albumCoverPressed(string album, string artist)
    signal bgClicked()

    width: 500
    height: 400


    background: Rectangle
    {
        anchors.fill: parent
        color: bae.altColor()
        z: -999
    }

    function clearGrid()
    {
        gridModel.clear()
    }

    MouseArea
    {
        anchors.fill: parent
        onClicked: bgClicked()
    }

    BabeHolder
    {
        visible: grid.count === 0
        message: "No albums..."
    }

    ListModel {id: gridModel}

    GridView
    {
        id: grid

        MouseArea
        {
            anchors.fill: parent
            onClicked: bgClicked()
            z: -999
        }

        width: Math.min(model.count, Math.floor(parent.width/cellWidth))*cellWidth
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        cellWidth: albumSize +(albumSize*0.2)
        cellHeight:  albumSize+(albumSize*0.8)
        highlightFollowsCurrentItem: false

        focus: true
        boundsBehavior: Flickable.StopAtBounds

        flickableDirection: Flickable.AutoFlickDirection

        snapMode: GridView.SnapToRow
        //        flow: GridView.FlowTopToBottom
        //        maximumFlickVelocity: albumSize*8

        model: gridModel


        //        highlight: Rectangle
        //        {
        //            id: highlight
        //            width: albumSize
        //            height: albumSize
        //            color: myPalette.highlight
        //            radius: 4
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
            id: albumDelegate

            albumSize : gridPage.albumSize
            albumRadius: gridPage.albumRadius
            albumCard: albumCardVisible
            Connections
            {
                target: albumDelegate
                onAlbumClicked:
                {
                    var album = grid.model.get(index).album
                    var artist = grid.model.get(index).artist
                    albumCoverClicked(album, artist)
                    grid.currentIndex = index
                }

                onAlbumPressed:
                {
                    var album = grid.model.get(index).album
                    var artist = grid.model.get(index).artist
                    albumCoverPressed(album, artist)
                }
            }
        }

        ScrollBar.vertical:BabeScrollBar { visible: true }
    }

}
