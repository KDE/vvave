import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import PlaylistsList 1.0
import BaseModel 1.0

import "../../utils"

import "../../view_models"
import "../../db/Queries.js" as Q
import "../../utils/Help.js" as H

BabeList
{
    id: playlistListRoot

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
        width: playlistListRoot.width
        label: model.playlist

        Connections
        {
            target : delegate

            onClicked :
            {
                currentIndex = index
                var playlist = list.get(index).playlist
                filterList.section.property = ""

                switch(playlist)
                {
                case "Most Played":

                    playlistViewRoot.populate(Q.GET.mostPlayedTracks);
                    break;

                case "Favorites":
                    filterList.section.property = "stars"
                    playlistViewRoot.populate(Q.GET.favoriteTracks);
                    break;

                case "Recent":
                    playlistViewRoot.populate(Q.GET.recentTracks);
                    break;

                case "Babes":
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
        if(bae.addPlaylist(title))
            model.insert(9, {playlist: title})
        list.positionViewAtEnd()
    }
}
