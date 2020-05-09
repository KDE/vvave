import QtQuick.Controls 2.10
import QtQuick 2.10
import ".."
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import AlbumsList 1.0

Maui.Page
{
    id: control
    property int albumCoverSize: 130
    property int albumCoverRadius :  Maui.Style.radiusV

    property alias list: _albumsList
    property alias listModel: _albumsModel

    property alias grid: grid
    property alias holder: grid.holder
    property alias count: grid.count

    signal albumCoverClicked(string album, string artist)
    signal albumCoverPressed(string album, string artist)
    signal bgClicked()

    flickable: grid.flickable

    MouseArea
    {
        anchors.fill: parent
        onClicked: bgClicked()
    }

    Albums
    {
        id: _albumsList
    }

    Maui.BaseModel
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

        itemSize: Math.min(albumCoverSize, Math.max(60, control.width* 0.3))
        holder.visible: count === 0

        model: _albumsModel
        delegate: Item
        {
            id: _albumDelegate
            height: grid.cellHeight
            width: grid.cellWidth

            property bool isCurrentItem: GridView.isCurrentItem

            BabeAlbum
            {
                id: albumDelegate
                anchors.centerIn: parent
                albumRadius: albumCoverRadius
                padding: Maui.Style.space.small
                height: grid.itemSize
                width: height
                isCurrentItem: _albumDelegate.isCurrentItem

                label1.text: model.album ? model.album : model.artist
                label2.text: model.artist && model.album ? model.artist : ""
                image.source:  model.artwork ?  model.artwork : "qrc:/assets/cover.png"

                Connections
                {
                    target: albumDelegate
                    onClicked:
                    {
                        grid.currentIndex = index
                        if(Maui.Handy.singleClick)
                        {
                            const album = _albumsList.get(index).album
                            const artist = _albumsList.get(index).artist
                            albumCoverClicked(album, artist)
                        }
                    }

                    onDoubleClicked:
                    {
                        grid.currentIndex = index
                        if(!Maui.Handy.singleClick)
                        {
                            const album = _albumsList.get(index).album
                            const artist = _albumsList.get(index).artist
                            albumCoverClicked(album, artist)
                        }
                    }

                    onPressAndHold:
                    {
                        const album = grid.model.get(index).album
                        const artist = grid.model.get(index).artist
                        albumCoverPressed(album, artist)
                    }
                }
            }
        }
    }
}
