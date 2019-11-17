import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import "utils"

import "widgets"
import "widgets/PlaylistsView"
import "widgets/MainPlaylist"
import "widgets/SettingsView"
import "widgets/SearchView"
import "widgets/CloudView"

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
import PlaylistsList 1.0

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
    property alias dialog : _dialogLoader.item

    Maui.App.iconName: "qrc:/assets/vvave.svg"
    Maui.App.description: qsTr("VVAVE will handle your whole music collection by retreaving semantic information from the web. Just relax, enjoy and discover your new music ")
    /***************************************************/
    /******************** PLAYBACK ********************/
    /*************************************************/
    property bool isShuffle: Maui.FM.loadSettings("SHUFFLE","PLAYBACK", false)
    property var currentTrack: mainlistEmpty?  ({url: "", artwork: "", fav: "0", stars: "0"}) : mainPlaylist.table.listModel.get(currentTrackIndex)

    property int currentTrackIndex: -1
    property int prevTrackIndex: 0

    readonly property string currentArtwork: currentTrack.artwork

    property alias durationTimeLabel: player.duration
    property string progressTimeLabel: player.transformTime((player.duration/1000) *(player.pos/ 1000))

    property alias isPlaying: player.playing
    property int onQueue: 0

    property bool mainlistEmpty: !mainPlaylist.table.count > 0

    /***************************************************/
    /******************** HANDLERS ********************/
    /*************************************************/
    readonly property var viewsIndex: ({ tracks: 0,
                                           albums: 1,
                                           artists: 2,
                                           playlists: 3,
                                           cloud: 4,
                                           folders: 5,
                                           youtube: 6,
                                           search: 7})

    property string syncPlaylist: ""
    property bool sync: false

    property bool focusView : false
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
        var message = qsTr("Missing file...")
        var messageBody = track.title + " by " + track.artist + " is missing.\nDo you want to remove it from your collection?"
        notify("dialog-question", message, messageBody, function ()
        {
            mainPlaylist.list.remove(mainPlaylist.table.currentIndex)
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

    FloatingDisk
    {
        id: _floatingDisk
        opacity: 1 - _drawer.position
    }

    headBar.middleContent : Maui.ActionGroup
    {
        id: _actionGroup
        Layout.fillHeight: true
//        Layout.fillWidth: true
        Layout.minimumWidth: implicitWidth
        currentIndex : swipeView.currentIndex
        onCurrentIndexChanged: swipeView.currentIndex = currentIndex
//        strech: true

        hiddenActions: [
            Action
            {
                text: qsTr("Cloud")
                icon.name: "folder-cloud"
            },

            Action
            {
                text: qsTr("Folders")
                icon.name: "folder"
            },

            Action
            {
                text: qsTr("YouTube")
                icon.name: "internet-services"
            }
        ]

        Action
        {
            icon.name: "view-media-track"
            text: qsTr("Tracks")
        }

        Action
        {
            text: qsTr("Albums")
            icon.name: /*"album"*/ "view-media-album-cover"
        }

        Action
        {
            text: qsTr("Artists")
            icon.name: "view-media-artist"
        }

        Action
        {
            text: qsTr("Playlists")
            icon.name: "view-media-playlist"
        }
    }


    onSearchButtonClicked:
    {
        _actionGroup.currentIndex = viewsIndex.search
        //        searchView.searchInput.forceActiveFocus()
    }

    Loader
    {
        id: _dialogLoader
    }

    InfoView
    {
        id: infoView
        maxWidth: parent.width * 0.8
        maxHeight: parent.height * 0.9
    }

    Loader
    {
        id: _focusViewLoader
        active: focusView
        source: "widgets/FocusView.qml"
    }

    Component
    {
        id: _shareDialogComponent
        Maui.ShareDialog {}
    }

    Component
    {
        id: _fmDialogComponent
        Maui.FileDialog { }
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

        MenuItem
        {
            text: qsTr("Sources")
            icon.name: "folder-add"
            onTriggered: sourcesDialog.open()
        },

        MenuItem
        {
            text: qsTr("Open")
            icon.name: "folder-add"
            onTriggered:
            {
                _dialogLoader.sourceComponent = _fmDialogComponent
                root.dialog.settings.onlyDirs = false
                root.dialog.settings.filterType = Maui.FMList.AUDIO
                root.dialog.show(function(paths)
                {
                    vvave.openUrls(paths)
                    root.dialog.close()
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

    Playlists
    {
        id: playlistsList
    }

    PlaylistDialog
    {
        id: playlistDialog
    }

    sideBar: Maui.AbstractSideBar
    {
        id: _drawer
        focus: true
        width: visible ? Math.min(Kirigami.Units.gridUnit * (Kirigami.Settings.isMobile? 18 : 20), root.width) : 0
        modal: !isWide
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        height: _drawer.modal ? implicitHeight - _mainPage.footer.height : implicitHeight

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

    Maui.Page
    {
        id: _mainPage
        anchors.fill: parent

        footer: ColumnLayout
        {
            id: _footerLayout
            visible: !mainlistEmpty || isPlaying
            height: visible ? Maui.Style.toolBarHeight * 1.2 : 0
            width: parent.width
            spacing: 0

            Kirigami.Separator
            {
                Layout.fillWidth: true
            }

            Slider
            {
                id: progressBar
                Layout.preferredHeight: Maui.Style.unit * (Kirigami.Settings.isMobile ?  6 : 8)
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
                        color: Kirigami.Theme.highlightColor
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
                    color: Kirigami.Theme.highlightColor
                }
            }

            Maui.ToolBar
            {
                Layout.fillHeight: true
                Layout.fillWidth: true

                position: ToolBar.Footer

                rightContent: ToolButton
                {
                    icon.name: "media-speaker"
                    onClicked: _sliderPopup.open()

                    Popup
                    {
                        id: _sliderPopup
                        height: 150
                        width: parent.width
                        y: -150
                        x: 0
                        //                            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPress
                        Slider
                        {
                            id: _volumeSlider
                            visible: true
                            height: parent.height
                            width: 20
                            anchors.horizontalCenter: parent.horizontalCenter
                            from: 0
                            to: 100
                            value: player.volume
                            orientation: Qt.Vertical

                            onMoved:
                            {
                                player.volume = value
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
                        icon.color: currentTrack.fav == "0" ? Kirigami.Theme.textColor :  babeColor
                        onClicked: if (!mainlistEmpty)
                                   {
                                       mainPlaylist.list.fav(currentTrackIndex, !(mainPlaylist.listModel.get(currentTrackIndex).fav == "1"))
                                       currentTrack = mainPlaylist.listModel.get(currentTrackIndex)
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

        ColumnLayout
        {
            anchors.fill: parent

            SwipeView
            {
                id: swipeView
                Layout.fillHeight: true
                Layout.fillWidth: true
                //                interactive: Kirigami.Settings.isMobile
                currentIndex: _actionGroup.currentIndex
                onCurrentIndexChanged: _actionGroup.currentIndex = currentIndex

                clip: true
                onCurrentItemChanged: currentItem.forceActiveFocus()

                TracksView
                {
                    id: tracksView

                    Connections
                    {
                        target: vvave
                        onRefreshTables: tracksView.list.refresh()
                    }

                    Connections
                    {
                        target: tracksView
                        onRowClicked: Player.quickPlay(tracksView.listModel.get(index))
                        onQuickPlayTrack: Player.quickPlay(tracksView.listModel.get(index))
                        onAppendTrack: Player.addTrack(tracksView.listModel.get(index))
                        onPlayAll: Player.playAll( tracksView.listModel.getAll())
                        onAppendAll: Player.appendAll( tracksView.listModel.getAll())
                        onQueueTrack: Player.queueTracks([tracksView.listModel.get(index)], index)
                    }
                }

                Loader
                {
                    active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem || item
                    sourceComponent: AlbumsView
                    {
                        id: albumsView

                        holder.emoji: "qrc:/assets/dialog-information.svg"
                        holder.isMask: false
                        holder.title : "No Albums!"
                        holder.body: "Add new music sources"
                        holder.emojiSize: Maui.Style.iconSizes.huge
                        title: count + qsTr(" albums")
                        list.query: Albums.ALBUMS
                        list.sortBy: Albums.ALBUM

                        Connections
                        {
                            target: vvave
                            onRefreshTables: albumsView.list.refresh()
                        }

                        Connections
                        {
                            target: albumsView
                            onRowClicked: Player.quickPlay(track)
                            onAppendTrack: Player.addTrack(track)
                            onPlayTrack: Player.quickPlay(track)

                            onAlbumCoverClicked: albumsView.populateTable(album, artist)

                            onAlbumCoverPressedAndHold:
                            {
                                var query = Q.GET.albumTracks_.arg(album)
                                query = query.arg(artist)

                                mainPlaylist.list.clear()
                                mainPlaylist.list.sortBy = Tracks.NONE
                                mainPlaylist.list.query = query
                                Player.playAt(0)
                            }

                            onPlayAll: Player.playAll(albumsView.listModel.getAll())
                            onAppendAll: Player.appendAll(albumsView.listModel.getAll())
                        }
                    }
                }

                Loader
                {
                    active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem || item
                    sourceComponent: AlbumsView
                    {
                        id: artistsView

                        holder.emoji: "qrc:/assets/dialog-information.svg"
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
                            target: vvave
                            onRefreshTables: artistsView.list.refresh()
                        }

                        Connections
                        {
                            target: artistsView
                            onRowClicked: Player.quickPlay(track)
                            onAppendTrack: Player.addTrack(track)
                            onPlayTrack: Player.quickPlay(track)
                            onAlbumCoverClicked: artistsView.populateTable(undefined, artist)

                            onAlbumCoverPressedAndHold:
                            {
                                var query = Q.GET.artistTracks_.arg(artist)
                                mainPlaylist.list.clear()
                                mainPlaylist.list.sortBy = Tracks.NONE
                                mainPlaylist.list.query = query
                                Player.playAt(0)
                            }

                            onPlayAll: Player.artistsView(albumsView.listModel.getAll())
                            onAppendAll: Player.artistsView(albumsView.listModel.getAll())
                        }
                    }
                }

                Loader
                {
                    active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem || item
                    sourceComponent: PlaylistsView
                    {
                        id: playlistsView

                        Connections
                        {
                            target: playlistsView

                            onRowClicked: Player.quickPlay(track)
                            onAppendTrack: Player.addTrack(track)
                            onPlayTrack: Player.quickPlay(track)
                            onAppendAll: Player.appendAll(playlistsView.listModel.getAll())
                            onSyncAndPlay:
                            {
                                Player.playAll(playlistsView.listModel.getAll())

                                root.sync = true
                                root.syncPlaylist = playlist
                            }

                            onPlayAll: Player.playAll(playlistsView.listModel.getAll())
                        }
                    }
                }

                Loader
                {
                    active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem || item
                    sourceComponent: CloudView
                    {
                        id: cloudView
                    }
                }

                Loader
                {
                    active: SwipeView.isCurrentItem || item
                    sourceComponent:  FoldersView
                    {
                        id: foldersView

                        Connections
                        {
                            target: vvave
                            onRefreshTables: foldersView.populate()
                        }

                        Connections
                        {
                            target: foldersView.list

                            onRowClicked: Player.quickPlay(foldersView.list.model.get(index))
                            onQuickPlayTrack: Player.quickPlay(foldersView.list.model.get(index))

                            onAppendTrack: Player.addTrack(foldersView.listModel.get(index))
                            onPlayAll: Player.playAll(foldersView.listModel.getAll())

                            onAppendAll: Player.appendAll(foldersView.listModel.getAll())
                            onQueueTrack: Player.queueTracks([foldersView.list.model.get(index)], index)
                        }
                    }
                }

                Loader
                {
                    active: SwipeView.isCurrentItem || item
                    sourceComponent: YouTube
                    {
                        id: youtubeView
                    }
                }

                Loader
                {
                    active: SwipeView.isCurrentItem || (item && item.listView.count > 0)
                    sourceComponent: SearchTable
                    {
                        id: searchView

                        Connections
                        {
                            target: searchView
                            onRowClicked: Player.quickPlay(searchView.listModel.get(index))
                            onQuickPlayTrack: Player.quickPlay(searchView.listModel.get(index))
                            onAppendTrack: Player.addTrack(searchView.listModel.get(index))
                            onPlayAll: Player.playAll(searchView.listModel.getAll())

                            onAppendAll: Player.appendAll(searchView.listModel.getAll())
                            onArtworkDoubleClicked:
                            {
                                var query = Q.GET.albumTracks_.arg(
                                            searchView.listModel.get(
                                                index).album)
                                query = query.arg(searchView.listModel.get(index).artist)

                                mainPlaylist.list.clear()
                                mainPlaylist.list.sortBy = Tracks.NONE
                                mainPlaylist.list.query = query
                                Player.playAt(0)
                            }
                        }
                    }
                }
            }

            SelectionBar
            {
                id: _selectionBar
                property alias listView: _selectionBar.selectionList
                Layout.maximumWidth: 500
                Layout.minimumWidth: 100
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                Layout.margins: Maui.Style.space.big
                Layout.topMargin: Maui.Style.space.small
                Layout.bottomMargin: Maui.Style.space.big

                onExitClicked:
                {
                    root.selectionMode = false
                    clear()
                }
            }
        }
    }

    /*CONNECTIONS*/
    Connections
    {
        target: vvave

        onRefreshTables:
        {
            if(size>0) root.notify("emblem-info", "Collection updated", size+" new tracks added...")
        }

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

    Component.onCompleted:
    {
        if(isAndroid)
        {
            Maui.Android.statusbarColor(Kirigami.Theme.backgroundColor, true)
            Maui.Android.navBarColor(Kirigami.Theme.backgroundColor, true)
        }
    }
}
