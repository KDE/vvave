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

    property int albumCoverSize: Math.min(180, width * 0.4)

    property int albumCoverRadius :  Maui.Style.radiusV
    property bool albumCardVisible : true

    property alias list: _albumsList
    property alias listModel: _albumsModel

    property alias grid: grid
    property alias holder: grid.holder
    property alias count: grid.count

    signal albumCoverClicked(string album, string artist)
    signal albumCoverPressed(string album, string artist)
    signal bgClicked()

    MouseArea
    {
        anchors.fill: parent
        onClicked: bgClicked()
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
        topMargin: Maui.Style.space.big

        itemSize: albumCoverSize
        holder.visible: count === 0

        model: _albumsModel
        delegate: BabeAlbum
        {
            id: albumDelegate

            albumSize : height * 0.6
            albumRadius: albumCoverRadius
            albumCard: albumCardVisible
            padding: Maui.Style.space.small

            width: grid.cellWidth
            height: width

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
