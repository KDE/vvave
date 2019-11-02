import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.10
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import PlaylistsList 1.0
import TracksList 1.0

import "../../utils"

import "../../view_models"
import "../../db/Queries.js" as Q
import "../../utils/Help.js" as H

BabeList
{
    id: control

    signal playSync(int index)
    topPadding: Maui.Style.contentMargins

    Maui.NewDialog
    {
        id: newPlaylistDialog
        title: qsTr("New Playlist...")
        onFinished: addPlaylist(text)
        acceptText: qsTr("Create")
        rejectButton.visible: false
    }

    headBar.leftContent:  [

        ToolButton
        {
            id : createPlaylistBtn
            text: qsTr("Add")
            icon.name : "list-add"
            onClicked: newPlaylistDialog.open()
        },

        ToolButton
        {
            text: qsTr("Remove")
            icon.name: "list-remove"
            onClicked: removePlaylist()
        }

    ]
    Maui.BaseModel
    {
        id: _playlistsModel
        list: playlistsList
    }

    model: _playlistsModel

    delegate : Maui.ListDelegate
    {
        id: delegate
        width: control.width
        label: model.playlist

        Connections
        {
            target : delegate

            onClicked :
            {
                currentIndex = index
                var playlist = playlistsList.get(index).playlist
                filterList.group = false

                switch(playlist)
                {
                case "Most Played":

                    populate(Q.GET.mostPlayedTracks);
                    filterList.list.sortBy = Tracks.COUNT
                    break;

                case "Rating":
                    filterList.list.sortBy = Tracks.RATE
                    filterList.group = true

                    populate(Q.GET.favoriteTracks);
                    break;

                case "Recent":
                    populate(Q.GET.recentTracks);
                    filterList.list.sortBy = Tracks.ADDDATE
                    filterList.group = true
                    break;

                case "Favs":
                    populate(Q.GET.babedTracks);
                    break;

                case "Online":
                    populate(Q.GET.favoriteTracks);
                    break;

                case "Tags":
                    populateExtra(Q.GET.tags, "Tags")
                    break;

                case "Relationships":
                    populate(Q.GET.favoriteTracks);
                    break;

                case "Popular":
                    populate(Q.GET.favoriteTracks);
                    break;

                case "Genres":
                    populateExtra(Q.GET.genres, "Genres")
                    break;

                default:
                    populate(Q.GET.playlistTracks_.arg(playlist));
                    break;

                }
            }
        }
    }

    function addPlaylist(text)
    {
        var title = text.trim()
        if(playlistList.insertAt(title,  0))
            control.listView.positionViewAtEnd()
    }
}
