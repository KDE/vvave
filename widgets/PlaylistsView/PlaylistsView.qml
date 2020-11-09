import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.10
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.maui.vvave 1.0

import "../../view_models/BabeTable"
import "../../view_models"
import "../../db/Queries.js" as Q
import "../../utils/Help.js" as H
import "../../utils/Player.js" as Player

StackView
{
    id: control
    clip: true

    property string currentPlaylist
    property string playlistQuery

    property Flickable flickable : currentItem.flickable

    Maui.NewDialog
    {
        id: newPlaylistDialog
        title: i18n("Add new playlist")
        message: i18n("Create a new playlist to organize your music collection")
        onFinished: addPlaylist(text)
        acceptButton.text: i18n("Create")
        rejectButton.visible: false
    }

    initialItem:  PlaylistsViewModel
    {
        Maui.FloatingButton
        {
            id: _overlayButton
            z: 999
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Maui.Style.toolBarHeight
            anchors.bottomMargin: Maui.Style.toolBarHeight + flickable.bottomMargin
            icon.name : "list-add"
            onClicked: newPlaylistDialog.open()
        }
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
                    playlistsList.removeTrack(currentPlaylist, listModel.get(filterList.currentIndex).url)
                    listModel.list.remove(filterList.currentIndex)
                }
            }

            onQueueTrack: Player.queueTracks([listModel.get(index)], index)

            onRowClicked: Player.quickPlay(filterList.listModel.get(index))
            onAppendTrack: Player.addTrack(filterList.listModel.get(index))
            onQuickPlayTrack: Player.quickPlay(filterList.listModel.get(index))

            onPlayAll:
            {
                if(filterList.isPublic)
                {
                    root.sync = true
                    root.syncPlaylist = currentPlaylist
                }

                Player.playAllModel(listModel.list)
                control.pop()
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

    function addPlaylist(text)
    {
        var title = text.trim()
        if(playlistsList.insert(title))
            control.listView.positionViewAtEnd()
    }
}
