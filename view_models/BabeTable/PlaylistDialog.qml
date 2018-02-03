import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami

import "../../view_models/BabeDialog"
import "../../view_models"

BabeDialog
{
    title: "Add "+ tracks.length +" tracks to..."
    standardButtons: Dialog.Save | Dialog.Cancel
    width: isMobile ? parent.width*0.7 : parent.width*0.4
    height: parent.height*0.5

    property var tracks : []

    Column
    {
        anchors.fill: parent

        BabeList
        {
            id: playlistsList
            width: parent.width
            height: parent.height
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
                    onClicked:
                    {
                        playlistsList.currentIndex = index
                    }
                }
            }

            Component.onCompleted:
            {
                var playlists = bae.get("select * from playlists order by addDate desc")
                if(playlists.length > 0)
                    for(var i in playlists)
                        playlistsList.model.append(playlists[i])
            }

        }
    }

    onAccepted: addToPlaylist(tracks)

    function addToPlaylist(tracks)
    {
        if(tracks.length > 0)
            for(var i in tracks)
                bae.trackPlaylist(tracks[i], playlistsList.model.get(playlistsList.currentIndex).playlist)
    }
}
