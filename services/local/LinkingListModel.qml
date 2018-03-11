import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami

import "../../utils"
import "../../widgets/PlaylistsView"
import "../../view_models"
import "../../db/Queries.js" as Q
import "../../utils/Help.js" as H
import Link.Codes 1.0

BabeList
{
    id: linkingListRoot

    headerBarExit: false
    headerBarTitle: isLinked ?link.getIp() : qsTr("Disconnected")

    headerBarLeft: BabeButton
    {
        anim : true
        iconName : "view-refresh"
        onClicked : refreshPlaylists()
    }

    headerBarRight: BabeButton
    {
        id: menuBtn
        iconName: "application-menu"
        onClicked: linkingConf.open()
    }

    ListModel
    {
        id: linkingListModel

        ListElement { playlist: qsTr("Albums"); playlistIcon: "view-media-album-cover"}
        ListElement { playlist: qsTr("Artists"); playlistIcon: "view-media-artist"}
        ListElement { playlist: qsTr("Most Played"); playlistIcon: "view-media-playcount" /*query: Q.Query.mostPlayedTracks*/ }
        ListElement { playlist: qsTr("Favorites"); playlistIcon: "view-media-favorite"}
        ListElement { playlist: qsTr("Recent"); playlistIcon: "view-media-recent"}
        ListElement { playlist: qsTr("Babes"); playlistIcon: "love"}
        ListElement { playlist: qsTr("Online"); playlistIcon: "internet-services"}
        ListElement { playlist: qsTr("Tags"); playlistIcon: "tag"}
        ListElement { playlist: qsTr("Relationships"); playlistIcon: "view-media-similarartists"}
        ListElement { playlist: qsTr("Popular"); playlistIcon: "view-media-chart"}
        ListElement { playlist: qsTr("Genres"); playlistIcon: "view-media-genre"}
    }

    model: linkingListModel

    delegate : PlaylistViewDelegate
    {
        id: delegate
        width: linkingListRoot.width

        Connections
        {
            target : delegate

            onClicked :
            {
                currentIndex = index
                var playlist = linkingListModel.get(index).playlist

                switch(playlist)
                {
                case "Artists":
                    populateExtra(LINK.FILTER, "select artist as tag from artists", playlist)
                    break

                case "Albums":
                    populateExtra(LINK.FILTER, "select album as tag, artist from albums", playlist)

                    break

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
                    populateExtra(LINK.FILTER, Q.GET.tags, playlist)
                    break;

                case "Relationships":

                    playlistViewRoot.populate(Q.GET.favoriteTracks);
                    break;

                case "Popular":

                    playlistViewRoot.populate(Q.GET.favoriteTracks);
                    break;

                case "Genres":

                    populateExtra(LINK.FILTER, Q.GET.genres, playlist)
                    break;

                default:

                    playlistViewRoot.populate(Q.GET.playlistTracks_.arg(playlist));
                    break;

                }
            }
        }
    }
}
