import QtQuick 2.9
import QtQuick.Controls 2.2
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

import "view_models"
import "view_models/BabeDialog"
import "view_models/BabeTable"

import "services/local"
import "services/web"
import "services/web/Spotify"

import "view_models/BabeGrid"

import "db/Queries.js" as Q
import "utils/Help.js" as H
import "utils/Player.js" as Player

import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.ApplicationWindow
{

    id: root
    //    minimumWidth: !isMobile ? columnWidth : 0
    //    minimumHeight: !isMobile ? columnWidth + 64 : 0
    //        flags: Qt.FramelessWindowHint
    title: qsTr("vvave")
    /***************************************************/
    /******************** ALIASES ********************/
    /*************************************************/
    property alias playIcon: playIcon
    property alias babeBtnIcon: babeBtnIcon
    property alias progressBar: mainPlaylist.progressBar
    property alias animFooter: mainPlaylist.animFooter
    property alias mainPlaylist: mainPlaylist
    property alias selectionBar: selectionBar

    /***************************************************/
    /******************** PLAYBACK ********************/
    /*************************************************/
    property bool isShuffle: bae.loadSetting("SHUFFLE","PLAYBACK", false) == "true" ? true : false
    property var currentTrack: ({
                                    babe: "0",
                                    stars: "0"
                                })

    property int currentTrackIndex: 0
    property int prevTrackIndex: 0
    property string currentArtwork: !mainlistEmpty ? mainPlaylist.list.model.get(0).artwork : ""
    property bool currentBabe: currentTrack.babe == "0" ? false : true
    property string durationTimeLabel: "00:00"
    property string progressTimeLabel: "00:00"
    property bool isPlaying: false
    property bool autoplay: bae.loadSetting("AUTOPLAY", "BABE",
                                            false) === "true" ? true : false
    property int onQueue: 0

    property bool mainlistEmpty: !mainPlaylist.table.count > 0

    /***************************************************/
    /******************** UI PROPS ********************/
    /*************************************************/

    readonly property real opacityLevel: 0.8
    property int miniArtSize: iconSizes.large

    property int columnWidth: Kirigami.Units.gridUnit * 17
    property int coverSize: focusMode ? columnWidth :
                                        (isAndroid ? Math.sqrt(root.width * root.height) * 0.4 :
                                                     columnWidth * (isMobile ? 0.7 : 0.6))


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
                                           vvave: 6,
                                           linking: 7,
                                           youtube: 8,
                                           spotify: 9

                                       })

    property string syncPlaylist: ""
    property bool sync: false
    property string infoMsg: ""
    property bool infoLabels: bae.loadSetting("LABELS", "PLAYBACK", false) == "true" ? true : false

    property bool isLinked: false
    property bool isServing: false

    property bool focusMode : false
    property bool selectionMode : false

    /***************************************************/
    /******************** UI COLORS *******************/
    /*************************************************/
    property string babeColor: bae.babeColor() //"#140032"

    /*SIGNALS*/
    signal missingAlert(var track)

    /*CONF*/
    pageStack.defaultColumnWidth: columnWidth
    pageStack.initialPage: [mainPlaylist, views]
    pageStack.interactive: isMobile
    pageStack.separatorVisible: pageStack.wideMode


    /*HANDLE EVENTS*/
    onWidthChanged: if (isMobile) {
                        if (width > height)
                            mainPlaylist.cover.visible = false
                        else
                            mainPlaylist.cover.visible = true
                    }

    onClosing: Player.savePlaylist()


    //    pageStack.onCurrentIndexChanged:
    //    {
    //        if(pageStack.currentIndex === 0 && isMobile && !pageStack.wideMode)
    //        {
    //            bae.androidStatusBarColor(babeColor)
    //            Material.background = babeColor
    //        }else
    //        {
    //            bae.androidStatusBarColor(babeAltColor)
    //            Material.background = babeAltColor
    //        }
    //    }
    onMissingAlert:
    {
        missingDialog.message = track.title + " by " + track.artist + " is missing"
        missingDialog.messageBody = "Do you want to remove it from your collection?"
        missingDialog.open()
    }

    /*COMPONENTS*/
    BabeNotify
    {
        id: babeNotify
    }

    BabeMessage
    {
        id: missingDialog
        width: parent.width * (isMobile ? 0.9 : 0.4)
        title: "Missing file"
        onAccepted: {
            bae.removeTrack(currentTrack.url)
            mainPlaylist.table.model.remove(mainPlaylist.table.currentIndex)
        }
    }


    /* UI */
    property bool accent : pageStack.wideMode || (!pageStack.wideMode && pageStack.currentIndex === 1)
    altToolBars: false
    accentColor: "#212121"
    headBarFGColor: altColorText
    headBarBGColor: currentView === viewsIndex.vvave ? "#7e57c2" : accentColor
    colorSchemeName: "vvave"
    altColorText: darkTextColor   

    headBar.middleContent : [

        Maui.ToolButton
        {
            iconName: "headphones"
            iconColor: !accent ? babeColor : altColorText
            display: pageStack.wideMode ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly

            onClicked: pageStack.currentIndex = 0

            text: qsTr("Now")
        },

        Maui.ToolButton
        {
            iconName: "view-media-track"
            iconColor:  accent && currentView === viewsIndex.tracks ? babeColor : altColorText
            display: pageStack.wideMode ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly

            onClicked:
            {
                pageStack.currentIndex = 1
                currentView = viewsIndex.tracks
            }

            text: qsTr("Tracks")
        },

        Maui.ToolButton
        {
            text: qsTr("Albums")
            iconName: /*"album"*/ "view-media-album-cover"
            iconColor:  accent && currentView === viewsIndex.albums ? babeColor : altColorText
            display: pageStack.wideMode ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly

            onClicked:
            {
                pageStack.currentIndex = 1
                albumsView.currentIndex = 0
                currentView = viewsIndex.albums
            }
        },

        Maui.ToolButton
        {
            text: qsTr("Artists")
            iconName: "view-media-artist"
            iconColor:  accent && currentView === viewsIndex.artists ? babeColor : altColorText
            display: pageStack.wideMode ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly

            onClicked:
            {
                pageStack.currentIndex = 1
                artistsView.currentIndex = 0
                currentView = viewsIndex.artists
            }
        },

        Maui.ToolButton
        {
            text: qsTr("Playlists")
            iconName: "view-media-playlist"
            iconColor:  accent && currentView === viewsIndex.playlists ? babeColor : altColorText
            display: pageStack.wideMode ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly

            onClicked:
            {
                pageStack.currentIndex = 1
                currentView = viewsIndex.playlists
            }
        }
    ]

    onSearchButtonClicked:
    {
        pageStack.currentIndex = 1
        currentView = viewsIndex.search
        searchView.searchInput.forceActiveFocus()
        riseContent()
    }

    FloatingDisk
    {
        id: floatingDisk
        x: space.big
        y: pageStack.height - height

        z: 999
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

    menuDrawer.actions: [

        Kirigami.Action
        {
            text: "Vvave Stream"
            iconName: "love"
            onTriggered:
            {
                pageStack.currentIndex = 1
                currentView = viewsIndex.vvave
            }
        },

        Kirigami.Action
        {
            text: qsTr("Folders")
            iconName: "folder"
            onTriggered:
            {
                pageStack.currentIndex = 1
                currentView = viewsIndex.folders
            }
        },

        Kirigami.Action
        {
            text: qsTr("Linking")
            iconName: isMobile ? "computer-laptop" : "phone"
            onTriggered:
            {
                pageStack.currentIndex = 1
                currentView = viewsIndex.linking
                if(!isLinked) linkingView.linkingConf.open()
            }
        },

        Kirigami.Action
        {
            text: qsTr("YouTube")
            iconName: "im-youtube"
            onTriggered:
            {
                pageStack.currentIndex = 1
                currentView = viewsIndex.youtube
            }
        },

        Kirigami.Action
        {
            text: qsTr("Spotify")
            onTriggered:
            {
                pageStack.currentIndex = 1
                currentView = viewsIndex.spotify
            }
        },

        Kirigami.Action
        {
            text: qsTr("Collection")
            iconName: "database-index"

            Kirigami.Action
            {
                text: qsTr("Sources...")
                onTriggered: sourcesDialog.open()
                iconName: "folder-new"
            }

            Kirigami.Action
            {
                text: qsTr("Re-Scan")
                onTriggered: bae.refreshCollection();
            }

            Kirigami.Action
            {
                text: qsTr("Refresh...")
                iconName: "view-refresh"

                Kirigami.Action
                {
                    text: qsTr("Tracks")
                    onTriggered: H.refreshTracks();
                }

                Kirigami.Action
                {
                    text: qsTr("Albums")
                    onTriggered: H.refreshAlbums();
                }

                Kirigami.Action
                {
                    text: qsTr("Artists")
                    onTriggered: H.refreshArtists();
                }

                Kirigami.Action
                {
                    text: qsTr("All")
                    onTriggered: H.refreshCollection();
                }
            }

            Kirigami.Action
            {
                text: qsTr("Clean")
                onTriggered: bae.removeMissingTracks();
                iconName: "edit-clear"
            }
        },

        Kirigami.Action
        {
            text: qsTr("Settings...")
            iconName: "view-media-config"
            //            Kirigami.Action
            //            {
            //                text: "Brainz"

            //                Kirigami.Action
            //                {
            //                    id: brainzToggle
            //                    text: checked ? "Turn OFF" : "Turn ON"
            //                    checked: bae.brainzState()
            //                    checkable: true
            //                    onToggled:
            //                    {
            //                        checked = !checked
            //                        bae.saveSetting("AUTO", checked, "BRAINZ")
            ////                        bae.brainz(checked)
            //                    }
            //                }
            //            }

            Kirigami.Action
            {
                text: "Appearance"

                Kirigami.Action
                {
                    text: "Icon size"
                    Kirigami.Action
                    {
                        text: iconSizes.small
                        onTriggered :
                        {
                            bae.saveSetting("ICON_SIZE", text, "BABE")
                            toolBarIconSize = text
                        }
                    }

                    Kirigami.Action
                    {
                        text: iconSizes.medium
                        onTriggered :
                        {
                            bae.saveSetting("ICON_SIZE", text, "BABE")
                            iconSizeChanged(text)
                        }
                    }

                    Kirigami.Action
                    {
                        text: iconSizes.big
                        onTriggered :
                        {
                            bae.saveSetting("ICON_SIZE", text, "BABE")
                            iconSizeChanged(text)
                        }
                    }
                }
            }

            Kirigami.Action
            {
                text: "Player"

                Kirigami.Action
                {
                    text: "Info label"

                    Kirigami.Action
                    {
                        text: checked ? "ON" : "OFF"
                        checked: infoLabels
                        checkable: true
                        onToggled:
                        {
                            infoLabels = checked
                            bae.saveSetting("LABELS", infoLabels ? true : false, "PLAYBACK")

                        }
                    }
                }

                Kirigami.Action
                {
                    text: "Autoplay"
                    checked: autoplay
                    checkable: true
                    onToggled:
                    {
                        autoplay = checked
                        bae.saveSetting("AUTOPLAY", autoplay ? true : false, "BABE")
                    }

                }
            }
        },

        Kirigami.Action
        {
            text: "Developer"
            iconName: "code-context"

            Kirigami.Action
            {
                text: "Wiki"
            }

            Kirigami.Action
            {
                text: "Console log"
                onTriggered: babeConsole.open()
            }
        },

        Kirigami.Action
        {
            text: "About..."
            iconName: "help-about"

            Kirigami.Action
            {
                text: "VVAVEIt"
            }

            Kirigami.Action
            {
                text: "VVAVE"
            }

            Kirigami.Action
            {
                text: "Pulpo"
            }

            Kirigami.Action
            {
                text: "Kirigami"
            }
        }
    ]

    Item
    {
        id: message
        visible: infoMsg.length > 0 && sync
        anchors.bottom: parent.bottom
        width: pageStack.wideMode ? columnWidth : parent.width
        height: iconSize
        z: 999

        Rectangle
        {
            id: infoBg

            anchors.fill: parent
            z: -999
            color: altColor
            opacity: opacityLevel

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

    MainPlaylist
    {
        id: mainPlaylist

        Connections
        {
            target: mainPlaylist
            onCoverPressed: Player.appendAll(tracks)
            onCoverDoubleClicked: Player.playAll(tracks)
        }

        floatingBar: true
        footBarOverlap: true
        altToolBars: true

        footBarVisible: !mainlistEmpty
        headBarVisible: !mainlistEmpty

        footBar.leftContent: Label
        {
            visible: !mainlistEmpty && infoLabels
            text: progressTimeLabel
            color: darkTextColor
            clip: true
        }

        footBar.rightContent: Label
        {
            visible: !mainlistEmpty && infoLabels
            text: durationTimeLabel
            color: darkTextColor
            clip: true
        }

        footBar.middleContent: [

            Maui.ToolButton
            {
                id: babeBtnIcon
                iconName: "love"

                iconColor: currentBabe ? babeColor : darkTextColor
                onClicked: if (!mainlistEmpty)
                {
                    var value = H.faveIt([mainPlaylist.list.model.get(currentTrackIndex).url])
                    currentBabe = value
                    mainPlaylist.list.model.get(currentTrackIndex).babe = value ? "1" : "0"
                }
            },

            Maui.ToolButton
            {
                iconName: "media-skip-backward"
                iconColor: darkTextColor
                onClicked: Player.previousTrack()
                onPressAndHold: Player.playAt(prevTrackIndex)
            },

            Maui.ToolButton
            {
                id: playIcon
                iconColor: darkTextColor
                iconName: isPlaying ? "media-playback-pause" : "media-playback-start"
                onClicked:
                {
                    if (isPlaying)
                    Player.pauseTrack()
                    else
                    Player.resumeTrack()
                }
            },

            Maui.ToolButton
            {
                id: nextBtn
                iconColor: darkTextColor
                iconName: "media-skip-forward"
                onClicked: Player.nextTrack()
                onPressAndHold: Player.playAt(Player.shuffle())
            },

            Maui.ToolButton
            {
                id: shuffleBtn
                iconColor: darkTextColor
                iconName: isShuffle ? "media-playlist-shuffle" : "media-playlist-repeat"
                onClicked:
                {
                    isShuffle = !isShuffle
                    bae.saveSetting("SHUFFLE",isShuffle, "PLAYBACK")
                }
            }
        ]
    }

    Maui.Page
    {
        id: views
        headBarVisible: false
        margins: 0
        //        focusPolicy: Qt.WheelFocus
        //        visualFocus: true

        ColumnLayout
        {
            anchors.fill: parent

            SwipeView
            {
                id: swipeView
                Layout.fillHeight: true
                Layout.fillWidth: true
                interactive: isMobile
                //                contentItem: ListView
                //                {
                //                    model: swipeView.contentModel
                //                    interactive: swipeView.interactive
                //                    currentIndex: swipeView.currentIndex

                //                    spacing: swipeView.spacing
                //                    orientation: swipeView.orientation
                //                    snapMode: ListView.SnapOneItem
                //                    boundsBehavior: Flickable.StopAtBounds

                //                    highlightRangeMode: ListView.StrictlyEnforceRange
                //                    preferredHighlightBegin: 0
                //                    preferredHighlightEnd: 0
                //                    highlightMoveDuration: 250
                //                    //                    min:10

                //                    maximumFlickVelocity: 10 * (swipeView.orientation ===
                //                                               Qt.Horizontal ? width : height)
                //                }

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
                        onRowClicked: Player.addTrack(tracksView.model.get(index))
                        onQuickPlayTrack: Player.quickPlay(tracksView.model.get(index))
                        onPlayAll: Player.playAll(bae.get(Q.GET.allTracks))
                        onAppendAll: Player.appendAll(bae.get(Q.GET.allTracks))
                        onQueueTrack: Player.queueTracks([tracksView.model.get(index)], index)
                    }
                }

                AlbumsView
                {
                    id: albumsView

                    grid.holder.emoji: "qrc:/assets/MusicBox.png"
                    grid.holder.isMask: false
                    grid.holder.title : "No Albums!"
                    grid.holder.body: "Add new music sources"
                    grid.holder.emojiSize: iconSizes.huge

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

                            var map = bae.get(query)
                            Player.playAll(map)
                        }

                        onPlayAll:
                        {
                            var query = Q.GET.albumTracks_.arg(album)
                            query = query.arg(artist)

                            query = query.arg(data.artist)
                            var tracks = bae.get(query)
                            Player.playAll(tracks)
                        }

                        onAppendAll:
                        {
                            var query = Q.GET.albumTracks_.arg(album)
                            query = query.arg(artist)
                            var tracks = bae.get(query)
                            Player.appendAll(tracks)
                        }
                    }
                }

                AlbumsView
                {
                    id: artistsView

                    grid.holder.emoji: "qrc:/assets/MusicBox.png"
                    grid.holder.isMask: false
                    grid.holder.title : "No Artists!"
                    grid.holder.body: "Add new music sources"
                    grid.holder.emojiSize: iconSizes.huge

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
                            var tracks = bae.get(query)
                            Player.playAll(tracks)
                        }

                        onAppendAll:
                        {
                            var query = Q.GET.artistTracks_.arg(artist)
                            var tracks = bae.get(query)
                            Player.appendAll(tracks)
                        }
                    }
                }

                PlaylistsView
                {
                    id: playlistsView
                    Connections {
                        target: playlistsView
                        onRowClicked: Player.addTrack(track)
                        onQuickPlayTrack: Player.quickPlay(track)
                        onPlayAll: Player.playAll(tracks)
                        onAppendAll: Player.appendAll(tracks)
                        onPlaySync:
                        {
                            var tracks = bae.get(Q.GET.playlistTracks_.arg(playlist))
                            Player.playAll(tracks)
                            root.sync = true
                            root.syncPlaylist = playlist
                            root.infoMsg = "Syncing to " + playlist
                        }
                    }
                }


                SearchTable
                {
                    id: searchView

                    Connections
                    {
                        target: searchView.searchTable
                        onRowClicked: Player.addTrack(searchView.searchTable.model.get(index))
                        onQuickPlayTrack: Player.quickPlay(searchView.searchTable.model.get(index))
                        onPlayAll: Player.playAll(searchView.searchRes)
                        onAppendAll: Player.appendAll(searchView.searchRes)
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
                        onPlayAll: Player.playAll(foldersView.getTracks())
                        onAppendAll: Player.appendAll(foldersView.getTracks())
                        onQueueTrack: Player.queueTracks([foldersView.list.model.get(index)], index)
                    }
                }

                BabeitView
                {
                    id: babeitView
                }

                LinkingView
                {
                    id: linkingView
                }

                YouTube
                {
                    id: youtubeView
                }

                Spotify
                {
                    id: spotifyView
                }
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
                    menuItem: MenuItem
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
        target: player
        onPos: progressBar.value = pos
        onTiming: progressTimeLabel = time
        onDurationChanged: durationTimeLabel = time

        onFinished: if (!mainlistEmpty)
                    {
                        if (currentTrack.url)
                            bae.playedTrack(currentTrack.url)

                        Player.nextTrack()
                    }

        onIsPlaying: isPlaying = playing
    }

    Connections
    {
        target: bae

        onRefreshTables: H.refreshCollection(size)
        onRefreshTracks: H.refreshTracks()
        onRefreshAlbums: H.refreshAlbums()
        onRefreshArtists: H.refreshArtists()

        onTrackLyricsReady:
        {
            if (url === currentTrack.url)
                Player.setLyrics(lyrics)
        }

        onSkipTrack: Player.nextTrack()
        onBabeIt: Player.babeTrack()

        onOpenFiles: Player.playAll(tracks)
    }
}
