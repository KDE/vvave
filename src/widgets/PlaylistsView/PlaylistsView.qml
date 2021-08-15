import QtQuick 2.14
import QtQuick.Controls 2.14

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.vvave 1.0 as Vvave

import "../BabeTable"

import "../../db/Queries.js" as Q
import "../../utils/Player.js" as Player

StackView
{
    id: control

    property string currentPlaylist
    property string playlistQuery

    property Flickable flickable : currentItem.flickable

    FB.NewTagDialog
    {
        id: newPlaylistDialog
    }

    initialItem: PlaylistsViewModel
    {
    }

    Component
    {
        id: _filterListComponent

        BabeTable
        {
            id: filterList
            property bool isPublic: true
            signal removeFromPlaylist(string url)
            list.query: control.playlistQuery
            coverArtVisible: true
            showTitle: false
            title: control.currentPlaylist
            holder.emoji: "qrc:/assets/dialog-information.svg"
            holder.isMask: true
            holder.title : title
            holder.body: "Your playlist is empty,<br>start adding new music to it"
            holder.emojiSize: Maui.Style.iconSizes.huge
            headBar.visible: true
            headBar.farLeftContent: ToolButton
            {
                icon.name: "go-previous"
                onClicked: control.pop()
            }

            contextMenuItems: MenuItem
            {
                text: i18n("Remove from playlist")
                onTriggered:
                {
                    Vvave.Playlists.removeTrack(currentPlaylist, listModel.get(filterList.currentIndex).url)
                    listModel.list.remove(filterList.currentIndex)
                }
            }

            onQueueTrack: Player.queueTracks([listModel.get(index)], index)

            onRowClicked: Player.quickPlay(filterList.listModel.get(index))
            onAppendTrack: Player.addTrack(filterList.listModel.get(index))
            onQuickPlayTrack: Player.quickPlay(filterList.listModel.get(index))

            onPlayAll:
            {
                Player.playAllModel(listModel.list)
                control.pop()                

                if(filterList.isPublic)
                {
                    root.sync = true
                    root.syncPlaylist = currentPlaylist
                }
            }

            onAppendAll: Player.appendAllModel(listModel.list)

            section.criteria: ViewSection.FullString
            section.delegate: Maui.LabelDelegate
            {
                label: filterList.section.property === i18n("stars") ? H.setStars(section) : section
                isSection: true
                labelTxt.font.family: "Material Design Icons"
                width: filterList.width
            }

            Component.onCompleted:
            {
                filterList.group = false

                switch(currentPlaylist)
                {
                case "Most Played":
                    playlistQuery = Q.GET.mostPlayedTracks
                    filterList.listModel.sort = "count"
                    break;

                case "Rating":
                    filterList.listModel.sort = "rate"
                    filterList.group = true

                    playlistQuery = Q.GET.favoriteTracks;
                    break;

                case "Recent":
                    playlistQuery = Q.GET.recentTracks;
                    filterList.listModel.sort = "adddate"
                    filterList.group = true
                    break;

                default:
                    playlistQuery = Q.GET.playlistTracks_.arg(currentPlaylist)
                    break;
                }

                filterList.isPublic = isPublic
                filterList.listModel.filter = ""
            }
        }
    }

    function populate(playlist, isPublic)
    {
        currentPlaylist = playlist
        control.push(_filterListComponent)
    }
}
