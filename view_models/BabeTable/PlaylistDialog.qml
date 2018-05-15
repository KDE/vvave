import QtQuick 2.0
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.maui 1.0 as Maui
import QtQuick.Layouts 1.3

import "../../view_models/BabeDialog"
import "../../view_models"
import "../../utils/Player.js" as Player
import "../../db/Queries.js" as Q

BabeDialog
{
    title: "Add "+ tracks.length +" tracks to..."
    standardButtons: Dialog.Save | Dialog.Cancel

    property var tracks : []

    ColumnLayout
    {
        spacing: space.small
        anchors.fill: parent

        BabeList
        {
            id: playlistsList

            Layout.fillHeight: true
            Layout.fillWidth: true

            headBarVisible: false
            holder.message: "<h2>There's not playlists</h2><br><p>Create a new one and start adding tracks to it<p/>"
            ListModel { id: listModel }
            model: listModel

            delegate: BabeDelegate
            {
                id: delegate
                label: playlist

                Connections
                {
                    target: delegate
                    onClicked: playlistsList.currentIndex = index
                    onPressAndHold:
                    {
                        playlistsList.currentIndex = index
                        Player.addToPlaylist(tracks, playlistsList.model.get(playlistsList.currentIndex).playlist)
                        close()
                    }
                }
            }
        }

        RowLayout
        {
            Layout.fillWidth: true
            Layout.margins: space.small

            TextField
            {
                Layout.fillWidth: true
                width: parent.width
                id: newPlaylistField
                color: textColor
                placeholderText: qsTr("New playlist")
                onAccepted:
                {
                    addPlaylist()
                    clear()
                    close()
                }
            }

            Maui.ToolButton
            {
                iconName: "checkbox"
                iconColor: textColor
                onClicked: addPlaylist()

            }
        }

    }

    onOpened:
    {
        newPlaylistField.clear()
        playlistsList.clearTable()
        var playlists = bae.get(Q.GET.playlists)
        if(playlists.length > 0)
            for(var i in playlists)
                playlistsList.model.append(playlists[i])

//        newPlaylistField.forceActiveFocus()
    }

    onAccepted:
    {
        if(newPlaylistField.text && newPlaylistField.text.length > 0)
        {
            addPlaylist()
            Player.addToPlaylist(tracks,newPlaylistField.text.trim())
        }
        else
            Player.addToPlaylist(tracks, playlistsList.model.get(playlistsList.currentIndex).playlist)

    }

    function addPlaylist()
    {
        if (newPlaylistField.text)
        {
            var title = newPlaylistField.text.trim()
            if(bae.addPlaylist(title))
            {
                playlistsList.model.insert(0, {playlist: title})
                playlistsView.playlistViewModel.model.insert(9, {playlist: title})
                playlistsList.list.positionViewAtBeginning()
            }

            newPlaylistField.clear()
        }
    }

}
