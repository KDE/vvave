import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.maui.vvave 1.0

import "../../view_models"
import "../../utils/Player.js" as Player
import "../../db/Queries.js" as Q

Maui.Dialog
{
    id: control
    property var tracks : []
    maxHeight: 400 * Maui.Style.unit
    page.margins: 0
    acceptButton.text: i18n("Save")
    rejectButton.text: i18n("Cancel")

    headBar.visible: true
    headBar.middleContent: Maui.TextField
    {
        id: newPlaylistField

        Layout.fillWidth: true
        color: Kirigami.Theme.textColor
        placeholderText: i18n("New playlist")
        onAccepted:
        {
            const playlist = text
            control.addPlaylist(playlist)
            control.insert(playlist, control.tracks)
        }

        actions.data: ToolButton
        {
            icon.name: "checkbox"
            enabled: newPlaylistField.text.length
            icon.color: Kirigami.Theme.textColor
            onClicked: control.addPlaylist(newPlaylistField.text)
        }
    }

    BabeList
    {
        id: dialogList

        Layout.fillHeight: true
        Layout.fillWidth: true

        headBar.visible: false
        holder.title: i18n("There's not playlists")
        holder.body: i18n("Create a new one and start adding tracks to it")

        model: Maui.BaseModel
        {
            id: _playlistsModel
            list: playlistsList
        }

        delegate: Maui.ListDelegate
        {
            id: delegate
            label: model.playlist
            iconName: model.icon
            iconSize: Maui.Style.iconSizes.small
            enabled: model.type === "personal"
            onClicked: enabled ? dialogList.currentIndex = index : -1
        }
    }

    onRejected: control.close()
    onAccepted:
    {
        if(newPlaylistField.text.length)
            control.addPlaylist(newPlaylistField.text)
        control.insert(_playlistsModel.get(dialogList.currentIndex).playlist, control.tracks)
    }

    function insert(playlist, urls)
    {
        playlistsList.addTrack(playlist, urls)
        control.close()
    }

    function addPlaylist(playlist)
    {
        var title = newPlaylistField.text.trim()
        if(playlistsList.insert(title))
        {
            dialogList.currentIndex = dialogList.count -1
            dialogList.listView.positionViewAtEnd()
        }

        newPlaylistField.clear()
    }
}
