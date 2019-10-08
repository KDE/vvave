import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import "utils"

import "widgets"
import "widgets/PlaylistsView"
import "widgets/MainPlaylist"
import "widgets/SettingsView"
import "widgets/SearchView"
//import "widgets/CloudView"

import "view_models"
import "view_models/BabeTable"

import "services/local"
import "services/web"
//import "services/web/Spotify"

import "view_models/BabeGrid"

import "widgets/InfoView"

import "db/Queries.js" as Q
import "utils/Help.js" as H
import "utils/Player.js" as Player

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import Player 1.0
import AlbumsList 1.0
import TracksList 1.0

import BaseModel 1.0
import TracksList 1.0

Maui.ApplicationWindow
{

    id: root
    title: qsTr("vvave")
    /***************************************************/
    /******************** ALIASES ********************/
    /*************************************************/
    property alias mainPlaylist: mainPlaylist
    property alias selectionBar: _selectionBar
    property alias progressBar: progressBar

    Maui.App.iconName: "qrc:/assets/vvave.svg"
    Maui.App.description: qsTr("VVAVE will handle your whole music collection by retreaving semantic information from the web. Just relax, enjoy and discover your new music ")
    showAccounts: false
    /***************************************************/
    /******************** PLAYBACK ********************/
    /*************************************************/
    property bool isShuffle: Maui.FM.loadSettings("SHUFFLE","PLAYBACK", false)
    property var currentTrack: ({
                                    fav: "0",
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
    property bool infoLabels: Maui.FM.loadSettings("LABELS", "PLAYBACK", false) == "true" ? true : false

    //    property bool isLinked: false
    //    property bool isServing: false

    //    property bool focusMode : false
    property bool selectionMode : false

    /***************************************************/
    /******************** UI COLORS *******************/
    /*************************************************/
    readonly property color babeColor: "#f84172"

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
            //            bae.removeTrack(currentTrack.url) //todo
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
                               if (currentTrack.url)
                                   mainPlaylist.list.countUp(currentTrackIndex)

                               Player.nextTrack()
                           }
    }

    headBar.middleContent : Kirigami.ActionToolBar
    {
        display: isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly
        position: ToolBar.Header
        Layout.fillWidth: true
        hiddenActions: [

            Kirigami.Action
            {
                text: qsTr("Folders")
                icon.name: "folder"
                checked: currentView === viewsIndex.folders
                checkable: false
                onTriggered: currentView = viewsIndex.folders
            },

            Kirigami.Action
            {
                text: qsTr("YouTube")
                checkable: false
                icon.name: "internet-services"
                checked: currentView === viewsIndex.youtube
                onTriggered: currentView = viewsIndex.youtube

            }

        ]
        actions: [
            Kirigami.Action
            {
                icon.name: "view-media-track"
                checked: currentView === viewsIndex.tracks
                //            showIndicator: true
                //            icon.color: active ? babeColor : altColorText
                onTriggered: currentView = viewsIndex.tracks
                text: qsTr("Tracks")
                checkable: false
                //            colorScheme.highlightColor: babeColor
                //            spacing: 0

            },

            Kirigami.Action
            {
                text: qsTr("Albums")
                checkable: false
                checked: currentView === viewsIndex.albums
                icon.name: /*"album"*/ "view-media-album-cover"
                //            icon.color: currentView === viewsIndex.albums ? babeColor : altColorText
                onTriggered: currentView = viewsIndex.albums
                //            colorScheme.highlightColor: babeColor
                //            showIndicator: true

            },

            Kirigami.Action
            {
                text: qsTr("Artists")
                checkable: false
                checked: currentView === viewsIndex.artists
                icon.name: "view-media-artist"
                //                Kirigami.Theme.textColor:  currentView === viewsIndex.artists ? babeColor : altColorText
                onTriggered: currentView = viewsIndex.artists
                //            colorScheme.highlightColor: babeColor
                //            showIndicator: true
            },

            Kirigami.Action
            {
                text: qsTr("Playlists")
                checkable: false
                checked: currentView === viewsIndex.playlists
                icon.name: "view-media-playlist"
                //            icon.color: currentView === viewsIndex.playlists ? babeColor : altColorText
                onTriggered: currentView = viewsIndex.playlists
                //            colorScheme.highlightColor: babeColor
                //            showIndicator: true

            }

        ]
    }

    footBar.visible: !mainlistEmpty
    footBar.implicitHeight: footBar.visible ? Maui.Style.toolBarHeight * 1.2 : 0
    footer: ColumnLayout
    {
        id: _footerLayout

        height: footBar.height
        width: root.width
        spacing: 0

        Slider
        {
            id: progressBar
            Layout.preferredHeight: Maui.Style.unit * (isMobile ?  6 : 8)
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
                implicitWidth: progressBar.pressed ? Maui.Style.iconSizes.medium : 0
                implicitHeight: progressBar.pressed ? Maui.Style.iconSizes.medium : 0
                radius: progressBar.pressed ? Maui.Style.iconSizes.medium : 0
                color: babeColor
            }
        }

        //        Kirigami.Separator
        //        {
        //            Layout.fillWidth: true
        ////            color: borderColor
        //        }

        Maui.ToolBar
        {
            Layout.fillHeight: true
            Layout.fillWidth: true

            position: ToolBar.Footer
            leftContent:  ToolButton
            {
                icon.name: "headphones"
                checked: _drawer.visible
                icon.color: _drawer.visible ? babeColor : Kirigami.Theme.textColor
                onClicked:
                {
                    console.log("SHOW DRAWER?", _drawer.visible)
                    _drawer.visible = !_drawer.visible
                }

                Kirigami.Theme.highlightColor: babeColor

                Connections
                {
                    target: mainPlaylist.table
                    onCountChanged: anim.start()
                }

                NumberAnimation on x
                {
                    property int count : 0
                    id: anim
                    to: 10
                    duration: 100
                    onStopped:
                    {
                        if(anim.to===10) { anim.from=10; anim.to=0; } else { anim.from=0; anim.to=10 }
                        count++;
                        if(count < 5)
                            start()
                        else
                        {
                            anim.to = 0
                            count = 0
                        }
                    }
                }
            }

            middleContent: [
                ToolButton
                {
                    id: babeBtnIcon
                    icon.name: "love"
                    enabled: currentTrackIndex >= 0
                    icon.color: currentBabe ? babeColor : Kirigami.Theme.textColor
                    onClicked: if (!mainlistEmpty)
                               {
                                   mainPlaylist.list.fav(currentTrackIndex, !(mainPlaylist.list.get(currentTrackIndex).fav == "1"))
                                   currentBabe = mainPlaylist.list.get(currentTrackIndex).fav == "1"
                               }
                },

                ToolButton
                {
                    icon.name: "media-skip-backward"
                    icon.color: Kirigami.Theme.textColor
                    onClicked: Player.previousTrack()
                    onPressAndHold: Player.playAt(prevTrackIndex)
                },

                ToolButton
                {
                    id: playIcon
                    enabled: currentTrackIndex >= 0
                    icon.color: Kirigami.Theme.textColor
                    icon.name: isPlaying ? "media-playback-pause" : "media-playback-start"
                    onClicked: player.playing = !player.playing
                },

                ToolButton
                {
                    id: nextBtn
                    icon.color: Kirigami.Theme.textColor
                    icon.name: "media-skip-forward"
                    onClicked: Player.nextTrack()
                    onPressAndHold: Player.playAt(Player.shuffle())
                },

                ToolButton
                {
                    id: shuffleBtn
                    icon.color: babeColor
                    icon.name: isShuffle ? "media-playlist-shuffle" : "media-playlist-normal"
                    onClicked:
                    {
                        isShuffle = !isShuffle
                        Maui.FM.saveSettings("SHUFFLE", isShuffle, "PLAYBACK")
                    }
                }
            ]
        }
    }


    //    leftIcon.icon.color: currentView === viewsIndex.search ? babeColor : altColorText
    onSearchButtonClicked:
    {
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

        MenuItem
        {
            text: qsTr("Sources...")
            icon.name: "folder-add"
            onTriggered: sourcesDialog.open()
        },

        MenuItem
        {
            text: qsTr("Open...")
            icon.name: "folder-add"
            onTriggered:
            {
                fmDialog.settings.onlyDirs = false
                fmDialog.settings.filterType = Maui.FMList.AUDIO
                fmDialog.show(function(paths)
                {
                    vvave.openUrls(paths)
                })
            }
        }/*,

                Menu
                {
                    title: qsTr("Collection")
                    //            icon.name: "settings-configure"

                    MenuItem
                    {
                        text: qsTr("Re-Scan")
                        onTriggered: bae.refreshCollection();
                    }

                    MenuItem
                    {
                        text: qsTr("Refresh...")
                        onTriggered: H.refreshCollection();
                    }

                    MenuItem
                    {
                        text: qsTr("Clean")
                        onTriggered: bae.removeMissingTracks();
                    }
                }*/

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
            font.pointSize: Maui.Style.fontSizes.medium
            text: infoMsg
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            color: Kirigami.Theme.textColor

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
                    to: Kirigami.Theme.textColor
                    duration: 500
                }
            }
        }
    }

    PlaylistDialog
    {
        id: playlistDialog
    }

    sideBar: Maui.AbstractSideBar
    {
        id: _drawer
        width: visible ? Math.min(Kirigami.Units.gridUnit * 18, root.width) : 0
        modal: !isWide

        MainPlaylist
        {
            id: mainPlaylist
            anchors.fill: parent
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
                //                if (!babeitView.isConnected && currentIndex === viewsIndex.vvave)
                //                    babeitView.logginDialog.open()
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
                holder.emojiSize: Maui.Style.iconSizes.huge
                title: count + qsTr(" albums")
                list.query: Albums.ALBUMS
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
                        mainPlaylist.list.sortBy = Tracks.NONE
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
                holder.emojiSize: Maui.Style.iconSizes.huge
                title: count + qsTr(" artists")
                list.query: Albums.ARTISTS
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
                        mainPlaylist.list.clear()
                        mainPlaylist.list.sortBy = Tracks.NONE
                        mainPlaylist.list.query = query
                        Player.playAll()
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
                        var query = playlistsView.playlistQuery
                        mainPlaylist.list.appendQuery(query)
                        Player.playAll()

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
                        mainPlaylist.list.clear()
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

                        mainPlaylist.list.clear()
                        mainPlaylist.list.sortBy = Tracks.NONE
                        mainPlaylist.list.query = query
                        Player.playAll()
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
                        //                        mainPlaylist.list.sortBy = Tracks.NONE
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
            id: _selectionBar
            property alias listView: _selectionBar.selectionList
            Layout.fillWidth: true
            Layout.margins: Maui.Style.space.big
            Layout.topMargin: Maui.Style.space.small
            Layout.bottomMargin: Maui.Style.space.big
            onIconClicked: _contextMenu.popup()
            onExitClicked: clear()
            //            Kirigami.Theme.backgroundColor: "#212121"

            //            model: BaseModel
            //            {
            //                list: _selectionBarModelList
            //            }

            //            Tracks
            //            {
            //                id: _selectionBarModelList
            //            }

            SelectionBarMenu
            {
                id: _contextMenu
            }

            //            function append(item)
            //            {
            //                _selectionBar.append(item)

            ////                if(selectedPaths.indexOf(item.path) < 0)
            ////                {
            ////                    selectedItems.push(item)
            ////                    selectedPaths.push(item.path)

            ////                    //             for(var i = 0; i < selectionList.count ; i++ )
            ////                    //                 if(selectionList.model.get(i).path === item.path)
            ////                    //                 {
            ////                    //                     selectionList.model.remove(i)
            ////                    //                     return
            ////                    //                 }

            ////                    selectionList.model.list.append(item)
            ////                    selectionList.positionViewAtEnd()

            ////                }
            //            }
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
        target: vvave

        onRefreshTables: H.refreshCollection(size)
        //        onRefreshTracks: H.refreshTracks()
        //        onRefreshAlbums: H.refreshAlbums()
        //        onRefreshArtists: H.refreshArtists()

        //        onCoverReady:
        //        {
        //            root.currentArtwork = path
        //            currentTrack.artwork = currentArtwork
        //            mainPlaylist.list.update(currentTrack, currentTrackIndex);
        //        }

        //        onTrackLyricsReady:
        //        {
        //            console.log(lyrics)
        //            if (url === currentTrack.url)
        //                Player.setLyrics(lyrics)
        //        }

        //        onSkipTrack: Player.nextTrack()
        //        onBabeIt: if (!mainlistEmpty)
        //                  {
        //                      mainPlaylist.list.fav(currentTrackIndex, !(mainPlaylist.list.get(currentTrackIndex).fav == "1"))
        //                      currentBabe = mainPlaylist.list.get(currentTrackIndex).fav == "1"
        //                  }

        onOpenFiles:
        {
            Player.appendTracksAt(tracks, 0)
            Player.playAt(0)
        }
    }
}
