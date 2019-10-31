import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "../../view_models/BabeTable"
import "../../view_models"
import "../../db/Queries.js" as Q
import "../../utils/Help.js" as H

ColumnLayout
{
    id: control
    spacing: 0

    property string playlistQuery
    property alias playlistModel : playlistViewModel.model
    property alias playlistList : playlistViewModel.list
    property alias playlistViewList : playlistViewModel

    signal rowClicked(var track)
    signal quickPlayTrack(var track)
    signal playAll()
    signal playSync(var playlist)
    signal appendAll()

    SwipeView
    {
        id: playlistSwipe

        Layout.fillHeight: true
        Layout.fillWidth: true
        interactive: false
        clip: true

        PlaylistsViewModel
        {
            id: playlistViewModel
            onPlaySync: syncAndPlay(index)
        }

        BabeList
        {
            id: playlistViewModelFilter
//            headBarExitIcon: "go-previous"
            headBar.leftContent: ToolButton
            {
                icon.name: "go-previous"
                onClicked: playlistSwipe.currentIndex = 0
            }

            model : ListModel {}
            delegate: Maui.LabelDelegate
            {
                id: delegate
                label : tag
                Connections
                {
                    target: delegate

                    onClicked: {}
                }
            }
        }
    }

    ColorTagsBar
    {
        Layout.fillWidth: true
        height: Maui.Style.rowHeightAlt
        recSize: Kirigami.Settings.isMobile ? Maui.Style.iconSizes.medium : Maui.Style.iconSizes.small
        onColorClicked: populate(Q.GET.colorTracks_.arg(color.toLowerCase()))
    }

    Maui.Dialog
    {
        id: _filterDialog
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
            title: playlistViewModel.list.get(playlistViewModel.currentIndex).playlist
            holder.emoji: "qrc:/assets/dialog-information.svg"
            holder.isMask: false
            holder.title : playlistViewModel.list.get(playlistViewModel.currentIndex).playlist
            holder.body: "Your playlist is empty,<br>start adding new music to it"
            holder.emojiSize: Maui.Style.iconSizes.huge

            contextMenuItems:
                MenuItem
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
                onRowClicked: control.rowClicked(filterList.list.get(index))
                onQuickPlayTrack: control.quickPlayTrack(filterList.list.get(filterList.currentIndex))

                onPlayAll: playAll()
                onAppendAll: appendAll()
                onPulled: populate(playlistQuery)
            }

            Connections
            {
                target: filterList.contextMenu

                onRemoveClicked:
                {
                    playlistList.removeTrack(playlistViewList.currentIndex, filterList.list.get(filterList.currentIndex).url)
                    populate(playlistQuery)
                }
            }
        }
    }


    function populateExtra(query, title)
    {
        //        playlistSwipe.currentIndex = 1

        //        var res = bae.get(query)
        //        playlistViewModelFilter.clearTable()
        //        playlistViewModelFilter.headBarTitle = title
        //        appendToExtraList(res)
    }

    function appendToExtraList(res)
    {
        if(res.length>0)
            for(var i in res)
                playlistViewModelFilter.model.append(res[i])
    }

    function populate(query)
    {
        playlistQuery = query
        filterList.list.query = playlistQuery
        _filterDialog.open()
    }

    function syncAndPlay(index)
    {
        if(!playlistList.get(index).playlistIcon)
            playSync(playlistList.get(index).playlist)
    }

    function removePlaylist()
    {
        playlistList.removePlaylist(playlistViewList.currentIndex)
    }
}
