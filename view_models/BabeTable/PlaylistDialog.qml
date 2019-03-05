import QtQuick 2.0
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3

import "../../view_models"
import "../../utils/Player.js" as Player
import "../../db/Queries.js" as Q

Maui.Dialog
{
    title: "Add "+ tracks.length +" tracks to..."

    property var tracks : []
    maxHeight: 400 * unit

    ColumnLayout
    {
        anchors.fill: parent

        BabeList
        {
            id: playlistsList

            Layout.fillHeight: true
            Layout.fillWidth: true

            headBar.visible: false
            holder.title: qsTr("There's not playlists")
            holder.body: qsTr("Create a new one and start adding tracks to it")

            model: playlistsView.playlistModel

            delegate: Maui.LabelDelegate
            {
                id: delegate
                label: model.playlist

                Connections
                {
                    target: delegate
                    onClicked: playlistsList.currentIndex = index
                    onPressAndHold:
                    {
                        playlistsList.currentIndex = index
                        insert()
                    }
                }
            }
        }

        RowLayout
        {
            Layout.fillWidth: true

            Maui.TextField
            {
                Layout.fillWidth: true
                id: newPlaylistField
                color: textColor
                placeholderText: qsTr("New playlist")
                onAccepted:
                {
                    addPlaylist()
                    playlistsView.playlistList.addTrack(playlistsList.listView.currentIndex, tracks)
                    clear()
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

    onAccepted:
    {
        if(newPlaylistField.text.length)
            addPlaylist()

        insert()
    }


    function insert()
    {
        playlistsView.playlistList.addTrack(playlistsList.listView.currentIndex, tracks)
        close()
    }

    function addPlaylist()
    {
        if (newPlaylistField.text)
        {
            var title = newPlaylistField.text.trim()
            if( playlistsView.playlistList.insertAt(title, 0))
            {
                playlistsList.listView.currentIndex = 0
                playlistsList.listView.positionViewAtBeginning()
            }

            newPlaylistField.clear()
        }
    }

}
