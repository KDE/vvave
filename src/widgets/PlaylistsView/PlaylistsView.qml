import QtQuick
import QtQuick.Controls

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

import org.maui.vvave as Vvave

import "../BabeTable"

import "../../db/Queries.js" as Q
import "../../utils/Player.js" as Player

StackView
{
    id: control

    property string playlistQuery

    readonly property Flickable flickable : currentItem.flickable
    readonly property alias playlistList :_playlistPage.list

    Component
    {
        id: newPlaylistDialogComponent
        FB.NewTagDialog {onClosed: destroy()}
    }

    initialItem: PlaylistsViewModel
    {
        id: _playlistPage
    }

    Component
    {
        id: _filterListComponent

        BabeTable
        {
            id: filterList

            property string currentPlaylist //id

            property bool isPublic: true

            signal removeFromPlaylist(string url)

            coverArtVisible: settings.showArtwork

            list.query: control.playlistQuery
            showTitle: false
            title: currentPlaylist

            holder.emoji: "qrc:/assets/dialog-information.svg"
            holder.isMask: true
            holder.title : title
            holder.body: i18n("Your playlist is empty. Start adding new music to it")

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
                    control.playlistList.removeTrack(currentPlaylist, listModel.get(filterList.currentIndex).url)
                    listModel.list.remove(filterList.currentIndex)
                }
            }

            onQueueTrack: (index) => Player.queueTracks([listModel.get(index)], index)
            onRowClicked: (index) => Player.quickPlay(filterList.listModel.get(index))
            onAppendTrack: (index) => Player.addTrack(filterList.listModel.get(index))

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
            onShuffleAll: Player.shuffleAllModel(listModel.list)

            Component.onCompleted:
            {
                isPublic = false

                switch(currentPlaylist)
                {
                case "mostPlayed":
                    playlistQuery = Q.GET.mostPlayedTracks
                    filterList.listModel.sort = "title"
                    break;

                case "randomTracks":
                    filterList.listModel.sort = "title"
                    playlistQuery = Q.GET.randomTracks_;
                    break;

                case "recentTracks":
                    playlistQuery = Q.GET.recentTracks_;
                    filterList.listModel.sort = "title"
                    break;

                case "neverPlayed":
                    playlistQuery = Q.GET.neverPlayedTracks_;
                    filterList.listModel.sort = "title"
                    break;

                case "classicTracks":
                    playlistQuery = Q.GET.oldTracks;
                    filterList.listModel.sort = "title"
                    break;

                default:
                    isPublic = true
                    playlistQuery = Q.GET.playlistTracks_.arg(currentPlaylist)
                    break;
                }

                filterList.isPublic = isPublic
                filterList.listModel.clearFilters()
            }
        }
    }

    function populate(playlist, isPublic)
    {
        control.push(_filterListComponent, {'currentPlaylist': playlist, 'isPublic': isPublic})
    }

    function getFilterField() : Item
    {
        return control.currentItem.getFilterField()
    }

    function getGoBackFunc()
    {
        if (control.depth > 1)
            return () => { control.pop() }
        else
            return null
    }
}
