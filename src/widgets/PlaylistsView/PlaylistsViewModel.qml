import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import org.kde.kirigami 2.8 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.vvave 1.0 as Vvave

import "../../utils"

import "../../view_models"
import "../../widgets"
import "../../db/Queries.js" as Q
import "../../utils/Help.js" as H

Maui.AltBrowser
{
    id: control

    anchors.fill: parent

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    viewType: root.isWide ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List

    gridView.itemSize: 130
    gridView.itemHeight: 130 * 1.5

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
        label2.text: model.description
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
            anchors.centerIn: parent
            width: control.gridView.itemSize - Maui.Style.space.medium
            height:control.gridView.itemHeight  - Maui.Style.space.medium

            isCurrentItem: parent.GridView.isCurrentItem
            images: model.preview.split(",")

            label1.font.bold: true
            label1.font.weight: Font.Bold
            label1.text: model.playlist
            label1.horizontalAlignment: Qt.AlignLeft
            label2.horizontalAlignment: Qt.AlignLeft
            label2.text: model.description
            iconSource: model.icon
            template.labelSizeHint: 40

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
