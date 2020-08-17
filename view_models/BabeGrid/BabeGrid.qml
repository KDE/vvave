import QtQuick.Controls 2.14
import QtQuick 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

import org.maui.vvave 1.0

import ".."

Maui.Page
{
    id: control
    property int albumCoverSize: 130
    property int albumCoverRadius :  Maui.Style.radiusV

    property alias list: _albumsList
    property alias listModel: _albumsModel

    property alias grid: grid
    property alias holder: grid.holder
    readonly property int count: grid.currentView.count

    signal albumCoverClicked(string album, string artist)
    signal albumCoverPressed(string album, string artist)

    flickable: grid.flickable

    headBar.visible: true
    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        placeholderText: i18n("Filter")
        onAccepted: _albumsModel.filter = text
        onCleared: _albumsModel.filter = ""
    }

    Maui.AltBrowser
    {
        id: grid
        anchors.fill: parent
        viewType: root.isWide ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List

        gridView.topMargin: Maui.Style.contentMargins
        listView.topMargin: Maui.Style.contentMargins
        listView.spacing: Maui.Style.space.medium

        gridView.itemSize: Math.min(albumCoverSize, Math.max(100, control.width* 0.3))
        holder.visible: count === 0

        model: Maui.BaseModel
        {
            id: _albumsModel
            recursiveFilteringEnabled: true
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive
            list: Albums
            {
                id: _albumsList
            }
        }

        listDelegate: Maui.ItemDelegate
        {
            isCurrentItem: ListView.isCurrentItem
            width: parent.width
            height: Maui.Style.rowHeight * 1.8
            leftPadding: Maui.Style.space.small
            rightPadding: Maui.Style.space.small

            Maui.ListItemTemplate
            {
                anchors.fill: parent
                spacing: Maui.Style.space.medium
                label1.text: model.album ? model.album : model.artist
                label2.text: model.artist && model.album ? model.artist : ""
                imageSource:  model.artwork ?  model.artwork : "qrc:/assets/cover.png"
                iconSizeHint: height * 0.9
            }

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

        gridDelegate: Item
        {
            id: _albumDelegate
            height: grid.gridView.cellHeight
            width: grid.gridView.cellWidth

            property bool isCurrentItem: GridView.isCurrentItem

            BabeAlbum
            {
                id: albumDelegate
                anchors.centerIn: parent
                albumRadius: albumCoverRadius
                padding: Maui.Style.space.small
                height: grid.gridView.itemSize
                width: height
                isCurrentItem: _albumDelegate.isCurrentItem

                label1.text: model.album ? model.album : model.artist
                label2.text: model.artist && model.album ? model.artist : ""
                image.source:  model.artwork ?  model.artwork : "qrc:/assets/cover.png"

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
