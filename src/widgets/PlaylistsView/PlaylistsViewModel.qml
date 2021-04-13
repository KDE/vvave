import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.12

import org.kde.kirigami 2.8 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.vvave 1.0

import "../../utils"

import "../../view_models"
import "../../widgets"
import "../../db/Queries.js" as Q
import "../../utils/Help.js" as H

Maui.Page
{
    id: control

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

    Maui.GridView
    {
        id: _gridView

        anchors.fill: parent

        itemSize: Math.min(260, Math.max(140, Math.floor(width* 0.3)))
        itemHeight: itemSize

        holder.emoji:  "qrc:/assets/dialog-information.svg"
        holder.title : i18n("No Playlists!")
        holder.body: i18n("Start creating new custom playlists")

        holder.emojiSize: Maui.Style.iconSizes.huge
        holder.visible: _gridView.count === 0

        model: Maui.BaseModel
        {
            id: _playlistsModel
            list: playlistsList
            recursiveFilteringEnabled: true
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        delegate : Maui.GalleryRollItem
        {
            id: _collageDelegate
            height: _gridView.cellHeight
            width: _gridView.cellWidth

            isCurrentItem: GridView.isCurrentItem
            images: model.preview.split(",")

            label1.text: model.playlist
            label2.text: model.description
            template.iconSource: model.icon

            onClicked :
            {
                _gridView.currentIndex = index
                if(Maui.Handy.singleClick)
                {
                    populate(model.playlist, true)
                }
            }

            onDoubleClicked :
            {
                _gridView.currentIndex = index
                if(!Maui.Handy.singleClick)
                {
                    populate(model.playlist, true)
                }
            }

            onRightClicked:
            {
                _gridView.currentIndex = index
                currentPlaylist = model.playlist
            }

            onPressAndHold:
            {
                _gridView.currentIndex = index
                currentPlaylist = model.playlist
            }
        }
    }
}
