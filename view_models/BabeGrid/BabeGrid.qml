import QtQuick.Controls 2.2
import QtQuick 2.9
import ".."
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

import BaseModel 1.0
import AlbumsList 1.0

Maui.Page
{
    id: gridPage
    //    readonly property int screenSize : bae.screenGeometry("width")*bae.screenGeometry("height");
    //    property int hintSize : Math.sqrt(root.width*root.height)*0.3

    property int albumCoverSize: Math.min(120, width * 0.3)
    readonly property int albumSpacing: albumCoverSize * 0.3 + space.small

    property int albumCoverRadius :  radiusV
    property bool albumCardVisible : true

    property alias list: _albumsList
    property alias listModel: _albumsModel

    property alias grid: grid
    property alias holder: holder
    property alias count: grid.count

    signal albumCoverClicked(string album, string artist)
    signal albumCoverPressed(string album, string artist)
    signal bgClicked()

//    margins: space.medium
//    topMargin: space.big

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

    Albums
    {
        id: _albumsList
    }

    BaseModel
    {
        id: _albumsModel
        list: _albumsList
    }

    Maui.GridView
    {
        id: grid
        onAreaClicked: bgClicked()
        adaptContent: true
        anchors.fill: parent
        anchors.topMargin: space.big

        itemSize: albumCoverSize
        spacing: albumSpacing

        cellWidth: albumCoverSize + spacing
        cellHeight:  albumCoverSize + spacing*2

        model: _albumsModel
        delegate: BabeAlbum
        {
            id: albumDelegate

            albumSize : grid.itemSize
            albumRadius: albumCoverRadius
            albumCard: albumCardVisible

            height: grid.cellHeight
            width: grid.cellWidth

            Connections
            {
                target: albumDelegate
                onClicked:
                {
                    var album = _albumsList.get(index).album
                    var artist = _albumsList.get(index).artist
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
