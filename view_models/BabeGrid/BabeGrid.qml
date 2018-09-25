import QtQuick.Controls 2.2
import QtQuick 2.9
import ".."
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: gridPage
    //    readonly property int screenSize : bae.screenGeometry("width")*bae.screenGeometry("height");
    //    property int hintSize : Math.sqrt(root.width*root.height)*0.3

    property int albumCoverSize: iconSizes.enormous
    readonly property int albumSpacing: albumCoverSize * 0.3 + space.small

    property int albumCoverRadius :  Kirigami.Units.devicePixelRatio * 6
    property bool albumCardVisible : true
    property alias gridModel: gridModel
    property alias grid: grid
    property alias holder: holder

    signal albumCoverClicked(string album, string artist)
    signal albumCoverPressed(string album, string artist)
    signal bgClicked()

    margins: space.medium
    topMargin: space.big

    onWidthChanged: grid.forceLayout()

    function clearGrid()
    {
        gridModel.clear()
    }

    MouseArea
    {
        anchors.fill: parent
        onClicked: bgClicked()
    }

    Maui.Holder
    {
        id: holder
        visible: grid.count === 0
    }

    ListModel {id: gridModel}

    Maui.GridView
    {
        id: grid
        onAreaClicked: bgClicked()
        adaptContent: true
        width: parent.width
        height: parent.height

        itemSize: albumCoverSize
        spacing: albumSpacing

        cellWidth: albumCoverSize + spacing
        cellHeight:  albumCoverSize + spacing*2

        model: gridModel
        delegate: BabeAlbum
        {
            id: albumDelegate

            albumSize : albumCoverSize
            albumRadius: albumCoverRadius
            albumCard: albumCardVisible

            height: grid.cellHeight
            width: grid.cellWidth

            Connections
            {
                target: albumDelegate
                onClicked:
                {
                    var album = grid.model.get(index).album
                    var artist = grid.model.get(index).artist
                    albumCoverClicked(album, artist)
                    grid.currentIndex = index
                }

                onPressAndHold:
                {
                    var album = grid.model.get(index).album
                    var artist = grid.model.get(index).artist
                    albumCoverPressed(album, artist)
                }
            }
        }
    }
}
