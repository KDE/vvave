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

Maui.Page
{
    id: control

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

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

        //        itemSize: Math.min(260, Math.max(140, Math.floor(width* 0.3)))
        itemSize: 160
        itemHeight: itemSize

        holder.emoji:  "qrc:/assets/dialog-information.svg"
        holder.title : i18n("No Playlists!")
        holder.body: i18n("Start creating new custom playlists")

        holder.emojiSize: Maui.Style.iconSizes.huge
        holder.visible: _gridView.count === 0

        model: Maui.BaseModel
        {
            id: _playlistsModel
            list: Vvave.Playlists
            recursiveFilteringEnabled: true
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        delegate : Item
        {
            height: GridView.view.cellHeight
            width: GridView.view.cellWidth

            Maui.GalleryRollItem
            {
                id: _collageDelegate
                anchors.fill: parent
                anchors.margins: Maui.Style.space.medium

                isCurrentItem: parent.GridView.isCurrentItem
                images: model.preview.split(",")

                label1.font.bold: true
                label1.font.weight: Font.Bold
                label1.text: model.playlist
                label1.horizontalAlignment: Qt.AlignLeft
                label2.horizontalAlignment: Qt.AlignLeft
                label2.text: model.description
                iconSource: model.icon

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
}
