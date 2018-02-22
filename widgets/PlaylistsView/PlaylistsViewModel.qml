import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami

import "../../utils"

import "../../view_models"
import "../../db/Queries.js" as Q

BabeList
{
    id: playlistListRoot

    headerBarColor: midLightColor
    headerBarExit: false
    headerBarTitle: "Playlists"

    AddPlaylistDialog
    {
        id:newPlaylistDialog
    }

    signal playSync(int index)

    Rectangle
    {
        anchors.fill: parent
        color: altColor
        z: -999
    }

    headerBarLeft: BabeButton
    {
        id : createPlaylistBtn
        anim : true
        iconName : "list-add"
        onClicked : newPlaylistDialog.open()
    }

    headerBarRight: BabeButton
    {
        iconName: "list-remove"
        onClicked: removePlaylist()
    }

    ListModel
    {
        id: playlistListModel

        ListElement { playlist: qsTr("Most Played"); playlistIcon: "view-media-playcount"; /*query: Q.Query.mostPlayedTracks*/ }
        ListElement { playlist: qsTr("Favorites"); playlistIcon: "view-media-favorite"}
        ListElement { playlist: qsTr("Recent"); playlistIcon: "view-media-recent"}
        ListElement { playlist: qsTr("Babes"); playlistIcon: "love"}
        ListElement { playlist: qsTr("Online"); playlistIcon: "internet-services"}
        ListElement { playlist: qsTr("Tags"); playlistIcon: "tag"}
        ListElement { playlist: qsTr("Relationships"); playlistIcon: "view-media-similarartists"}
        ListElement { playlist: qsTr("Popular"); playlistIcon: "view-media-chart"}
        ListElement { playlist: qsTr("Genres"); playlistIcon: "view-media-genre"}
    }

    model: playlistListModel

    delegate : PlaylistViewDelegate
    {
        id: delegate
        width: playlistListRoot.width

        Connections
        {
            target : delegate

            onClicked :
            {
                currentIndex = index
                var playlist = playlistListModel.get(index).playlist
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

                    playlistViewRoot.populate(Q.GET.favoriteTracks);
                    break;

                case "Relationships":

                    playlistViewRoot.populate(Q.GET.favoriteTracks);
                    break;

                case "Popular":

                    playlistViewRoot.populate(Q.GET.favoriteTracks);
                    break;

                case "Genre":

                    filterList.section.property = "genre"
                    playlistViewRoot.populate(Q.GET.favoriteTracks);
                    break;

                default:

                    playlistViewRoot.populate(Q.GET.playlistTracks_.arg(playlist));
                    break;

                }

                if(!playlistViewRoot.wideMode)
                    playlistViewRoot.currentIndex = 1

            }

            onPlaySync: playlistListRoot.playSync(index)

        }
    }
}
