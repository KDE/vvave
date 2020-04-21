import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.10
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import TracksList 1.0
import QtGraphicalEffects 1.0

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
    property alias playlistModel : playlistViewModel.model
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
        title: qsTr("Add new playlist")
        onFinished: addPlaylist(text)
        acceptText: qsTr("Create")
        rejectButton.visible: false
    }

    BabeTable
    {
        id: filterList
        property bool isPublic: true

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
            text: qsTr("Remove from playlist")
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
            label: filterList.section.property === qsTr("stars") ? H.setStars(section) : section
            isSection: true
            labelTxt.font.family: "Material Design Icons"
            width: filterList.width
        }

        Connections
        {
            target: filterList.contextMenu

            onRemoveClicked:
            {
                playlistsList.removeTrack(playlistViewList.currentIndex, filterList.listModel.get(filterList.currentIndex).url)
                populate(playlistQuery)
            }
        }
    }

    function appendToExtraList(res)
    {
        if(res.length>0)
            for(var i in res)
                playlistViewModelFilter.model.append(res[i])
    }

    function populate(query, isPublic)
    {
        playlistQuery = query
        filterList.isPublic = isPublic
        filterList.list.query = playlistQuery
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
