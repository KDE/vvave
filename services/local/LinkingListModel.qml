import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.10
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "../../utils"
import "../../widgets/PlaylistsView"
import "../../view_models"
import "../../db/Queries.js" as Q
import "../../utils/Help.js" as H
import Link.Codes 1.0

BabeList
{
    id: linkingListRoot

    headBarExit: false
    headBarTitle: isLinked ?link.getIp() : i18n("Disconnected")

    headBar.leftContent: ToolButton
    {
        icon.name : "view-refresh"
        onClicked : refreshPlaylists()
    }

    headBar.rightContent: ToolButton
    {
        id: menuBtn
        icon.name: "application-menu"
        onClicked: linkingConf.open()
    }

    ListModel
    {
        id: linkingListModel

        ListElement { playlist: i18n("Albums"); icon: "view-media-album-cover"}
        ListElement { playlist: i18n("Artists"); icon: "view-media-artist"}
        ListElement { playlist: i18n("Most Played"); icon: "view-media-playcount" /*query: Q.Query.mostPlayedTracks*/ }
        ListElement { playlist: i18n("Favorites"); icon: "view-media-favorite"}
        ListElement { playlist: i18n("Recent"); icon: "view-media-recent"}
        ListElement { playlist: i18n("Babes"); icon: "love"}
        ListElement { playlist: i18n("Online"); icon: "internet-services"}
        ListElement { playlist: i18n("Tags"); icon: "tag"}
        ListElement { playlist: i18n("Relationships"); icon: "view-media-similarartists"}
        ListElement { playlist: i18n("Popular"); icon: "view-media-chart"}
        ListElement { playlist: i18n("Genres"); icon: "view-media-genre"}
    }

    model: linkingListModel

    delegate : Maui.ListDelegate
    {
        id: delegate
        width: linkingListRoot.width
        label: model.playlist

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
