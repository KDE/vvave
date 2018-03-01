import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami

import "../../view_models/BabeTable"
import "../../view_models/BabeMenu"
import "../../view_models"
import "../../db/Queries.js" as Q
import "../../utils/Help.js" as H


//    transform: Translate
//    {
//        x: (playlistViewDrawer.position * playlistViewRoot.width * 0.33)*-1
//    }

Kirigami.PageRow
{
    id: playlistViewRoot
    property string playlistQuery

    property alias playlistViewModel : playlistViewModel

    signal rowClicked(var track)
    signal quickPlayTrack(var track)
    signal playAll(var tracks)
    signal playSync(var playlist)
    signal appendAll(var tracks)

    clip: true
    separatorVisible: wideMode
    initialPage: [playlistList, playlistViewDrawer]
    defaultColumnWidth: Kirigami.Units.gridUnit * 15
    interactive: false


    Page
    {
        id: playlistList
        clip: true

        ColumnLayout
        {
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

                    headerBarExitIcon: "arrow-left"

                    model : ListModel {}
                    delegate: BabeDelegate
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
                recSize: isMobile ? toolBarIconSize : 16

                onColorClicked:
                {
                    populate(Q.GET.colorTracks_.arg(color))
                    if(!playlistViewRoot.wideMode)
                        playlistViewRoot.currentIndex = 1
                }
            }
        }
    }


    Page
    {
        id: playlistViewDrawer
        anchors.fill: parent
        clip: true

        BabeTable
        {
            id: filterList
            anchors.fill: parent
            quickPlayVisible: true
            coverArtVisible: true
            trackRating: true
            trackDuration: false
            headerBarVisible: true
            headerBarExitIcon: "arrow-left"
            headerBarExit: !playlistViewRoot.wideMode
            headerBarTitle: playlistViewRoot.wideMode ? "" : playlistViewModel.model.get(playlistViewModel.currentIndex).playlist
            onExit: if(!playlistViewRoot.wideMode)
                        playlistViewRoot.currentIndex = 0

            holder.message:  "<h2>"+playlistViewModel.model.get(playlistViewModel.currentIndex).playlist+"</h2><p>Your playlist is empty,<br>start adding new music to it</p>"
            holder.emoji: "qrc:/assets/face-hug.png"

            headerMenu.menuItem:  [
                BabeMenuItem
                {
                    enabled: !playlistViewModel.model.get(playlistViewModel.currentIndex).playlistIcon
                    text: "Sync tags"
                    onTriggered: {}
                },
                BabeMenuItem
                {
                    enabled: !playlistViewModel.model.get(playlistViewModel.currentIndex).playlistIcon
                    text: "Play-n-Sync"
                    onTriggered:
                    {
                        filterList.headerMenu.close()
                        syncAndPlay(playlistViewModel.currentIndex)
                    }
                },
                BabeMenuItem
                {
                    enabled: !playlistViewModel.model.get(playlistViewModel.currentIndex).playlistIcon
                    text: "Remove playlist"
                    onTriggered: removePlaylist()
                }
            ]

            contextMenu.menuItem: [

                BabeMenuItem
                {
                    text: qsTr("Remove from playlist")
                    onTriggered:
                    {
                        bae.removePlaylistTrack(filterList.model.get(filterList.currentIndex).url, playlistViewModel.model.get(playlistViewModel.currentIndex).playlist)
                        populate(playlistQuery)
                    }
                }
            ]


            section.criteria: ViewSection.FullString
            section.delegate: BabeDelegate
            {
                label: filterList.section.property === qsTr("stars") ? H.setStars(section) : section
                isSection: true
                boldLabel: true
                fontFamily: "Material Design Icons"

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
        }

    }

    function populateExtra(query, title)
    {
        playlistSwipe.currentIndex = 1

        var res = bae.get(query)
        playlistViewModelFilter.clearTable()
        playlistViewModelFilter.headerBarTitle = title
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
