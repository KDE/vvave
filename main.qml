import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import "utils"

import "widgets"
import "widgets/MyBeatView"
import "widgets/PlaylistsView"
import "widgets/MainPlaylist"
import "widgets/SettingsView"
import "widgets/SearchView"
import "widgets/CloudView"

import "view_models"
import "view_models/BabeTable"

import "services/local"
import "services/web"
import "services/web/Spotify"

import "view_models/BabeGrid"

import "widgets/InfoView"

import "db/Queries.js" as Q
import "utils/Help.js" as H
import "utils/Player.js" as Player

import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import FMList 1.0
import Player 1.0
import AlbumsList 1.0
import TracksList 1.0

Maui.ApplicationWindow
{

    id: root
    title: qsTr("vvave")
    /***************************************************/
    /******************** ALIASES ********************/
    /*************************************************/
    property alias mainPlaylist: mainPlaylist
    property alias selectionBar: selectionBar
    property alias progressBar: progressBar

    about.appIcon: "qrc:/assets/vvave.svg"
    about.appDescription: qsTr("VVAVE will handle your whole music collection by retreaving semantic information from the web. Just relax, enjoy and discover your new music ")
    showAccounts: false
    /***************************************************/
    /******************** PLAYBACK ********************/
    /*************************************************/
    property bool isShuffle: /*bae.loadSetting("SHUFFLE","PLAYBACK", false) == "true" ? true :*/ false
    property var currentTrack: ({
                                    babe: "0",
                                    stars: "0"
                                })

    property int currentTrackIndex: -1
    property int prevTrackIndex: 0

    property string currentArtwork: !mainlistEmpty ? mainPlaylist.list.get(0).artwork : ""
    property bool currentBabe: currentTrack.fav == "0" ? false : true

    property alias durationTimeLabel: player.duration
    property string progressTimeLabel: player.transformTime(player.position/1000)

    property alias isPlaying: player.playing
    property int onQueue: 0

    property bool mainlistEmpty: !mainPlaylist.table.count > 0

      /***************************************************/
    /******************** HANDLERS ********************/
    /*************************************************/

    property int currentView: viewsIndex.tracks

    readonly property var viewsIndex: ({
                                           tracks: 0,
                                           albums: 1,
                                           artists: 2,
                                           playlists: 3,
                                           search: 4,
                                           folders: 5,
//                                           cloud: 6,
//                                           vvave: 7,
//                                           linking: 8,
                                           youtube: 6,
//                                           spotify: 10

                                       })

    property string syncPlaylist: ""
    property bool sync: false

    property string infoMsg: ""
    property bool infoLabels: bae.loadSetting("LABELS", "PLAYBACK", false) == "true" ? true : false

//    property bool isLinked: false
//    property bool isServing: false

//    property bool focusMode : false
    property bool selectionMode : false

    /***************************************************/
    /******************** UI COLORS *******************/
    /*************************************************/
    readonly property string babeColor: bae.babeColor() //"#140032"

    /*SIGNALS*/
    signal missingAlert(var track)


    /*HANDLE EVENTS*/
    onClosing: Player.savePlaylist()

    onMissingAlert:
    {
        var message = track.title + " by " + track.artist + " is missing"
        var messageBody = "Do you want to remove it from your collection?"
        notify("alert", message, messageBody, function ()
        {
            bae.removeTrack(currentTrack.url) //todo
            mainPlaylist.table.model.remove(mainPlaylist.table.currentIndex)
        })
    }

    /*COMPONENTS*/

    Player
    {
        id: player
        volume: 100
        onFinishedChanged: if (!mainlistEmpty)
                           {
                               console.log("track fully played")
                               if (currentTrack.url)
                                   mainPlaylist.list.countUp(currentTrackIndex)

                               Player.nextTrack()
                           }
    }

    BabeNotify
    {
        id: babeNotify //todo
    }


    /* UI */
    property bool accent : pageStack.wideMode || (!pageStack.wideMode && pageStack.currentIndex === 1)
    altToolBars: false
    accentColor: babeColor
    headBarFGColor: altColorText
    headBarBGColor: currentView === viewsIndex.vvave ? "#7e57c2" : "#212121"
    colorSchemeName: "vvave"
    altColorText: darkTextColor
    floatingBar: false

    headBar.middleContent : [

        Maui.ToolButton
        {
            iconName: "headphones"
            iconColor: !accent  || isPlaying  ? babeColor : altColorText
            onClicked: pageStack.currentIndex = 0
            colorScheme.highlightColor: babeColor
            text: qsTr("Now")
        },

        Maui.ToolButton
        {
            iconName: "view-media-track"
            iconColor:  accent && currentView === viewsIndex.tracks ? babeColor : altColorText
            onClicked:
            {
                pageStack.currentIndex = 1
                currentView = viewsIndex.tracks
            }

            text: qsTr("Tracks")
            tooltipText: pageStack.wideMode ? "" : text
            colorScheme.highlightColor: babeColor

        },

        Maui.ToolButton
        {
            text: qsTr("Albums")
            iconName: /*"album"*/ "view-media-album-cover"
            iconColor: accent && currentView === viewsIndex.albums ? babeColor : altColorText
            onClicked:
            {
                pageStack.currentIndex = 1
                currentView = viewsIndex.albums
            }
            tooltipText: pageStack.wideMode ? "" : text
            colorScheme.highlightColor: babeColor

        },

        Maui.ToolButton
        {
            text: qsTr("Artists")
            iconName: "view-media-artist"
            iconColor:  accent && currentView === viewsIndex.artists ? babeColor : altColorText
            onClicked:
            {
                pageStack.currentIndex = 1
                currentView = viewsIndex.artists
            }
            tooltipText: pageStack.wideMode ? "" : text
            colorScheme.highlightColor: babeColor

        },

        Maui.ToolButton
        {
            text: qsTr("Playlists")
            iconName: "view-media-playlist"
            iconColor:  accent && currentView === viewsIndex.playlists ? babeColor : altColorText
            onClicked:
            {
                pageStack.currentIndex = 1
                currentView = viewsIndex.playlists
            }
            tooltipText: pageStack.wideMode ? "" : text
            colorScheme.highlightColor: babeColor

        }
    ]

    footBar.implicitHeight: footBar.visible ? toolBarHeight * 1.2 : 0
    page.footBarItem: ColumnLayout
    {
        id: _footerLayout

        height: footBar.height
        width: root.width
        spacing: 0

        Slider
        {
            id: progressBar
            Layout.preferredHeight: unit * (isMobile ?  6 : 8)
            Layout.fillWidth: true

            padding: 0
            from: 0
            to: 1000
            value: player.pos
            spacing: 0
            focus: true
            onMoved:
            {
                player.pos = value
            }

            background: Rectangle
            {
                implicitWidth: progressBar.width
                implicitHeight: progressBar.height
                width: progressBar.availableWidth
                height: implicitHeight
                color: "transparent"

                Rectangle
                {
                    width: progressBar.visualPosition * parent.width
                    height: progressBar.height
                    color: babeColor
                }
            }

            handle: Rectangle
            {
                x: progressBar.leftPadding + progressBar.visualPosition
                   * (progressBar.availableWidth - width)
                y: -(progressBar.height * 0.8)
                implicitWidth: progressBar.pressed ? iconSizes.medium : 0
                implicitHeight: progressBar.pressed ? iconSizes.medium : 0
                radius: progressBar.pressed ? iconSizes.medium : 0
                color: babeColor
            }
        }

        Kirigami.Separator
        {
            Layout.fillWidth: true
            color: borderColor
        }

        Maui.ToolBar
        {
            Layout.fillHeight: true
            Layout.fillWidth: true

            middleContent: [

                Maui.ToolButton
                {
                    id: babeBtnIcon
                    iconName: "love"

                    iconColor: currentBabe ? babeColor : textColor
                    onClicked: if (!mainlistEmpty)
                    {
                        mainPlaylist.list.fav(currentTrackIndex, !(mainPlaylist.list.get(currentTrackIndex).fav == "1"))
                        currentBabe = mainPlaylist.list.get(currentTrackIndex).fav == "1"
                    }
                },

                Maui.ToolButton
                {
                    iconName: "media-skip-backward"
                    iconColor: textColor
                    onClicked: Player.previousTrack()
                    onPressAndHold: Player.playAt(prevTrackIndex)
                },

                Maui.ToolButton
                {
                    id: playIcon
                    iconColor: textColor
                    iconName: isPlaying ? "media-playback-pause" : "media-playback-start"
                    onClicked:
                    {
                        player.playing = !player.playing
                    }
                },

                Maui.ToolButton
                {
                    id: nextBtn
                    iconColor: textColor
                    iconName: "media-skip-forward"
                    onClicked: Player.nextTrack()
                    onPressAndHold: Player.playAt(Player.shuffle())
                },

                Maui.ToolButton
                {
                    id: shuffleBtn
                    iconColor: textColor
                    iconName: isShuffle ? "media-playlist-shuffle" : "media-playlist-normal"
                    onClicked:
                    {
                        isShuffle = !isShuffle
                        bae.saveSetting("SHUFFLE",isShuffle, "PLAYBACK")
                    }
                }
            ]
        }
    }

    footBar.visible: !mainlistEmpty

    leftIcon.iconColor: accent && currentView === viewsIndex.search ? babeColor : altColorText
    onSearchButtonClicked:
    {
        pageStack.currentIndex = 1
        currentView = viewsIndex.search
        searchView.searchInput.forceActiveFocus()
    }

    InfoView
    {
        id: infoView
        maxWidth: parent.width * 0.8
        maxHeight: parent.height * 0.9
    }

    Maui.ShareDialog
    {
        id: shareDialog
    }

    Maui.FileDialog
    {
        id: fmDialog
    }

    SourcesDialog
    {
        id: sourcesDialog
    }

    BabeConsole
    {
        id: babeConsole
    }

    //    menuDrawer.bannerImageSource: "qrc:/assets/banner.svg"

    mainMenu: [

//        Maui.MenuItem
//        {
//            text: "Vvave Stream"
//            icon.name: "headphones"
//            onTriggered:
//            {
//                pageStack.currentIndex = 1
//                currentView = viewsIndex.vvave
//            }
//        },

        Maui.MenuItem
        {
            text: qsTr("Folders")
            icon.name: "folder"
            onTriggered:
            {
                pageStack.currentIndex = 1
                currentView = viewsIndex.folders
            }
        },

//        Maui.MenuItem
//        {
//            text: qsTr("Linking")
//            icon.name: "view-links"
//            onTriggered:
//            {
//                pageStack.currentIndex = 1
//                currentView = viewsIndex.linking
//                if(!isLinked) linkingView.linkingConf.open()
//            }
//        },

        Maui.MenuItem
        {
            text: qsTr("YouTube")
            icon.name: "internet-services"
            onTriggered:
            {
                pageStack.currentIndex = 1
                currentView = viewsIndex.youtube
            }
        },

//        Maui.MenuItem
//        {
//            text: qsTr("Cloud")
//            icon.name: "folder-cloud"
//            onTriggered:
//            {
//                pageStack.currentIndex = 1
//                currentView = viewsIndex.cloud
//            }
//        },


        //        Maui.MenuItem
        //        {
        //            text: qsTr("Spotify")
        //            icon.name: "internet-services"
        //            onTriggered:
        //            {
        //                pageStack.currentIndex = 1
        //                currentView = viewsIndex.spotify
        //            }
        //        },

        MenuSeparator{},

        Maui.MenuItem
        {
            text: qsTr("Sources...")
            icon.name: "folder-add"
            onTriggered: sourcesDialog.open()
        }

        //        Maui.Menu
        //        {
        //            title: qsTr("Collection")
        //            //            icon.name: "settings-configure"

        //            Maui.MenuItem
        //            {
        //                text: qsTr("Re-Scan")
        //                onTriggered: bae.refreshCollection();
        //            }

        //            Maui.MenuItem
        //            {
        //                text: qsTr("Refresh...")
        //                onTriggered: H.refreshCollection();
        //            }

        //            Maui.MenuItem
        //            {
        //                text: qsTr("Clean")
        //                onTriggered: bae.removeMissingTracks();
        //            }
        //        },

        //        Maui.Menu
        //        {
        //            title: qsTr("Settings...")
        //            //            Kirigami.Action
        //            //            {
        //            //                text: "Brainz"

        //            //                Kirigami.Action
        //            //                {
        //            //                    id: brainzToggle
        //            //                    text: checked ? "Turn OFF" : "Turn ON"
        //            //                    checked: bae.brainzState()
        //            //                    checkable: true
        //            //                    onToggled:
        //            //                    {
        //            //                        checked = !checked
        //            //                        bae.saveSetting("AUTO", checked, "BRAINZ")
        //            ////                        bae.brainz(checked)
        //            //                    }
        //            //                }
        //            //            }



        //            Maui.MenuItem
        //            {
        //                text: "Info label" + checked ? "ON" : "OFF"
        //                checked: infoLabels
        //                checkable: true
        //                onToggled:
        //                {
        //                    infoLabels = checked
        //                    bae.saveSetting("LABELS", infoLabels ? true : false, "PLAYBACK")

        //                }
        //            }

        //            Maui.MenuItem
        //            {
        //                text: "Autoplay"
        //                checked: autoplay
        //                checkable: true
        //                onToggled:
        //                {
        //                    autoplay = checked
        //                    bae.saveSetting("AUTOPLAY", autoplay ? true : false, "BABE")
        //                }
        //            }
        //        }
    ]

    Item
    {
        id: message
        visible: infoMsg.length && sync
        anchors.bottom: parent.bottom
        width: parent.width
        height: iconSize
        z: 999

        Rectangle
        {
            id: infoBg

            anchors.fill: parent
            z: -999
            color: altColor
            opacity: 0.8

            SequentialAnimation
            {
                id: animBg
                PropertyAnimation
                {
                    target: infoBg
                    property: "color"
                    easing.type: Easing.InOutQuad
                    to: babeColor
                    duration: 250
                }

                PropertyAnimation
                {
                    target: infoBg
                    property: "color"
                    easing.type: Easing.InOutQuad
                    to: altColor
                    duration: 500
                }
            }
        }

        Label
        {
            id: infoTxt
            anchors.centerIn: parent
            anchors.fill: parent
            height: parent.height
            width: parent.width
            font.pointSize: fontSizes.medium
            text: infoMsg
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            color: textColor

            SequentialAnimation
            {
                id: animTxt
                PropertyAnimation
                {
                    target: infoTxt
                    property: "color"
                    easing.type: Easing.InOutQuad
                    to: "white"
                    duration: 250
                }

                PropertyAnimation
                {
                    target: infoTxt
                    property: "color"
                    easing.type: Easing.InOutQuad
                    to: textColor
                    duration: 500
                }
            }
        }
    }

    PlaylistDialog
    {
        id: playlistDialog
    }

    globalDrawer: Maui.GlobalDrawer
    {
        id: _drawer
        width: Kirigami.Units.gridUnit * 14

        modal: !root.isWide
        handleVisible: modal

        contentItem: MainPlaylist
        {
            id: mainPlaylist
            Connections
            {
                target: mainPlaylist
                onCoverPressed: Player.appendAll(tracks)
                onCoverDoubleClicked: Player.playAll(tracks)
            }
        }
    }

    ColumnLayout
    {
        anchors.fill: parent

        SwipeView
        {
            id: swipeView
            Layout.fillHeight: true
            Layout.fillWidth: true
            interactive: isMobile
            currentIndex: currentView

            onCurrentItemChanged: currentItem.forceActiveFocus()

            onCurrentIndexChanged:
            {
                currentView = currentIndex
                if (!babeitView.isConnected && currentIndex === viewsIndex.vvave)
                    babeitView.logginDialog.open()
            }

            TracksView
            {
                id: tracksView
                Connections
                {
                    target: tracksView
                    onRowClicked: Player.addTrack(tracksView.list.get(index))
                    onQuickPlayTrack: Player.quickPlay(tracksView.list.get(index))
                    onPlayAll:
                    {
                        var query = Q.GET.allTracks

                        mainPlaylist.list.clear()
                        mainPlaylist.list.query = query
                        Player.playAll()
                    }
                    onAppendAll:
                    {
                        mainPlaylist.list.appendQuery(Q.GET.allTracks)
                        mainPlaylist.listView.positionViewAtEnd()
                    }

                    onQueueTrack: Player.queueTracks([tracksView.list.get(index)], index)
                }
            }

            AlbumsView
            {
                id: albumsView

                holder.emoji: "qrc:/assets/MusicBox.png"
                holder.isMask: false
                holder.title : "No Albums!"
                holder.body: "Add new music sources"
                holder.emojiSize: iconSizes.huge
                headBarTitle: count + qsTr(" albums")
                list.query: Q.GET.allAlbumsAsc
                list.sortBy: Albums.ALBUM

                Connections
                {
                    target: albumsView
                    onRowClicked: Player.addTrack(track)
                    onPlayTrack: Player.quickPlay(track)

                    onAlbumCoverClicked: albumsView.populateTable(album, artist)

                    onAlbumCoverPressedAndHold:
                    {
                        var query = Q.GET.albumTracks_.arg(album)
                        query = query.arg(artist)

                        mainPlaylist.list.clear()
                        mainPlaylist.list.query = query
                        Player.playAll()
                    }

                    onPlayAll:
                    {
                        var query = Q.GET.albumTracks_.arg(album)
                        query = query.arg(artist)
                        query = query.arg(data.artist)

                        mainPlaylist.list.clear()
                        mainPlaylist.list.query = query
                        Player.playAll()
                    }

                    onAppendAll:
                    {
                        var query = Q.GET.albumTracks_.arg(album)
                        query = query.arg(artist)

                        mainPlaylist.list.appendQuery(query)
                        mainPlaylist.listView.positionViewAtEnd()
                    }
                }
            }

            AlbumsView
            {
                id: artistsView

                holder.emoji: "qrc:/assets/MusicBox.png"
                holder.isMask: false
                holder.title : qsTr("No Artists!")
                holder.body: qsTr("Add new music sources")
                holder.emojiSize: iconSizes.huge
                headBarTitle: count + qsTr(" artists")
                list.query: Q.GET.allArtistsAsc
                list.sortBy: Albums.ARTIST
                table.list.sortBy:  Tracks.NONE

                Connections
                {
                    target: artistsView
                    onRowClicked: Player.addTrack(track)
                    onPlayTrack: Player.quickPlay(track)
                    onAlbumCoverClicked: artistsView.populateTable(undefined, artist)

                    onAlbumCoverPressedAndHold:
                    {
                        var query = Q.GET.artistTracks_.arg(artist)
                        var map = bae.get(query)
                        Player.playAll(map)
                    }

                    onPlayAll:
                    {
                        var query = Q.GET.artistTracks_.arg(artist)
                        query = query.arg(data.artist)

                        mainPlaylist.list.clear()
                        mainPlaylist.list.sortBy = Tracks.NONE
                        mainPlaylist.list.query = query
                        Player.playAll()
                    }

                    onAppendAll:
                    {
                        var query = Q.GET.artistTracks_.arg(artist)

                        mainPlaylist.list.appendQuery(query)
                        mainPlaylist.listView.positionViewAtEnd()
                    }
                }
            }

            PlaylistsView
            {
                id: playlistsView

                Connections
                {
                    target: playlistsView
                    onRowClicked: Player.addTrack(track)
                    onQuickPlayTrack: Player.quickPlay(track)

                    onPlayAll:
                    {
                        var query = playlistsView.playlistQuery


                        mainPlaylist.list.clear()
                        mainPlaylist.list.sortBy = Tracks.NONE
                        mainPlaylist.list.query = query
                        Player.playAll()
                    }

                    onAppendAll:
                    {
                        var query = playlistsView.playlistQuery

                        mainPlaylist.list.appendQuery(query)
                        mainPlaylist.listView.positionViewAtEnd()
                    }

                    onPlaySync:
                    {
                        var tracks = bae.get(Q.GET.playlistTracks_.arg(playlist))
                        Player.playAll(tracks)
                        root.sync = true
                        root.syncPlaylist = playlist
                        root.infoMsg = qsTr("Syncing to ") + playlist
                    }
                }
            }


            SearchTable
            {
                id: searchView

                Connections
                {
                    target: searchView
                    onRowClicked: Player.addTrack(searchView.list.get(index))
                    onQuickPlayTrack: Player.quickPlay(searchView.list.get(index))
                    onPlayAll:
                    {
                        var tracks = searchView.list.getAll()
                        for(var i in tracks)
                            Player.appendTrack(tracks[i])

                        Player.playAll()
                    }

                    onAppendAll: Player.appendAll(searchView.list.getAll())
                    onArtworkDoubleClicked:
                    {
                        var query = Q.GET.albumTracks_.arg(
                                    searchView.searchTable.model.get(
                                        index).album)
                        query = query.arg(searchView.searchTable.model.get(
                                              index).artist)

                        Player.playAll(bae.get(query))
                    }
                }
            }

            FoldersView
            {
                id: foldersView

                Connections
                {
                    target: foldersView.list

                    onRowClicked: Player.addTrack(foldersView.list.model.get(index))
                    onQuickPlayTrack: Player.quickPlay(foldersView.list.model.get(index))
                    onPlayAll:
                    {
                        mainPlaylist.list.clear()
                        mainPlaylist.list.sortBy = Tracks.NONE
                        mainPlaylist.list.query = foldersView.list.list.query
                        Player.playAll()
                    }

                    onAppendAll:
                    {
                        var query = foldersView.list.list.query
                        mainPlaylist.list.appendQuery(query)
                        mainPlaylist.listView.positionViewAtEnd()
                    }

                    onQueueTrack: Player.queueTracks([foldersView.list.model.get(index)], index)
                }
            }

//            CloudView
//            {
//                id: cloudView
//                onQuickPlayTrack: Player.quickPlay(cloudView.list.get(index))
//            }

//            BabeitView
//            {
//                id: babeitView
//            }

//            LinkingView
//            {
//                id: linkingView
//            }

            YouTube
            {
                id: youtubeView
            }

//            Spotify
//            {
//                id: spotifyView
//            }
        }

        Maui.SelectionBar
        {
            id: selectionBar
            Layout.fillWidth: true
            Layout.margins: space.huge
            Layout.topMargin: space.small
            Layout.bottomMargin: space.big
            onIconClicked: contextMenu.show(selectedPaths)
            onExitClicked: clear()

            TableMenu
            {
                id: contextMenu
                menuItem: Maui.MenuItem
                {
                    text: qsTr("Play all")
                    onTriggered:
                    {
                        var data = bae.getList(selectionBar.selectedPaths)
                        contextMenu.close()
                        selectionMode = false
                        selectionBar.clear()
                        Player.playAll(data)

                    }
                }

                onFavClicked: H.faveIt(paths)

                onQueueClicked: H.queueIt(paths)
                onSaveToClicked:
                {
                    playlistDialog.tracks = paths
                    playlistDialog.open()
                }
                onOpenWithClicked: bae.showFolder(paths)

                onRemoveClicked:
                {

                }
                onRateClicked: H.rateIt(paths, rate)

                onColorClicked: H.moodIt(paths, color)
            }
        }
    }


    /*animations*/


    /*FUNCTIONS*/
    function infoMsgAnim()
    {
        animBg.running = true
        animTxt.running = true
    }


    function toggleMaximized()
    {
        if (root.visibility === Window.Maximized) {
            root.showNormal();
        } else {
            root.showMaximized();
        }
    }


    /*CONNECTIONS*/

    Connections
    {
        target: bae

        onRefreshTables: H.refreshCollection(size)
        //        onRefreshTracks: H.refreshTracks()
        //        onRefreshAlbums: H.refreshAlbums()
        //        onRefreshArtists: H.refreshArtists()

        onTrackLyricsReady:
        {
            console.log(lyrics)
            if (url === currentTrack.url)
                Player.setLyrics(lyrics)
        }

        onSkipTrack: Player.nextTrack()
        onBabeIt: Player.babeTrack()

        onOpenFiles: Player.playAll(tracks)
    }
}
