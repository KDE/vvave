import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.8 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.vvave 1.0 as Vvave

Maui.AltBrowser
{
    id: control

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    viewType: root.isWide ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List

    gridView.itemSize: 140
    gridView.itemHeight: 180

    holder.emoji:  "qrc:/assets/dialog-information.svg"
    holder.title : i18n("No Playlists!")
    holder.body: i18n("Start creating new custom playlists")

    holder.emojiSize: Maui.Style.iconSizes.huge
    holder.visible: count === 0

    model: Maui.BaseModel
    {
        id: _playlistsModel
        list: Vvave.Playlists
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    footBar.visible: false
    headBar.forceCenterMiddleContent: false
    headBar.middleContent: Maui.TextField
    {
        Layout.maximumWidth: 500
        Layout.fillWidth: true
        placeholderText: i18n("Filter")
        onAccepted: _playlistsModel.filter = text
        onCleared: _playlistsModel.filter = ""
    }

    headBar.rightContent: ToolButton
    {
        icon.name: "list-add"
        onClicked:
        {
            newPlaylistDialog.open()
        }
    }

    listDelegate: Maui.ListBrowserDelegate
    {
        width: ListView.view.width
        height: Maui.Style.rowHeight * 1.8

        isCurrentItem: ListView.isCurrentItem

        label1.font.bold: true
        label1.font.weight: Font.Bold
        label1.text: model.playlist
        label1.horizontalAlignment: Qt.AlignLeft
        label2.horizontalAlignment: Qt.AlignLeft
        iconSource: model.icon

        onClicked :
        {
            control.currentIndex = index
            if(Maui.Handy.singleClick)
            {
                populate(model.playlist, true)
            }
        }

        onDoubleClicked :
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick)
            {
                populate(model.playlist, true)
            }
        }

        onRightClicked:
        {
            control.currentIndex = index
            currentPlaylist = model.playlist
        }

        onPressAndHold:
        {
            control.currentIndex = index
        }
    }

    gridDelegate : Item
    {
        height: GridView.view.cellHeight
        width: GridView.view.cellWidth

        Maui.GalleryRollItem
        {
            id: _collageDelegate
            anchors.fill: parent
            anchors.margins: Kirigami.Settings.isMobile ? Maui.Style.space.small : Maui.Style.space.medium
            orientation: Qt.Vertical
            imageWidth: 120
            imageHeight: 120

            isCurrentItem: parent.GridView.isCurrentItem
            images: model.preview.split(",")

            label1.font.bold: true
            label1.font.weight: Font.Bold
            label1.text: model.playlist
            iconSource: model.icon
            template.labelSizeHint: 24

            onClicked :
            {
                control.currentIndex = index
                if(Maui.Handy.singleClick)
                {
                    populate(model.playlist, true)
                }
            }

            onDoubleClicked :
            {
                control.currentIndex = index
                if(!Maui.Handy.singleClick)
                {
                    populate(model.playlist, true)
                }
            }

            onRightClicked:
            {
                control.currentIndex = index
                currentPlaylist = model.playlist
            }

            onPressAndHold:
            {
                control.currentIndex = index
                currentPlaylist = model.playlist
            }
        }
    }
}
