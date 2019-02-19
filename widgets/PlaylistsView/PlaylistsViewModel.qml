import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import PlaylistsList 1.0
import BaseModel 1.0

import TracksList 1.0

import "../../utils"

import "../../view_models"
import "../../db/Queries.js" as Q
import "../../utils/Help.js" as H

BabeList
{
    id: control

    property alias list: _playlistsList

    headBarExit: false
    headBarTitle: "Playlists"

    Maui.NewDialog
    {
        id: newPlaylistDialog
        title: qsTr("New Playlist...")
        onFinished: addPlaylist(text)
        acceptText: qsTr("Create")
        rejectButton.visible: false
    }

    signal playSync(int index)
    headBar.plegable: false

    headBar.leftContent: Maui.ToolButton
    {
        id : createPlaylistBtn
        anim : true
        iconName : "list-add"
        onClicked : newPlaylistDialog.open()
    }

    headBar.rightContent: Maui.ToolButton
    {
        iconName: "list-remove"
        onClicked: removePlaylist()
    }

    BaseModel
    {
        id: _playlistsModel
        list: _playlistsList
    }

    Playlists
    {
        id: _playlistsList
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
                var playlist = _playlistsList.get(index).playlist
                filterList.group = false

                switch(playlist)
                {
                case "Most Played":

                    playlistViewRoot.populate(Q.GET.mostPlayedTracks);
                    filterList.list.sortBy = Tracks.COUNT
                    break;

                case "Favorites":
                    filterList.list.sortBy = Tracks.RATE
                    filterList.group = true

                    playlistViewRoot.populate(Q.GET.favoriteTracks);
                    break;

                case "Recent":
                    playlistViewRoot.populate(Q.GET.recentTracks);
                    filterList.list.sortBy = Tracks.ADDDATE
                    filterList.group = true
                    break;

                case "Favs":
                    playlistViewRoot.populate(Q.GET.babedTracks);
                    break;

                case "Online":
                    playlistViewRoot.populate(Q.GET.favoriteTracks);
                    break;

                case "Tags":
                    populateExtra(Q.GET.tags, "Tags")
                    break;

                case "Relationships":
                    playlistViewRoot.populate(Q.GET.favoriteTracks);
                    break;

                case "Popular":
                    playlistViewRoot.populate(Q.GET.favoriteTracks);
                    break;

                case "Genres":
                    populateExtra(Q.GET.genres, "Genres")
                    break;

                default:
                    playlistViewRoot.populate(Q.GET.playlistTracks_.arg(playlist));
                    break;

                }
            }
        }
    }

    function addPlaylist(text)
    {
        var title = text.trim()
        if(list.insertAt(title,  0))
            control.listView.positionViewAtEnd()
    }
}
