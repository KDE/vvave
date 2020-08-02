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

StackView
{
    id: control
    clip: true

    property string currentPlaylist
    property string playlistQuery
    property alias playlistViewList : playlistViewModel

    property alias listModel : filterList.listModel

    signal rowClicked(var track)
    signal playTrack(var track)
    signal appendTrack(var track)
    signal playAll()
    signal syncAndPlay(string playlist)
    signal appendAll()

    property Flickable flickable : currentItem.flickable

    initialItem: PlaylistsViewModel
    {
        id: playlistViewModel

        Maui.FloatingButton
        {
            id: _overlayButton
            z: 999
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Maui.Style.toolBarHeight
            anchors.bottomMargin: Maui.Style.toolBarHeight
            icon.name : "list-add"
            onClicked: newPlaylistDialog.open()
        }
    }

    Maui.NewDialog
    {
        id: newPlaylistDialog
        title: i18n("Add new playlist")
        message: i18n("Create a new playlist to organize your music collection")
        onFinished: addPlaylist(text)
        acceptButton.text: i18n("Create")
        rejectButton.visible: false
    }

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
                filterList.list.remove(filterList.currentIndex)
            }
        }

        onRowClicked: control.rowClicked(filterList.listModel.get(index))
        onQuickPlayTrack: control.playTrack(filterList.listModel.get(filterList.currentIndex))
        onAppendTrack: control.appendTrack(filterList.listModel.get(filterList.currentIndex))

        onPlayAll:
        {
            if(filterList.isPublic)
                control.syncAndPlay(control.currentPlaylist)
            else
                control.playAll()

            control.pop()
        }

        onAppendAll: appendAll()
        onPulled: populate(playlistQuery)
        section.criteria: ViewSection.FullString
        section.delegate: Maui.LabelDelegate
        {
            label: filterList.section.property === i18n("stars") ? H.setStars(section) : section
            isSection: true
            labelTxt.font.family: "Material Design Icons"
            width: filterList.width
        }

    }

    function appendToExtraList(res)
    {
        if(res.length>0)
            for(var i in res)
                playlistViewModelFilter.model.append(res[i])
    }

    function populate(playlist, isPublic)
    {
        currentPlaylist = playlist

        switch(currentPlaylist)
        {
        case "Most Played":
            playlistQuery = Q.GET.mostPlayedTracks
            filterList.list.sortBy = Tracks.COUNT
            break;

        case "Rating":
            filterList.list.sortBy = Tracks.RATE
            filterList.group = true

            playlistQuery = Q.GET.favoriteTracks;
            break;

        case "Recent":
            playlistQuery = Q.GET.recentTracks;
            filterList.list.sortBy = Tracks.ADDDATE
            filterList.group = true
            break;

        default:
            playlistQuery = Q.GET.playlistTracks_.arg(currentPlaylist)
            break;
        }

        filterList.isPublic = isPublic
        filterList.listModel.filter = ""
        control.push(filterList)
    }

    function removePlaylist()
    {
        playlistsList.removePlaylist(playlistViewList.currentIndex)
    }

    function addPlaylist(text)
    {
        var title = text.trim()
        if(playlistsList.insert(title))
            control.listView.positionViewAtEnd()
    }
}
