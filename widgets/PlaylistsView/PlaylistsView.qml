import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui


import "../../view_models/BabeTable"
import "../../view_models"
import "../../db/Queries.js" as Q
import "../../utils/Help.js" as H


Kirigami.PageRow
{
    id: playlistViewRoot

    property string playlistQuery
    property alias playlistViewModel : playlistViewModel

//    property alias list : _playlistsList
//    property alias listModel: _playlistsModel
//    property alias listView : playlistViewModel.listView

    signal rowClicked(var track)
    signal quickPlayTrack(var track)
    signal playAll(var tracks)
    signal playSync(var playlist)
    signal appendAll(var tracks)

    clip: true
    separatorVisible: wideMode
    initialPage: [playlistList, filterList]
    defaultColumnWidth: Kirigami.Units.gridUnit * 15
    interactive: currentIndex === 1 && !wideMode


    ColumnLayout
    {
        id: playlistList
        clip: true
        anchors.fill: parent
        spacing: 0
        Layout.margins: 0

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

                headBarExitIcon: "go-previous"

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

                onExit: playlistSwipe.currentIndex = 0
            }

        }

        ColorTagsBar
        {
            Layout.fillWidth: true
            height: rowHeightAlt
            recSize: isMobile ? iconSize : 16

            onColorClicked:
            {
                populate(Q.GET.colorTracks_.arg(color))
                if(!playlistViewRoot.wideMode)
                    playlistViewRoot.currentIndex = 1
            }
        }
    }

    BabeTable
    {
        id: filterList
        clip: true
        anchors.fill: parent
        quickPlayVisible: true
        coverArtVisible: true
        trackRating: true
        trackDuration: false
        headBar.visible: !holder.visible
        headBarExitIcon: "go-previous"
        headBarExit: !playlistViewRoot.wideMode
        headBarTitle: playlistViewModel.model.get(playlistViewModel.currentIndex).playlist
        onExit: if(!playlistViewRoot.wideMode)
                    playlistViewRoot.currentIndex = 0

        holder.emoji: "qrc:/assets/Electricity.png"
        holder.isMask: false
        holder.title : playlistViewModel.model.get(playlistViewModel.currentIndex).playlist
        holder.body: "Your playlist is empty,<br>start adding new music to it"
        holder.emojiSize: iconSizes.huge

        headerMenu.menuItem:  [
            MenuItem
            {
                enabled: !playlistViewModel.model.get(playlistViewModel.currentIndex).playlistIcon
                text: "Sync tags"
                onTriggered: {}
            },
            MenuItem
            {
                enabled: !playlistViewModel.model.get(playlistViewModel.currentIndex).playlistIcon
                text: "Play-n-Sync"
                onTriggered:
                {
                    filterList.headerMenu.close()
                    syncAndPlay(playlistViewModel.currentIndex)
                }
            },
            MenuItem
            {
                enabled: !playlistViewModel.model.get(playlistViewModel.currentIndex).playlistIcon
                text: "Remove playlist"
                onTriggered: removePlaylist()
            }
        ]


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
            boldLabel: true
            labelTxt.font.family: "Material Design Icons"

        }

        Connections
        {
            target: filterList
            onRowClicked: playlistViewRoot.rowClicked(filterList.model.get(index))
            onQuickPlayTrack:
            {
                playlistViewRoot.quickPlayTrack(filterList.model.get(index))
            }
            onPlayAll: playAll(bae.get(playlistQuery))
            onAppendAll: appendAll(bae.get(playlistQuery))
            onPulled: populate(playlistQuery)
        }

        Connections
        {
            target: filterList.contextMenu

            onRemoveClicked:
            {
                bae.removePlaylistTrack(url, playlistViewModel.model.get(playlistViewModel.currentIndex).playlist)
                populate(playlistQuery)
            }
        }
    }


    function populateExtra(query, title)
    {
        playlistSwipe.currentIndex = 1

        var res = bae.get(query)
        playlistViewModelFilter.clearTable()
        playlistViewModelFilter.headBarTitle = title
        appendToExtraList(res)
    }

    function appendToExtraList(res)
    {
        if(res.length>0)
            for(var i in res)
                playlistViewModelFilter.model.append(res[i])
    }

    function populate(query)
    {

        if(!playlistViewRoot.wideMode)
            playlistViewRoot.currentIndex = 1

        playlistQuery = query
        filterList.clearTable()

        var tracks = bae.get(query)

        if(tracks.length>0)
            for(var i in tracks)
                filterList.model.append(tracks[i])

    }

    function refresh()
    {
        for(var i=9; i < playlistViewModel.count; i++)
            playlistViewModel.model.remove(i)

        setPlaylists()
    }

    function setPlaylists()
    {
        var playlists = bae.get(Q.GET.playlists)
        if(playlists.length > 0)
            for(var i in playlists)
                playlistViewModel.model.append(playlists[i])
    }

    function syncAndPlay(index)
    {
        if(!playlistViewModel.model.get(index).playlistIcon)
            playlistViewRoot.playSync(playlistViewModel.model.get(index).playlist)
    }

    function removePlaylist()
    {

        bae.removePlaylist(playlistViewModel.model.get(playlistViewModel.currentIndex).playlist)

        filterList.clearTable()
        refresh()

    }

    Component.onCompleted: setPlaylists()
}
