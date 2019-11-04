import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.10
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import TracksList 1.0

import "../../view_models/BabeTable"
import "../../view_models"
import "../../db/Queries.js" as Q
import "../../utils/Help.js" as H

Maui.Page
{
    id: control
    spacing: Maui.Style.space.medium

    property string currentPlaylist
    property string playlistQuery
    property alias playlistModel : playlistViewModel.model
    property alias playlistViewList : playlistViewModel

    property alias listModel : filterList.listModel

    signal rowClicked(var track)
    signal quickPlayTrack(var track)
    signal playAll()
    signal syncAndPlay(string playlist)
    signal appendAll()

    footBar.rightContent:  [

        ToolButton
        {
            id : createPlaylistBtn
//            text: qsTr("Add")
            icon.name : "list-add"
            onClicked: newPlaylistDialog.open()
        }
    ]

    PlaylistsViewModel
    {
        id: playlistViewModel
        anchors.fill: parent
    }

    Maui.NewDialog
    {
        id: newPlaylistDialog
        title: qsTr("New Playlist...")
        onFinished: addPlaylist(text)
        acceptText: qsTr("Create")
        rejectButton.visible: false
    }

    Maui.Dialog
    {
        id: _filterDialog
        property bool isPublic: true

        parent: parent
        maxHeight: maxWidth
        maxWidth: Maui.Style.unit * 600
        defaultButtons: false
        page.padding: 0

        BabeTable
        {
            id: filterList
            anchors.fill: parent
            clip: true
            coverArtVisible: true
            headBar.visible: !holder.visible
            title: control.currentPlaylist
            holder.emoji: "qrc:/assets/dialog-information.svg"
            holder.isMask: false
            holder.title : title
            holder.body: "Your playlist is empty,<br>start adding new music to it"
            holder.emojiSize: Maui.Style.iconSizes.huge

            contextMenuItems: MenuItem
            {
                text: qsTr("Remove from playlist")
            }


            //        headerMenu.menuItem:  [
            //            Maui.MenuItem
            //            {
            //                enabled: !playlistViewModel.model.get(playlistViewModel.currentIndex).playlistIcon
            //                text: "Sync tags"
            //                onTriggered: {}
            //            },
            //            Maui.MenuItem
            //            {
            //                enabled: !playlistViewModel.model.get(playlistViewModel.currentIndex).playlistIcon
            //                text: "Play-n-Sync"
            //                onTriggered:
            //                {
            //                    filterList.headerMenu.close()
            //                    syncAndPlay(playlistViewModel.currentIndex)
            //                }
            //            },
            //            Maui.MenuItem
            //            {
            //                enabled: !playlistViewModel.model.get(playlistViewModel.currentIndex).playlistIcon
            //                text: "Remove playlist"
            //                onTriggered: removePlaylist()
            //            }
            //        ]


            //            contextMenu.menuItem: [

            //                MenuItem
            //                {
            //                    text: qsTr("Remove from playlist")
            //                    onTriggered:
            //                    {
            //                        bae.removePlaylistTrack(filterList.model.get(filterList.currentIndex).url, playlistViewModel.model.get(playlistViewModel.currentIndex).playlist)
            //                        populate(playlistQuery)
            //                    }
            //                }
            //            ]

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
                target: filterList
                onRowClicked: control.rowClicked(filterList.listModel.get(index))
                onQuickPlayTrack: control.quickPlayTrack(filterList.listModel.get(filterList.currentIndex))

                onPlayAll:
                {
                    if(_filterDialog.isPublic)
                        control.syncAndPlay(control.currentPlaylist)
                    else
                        control.playAll()

                    _filterDialog.close()
                }

                onAppendAll: appendAll()
                onPulled: populate(playlistQuery)
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
        _filterDialog.isPublic = isPublic
        filterList.list.query = playlistQuery
        _filterDialog.open()
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
