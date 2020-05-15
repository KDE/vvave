import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.maui.vvave 1.0 as Vvave

import Player 1.0
import AlbumsList 1.0
import TracksList 1.0
import PlaylistsList 1.0

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

import "view_models/BabeGrid"

import "widgets/InfoView"

import "db/Queries.js" as Q
import "utils/Help.js" as H
import "utils/Player.js" as Player

Maui.ApplicationWindow
{

    id: root
    title: currentTrack ? currentTrack.title + " - " +  currentTrack.artist + " | " + currentTrack.album : ""
    /***************************************************/
    /******************** ALIASES ********************/
    /*************************************************/
    property alias mainPlaylist: mainPlaylist
    property alias selectionBar: _selectionBar
    property alias progressBar: progressBar
    property alias dialog : _dialogLoader.item

    Maui.App.iconName: "qrc:/assets/vvave.svg"
    Maui.App.description: qsTr("VVAVE will handle your whole music collection by retreaving semantic information from the web. Just relax, enjoy and discover your new music ")
    background.opacity: translucency ? 0.5 : 1
//    floatingHeader: swipeView.currentIndex === viewsIndex.albums || swipeView.currentIndex === viewsIndex.artists
//    autoHideHeader: true
    floatingFooter: false

    /***************************************************/
    /******************** PLAYBACK ********************/
    /*************************************************/
    property bool isShuffle: Maui.FM.loadSettings("SHUFFLE","PLAYBACK", false)
    property var currentTrack: mainPlaylist.listView.itemAtIndex(currentTrackIndex)

    property int currentTrackIndex: -1
    property int prevTrackIndex: 0

    readonly property string currentArtwork: currentTrack ?  currentTrack.artwork : ""

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
                                           youtube: 6})

    property string syncPlaylist: ""
    property bool sync: false

    property bool focusView : false
    property bool selectionMode : false

    /***************************************************/
    /******************** UI COLORS *******************/
    /*************************************************/
    readonly property color babeColor: "#f84172"
    property bool translucency : Maui.Handy.isLinux

    /*SIGNALS*/
    signal missingAlert(var track)

    //    flickable: swipeView.currentItem.flickable ||  swipeView.currentItem.item.flickable

    footerPositioning: ListView.InlineFooter
    /*HANDLE EVENTS*/
    onClosing: Player.savePlaylist()
    onMissingAlert:
    {
        var message = qsTr("Missing file")
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
                               if (currentTrack && currentTrack.url)
                                   mainPlaylist.list.countUp(currentTrackIndex)

                               Player.nextTrack()
                           }
    }

    headBar.visible: !focusView
    headBar.rightContent: ToolButton
    {
        visible: Maui.Handy.isTouch
        icon.name: "item-select"
        onClicked: selectionMode = !selectionMode
        checkable: false
        checked: selectionMode
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
        anchors.fill: parent
        active: focusView
        source: "widgets/FocusView.qml"
    }

    Component
    {
        id: _shareDialogComponent
        MauiLab.ShareDialog {}
    }

    Component
    {
        id: _fmDialogComponent
        Maui.FileDialog {}
    }

    Component
    {
        id: _settingsDialogComponent
        SettingsDialog {}
    }

    SourcesDialog
    {
        id: sourcesDialog
    }

    FloatingDisk
    {
        id: _floatingDisk
    }

    mainMenu: [

        MenuSeparator{},

        MenuItem
        {
            text: qsTr("Settings")
            icon.name: "settings-configure"
            onTriggered:
            {
                _dialogLoader.sourceComponent = _settingsDialogComponent
                dialog.open()
            }
        },

        MenuItem
        {
            text: qsTr("Sources")
            icon.name: "folder-add"
            onTriggered: sourcesDialog.open()
        },

        MenuSeparator{},

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
                    Vvave.Vvave.openUrls(paths)
                    root.dialog.close()
                })
            }
        }
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
        width: visible ? Math.min(Kirigami.Units.gridUnit * 16, root.width) : 0
        collapsed: !isWide
        collapsible: true
        dragMargin: Maui.Style.space.big
        overlay.visible: collapsed && position > 0 && visible
        Connections
        {
            target: _drawer.overlay
            onClicked: _drawer.close()
        }

        background: Rectangle
        {
            color: Kirigami.Theme.backgroundColor
            opacity: translucency ? 0.5 : 1
        }

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

//    autoHideFooter: true
//    autoHideFooterMargins: root.height * 0.2
//    autoHideFooterDelay: 5000

    footer: ItemDelegate
    {
        visible: !focusView
        width: parent.width
        height: visible ? _footerLayout.implicitHeight : 0

        background: Item
        {
            Image
            {
                id: artworkBg
                height: parent.height
                width: parent.width

                sourceSize.width: 500
                sourceSize.height: height

                fillMode: Image.PreserveAspectCrop
                antialiasing: true
                smooth: true
                asynchronous: true
                cache: true

                source: currentArtwork
            }

            FastBlur
            {
                id: fastBlur
                anchors.fill: parent
                source: artworkBg
                radius: 100
                transparentBorder: false
                cached: true

                Rectangle
                {
                    anchors.fill: parent
                    color: Kirigami.Theme.backgroundColor
                    opacity: 0.8
                }
            }

            Kirigami.Separator
            {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
            }
        }

        ColumnLayout
    {
        id: _footerLayout
        anchors.fill: parent
        spacing: 0

        Maui.ToolBar
        {
            Layout.fillWidth: true
            preferredHeight: Maui.Style.toolBarHeightAlt * 0.8
            position: ToolBar.Footer
            visible: isPlaying

            leftContent: Label
            {
                id: _label1
                visible: text.length
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                text: progressTimeLabel
                elide: Text.ElideMiddle
                wrapMode: Text.NoWrap
                color: Kirigami.Theme.textColor
                font.weight: Font.Normal
                font.pointSize: Maui.Style.fontSizes.default
            }

            middleContent:  Item
            {
                Layout.fillHeight: true
                Layout.fillWidth: true

                Label
                {
                    anchors.fill: parent
                    visible: text.length
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                    text: root.title
                    elide: Text.ElideMiddle
                    wrapMode: Text.NoWrap
                    color: Kirigami.Theme.textColor
                    font.weight: Font.Normal
                    font.pointSize: Maui.Style.fontSizes.default
                }
            }

            rightContent: Label
            {
                id: _label2
                visible: text.length
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                text: player.transformTime(player.duration/1000)
                elide: Text.ElideMiddle
                wrapMode: Text.NoWrap
                color: Kirigami.Theme.textColor
                font.weight: Font.Normal
                font.pointSize: Maui.Style.fontSizes.default
                opacity: 0.7
            }

            background: Slider
            {
                id: progressBar
                z: parent.z+1
                padding: 0
                from: 0
                to: 1000
                value: player.pos
                spacing: 0
                focus: true
                onMoved: player.pos = value
                enabled: player.playing
                Kirigami.Separator
                {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                }

                background: Rectangle
                {
                    implicitWidth: progressBar.width
                    implicitHeight: progressBar.height
                    width: progressBar.availableWidth
                    height: implicitHeight
                    color: "transparent"
                    opacity: 0.4

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
                    y: 0
                    implicitWidth: Maui.Style.iconSizes.medium
                    implicitHeight: progressBar.height
                    color: progressBar.pressed ? Qt.lighter(Kirigami.Theme.highlightColor, 1.2) : "transparent"
                }
            }
        }

        Maui.ToolBar
        {
            Layout.fillWidth: true
            Layout.preferredHeight: Maui.Style.toolBarHeight
            position: ToolBar.Footer

            background: Item {}
            rightContent: ToolButton
            {
                icon.name: _volumeSlider.value === 0 ? "player-volume-muted" : "player-volume"
                onPressAndHold :
                {
                    player.volume = player.volume === 0 ? 100 : 0
                }

                onClicked:
                {
                    _sliderPopup.visible ? _sliderPopup.close() : _sliderPopup.open()
                }

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
                    checked: currentTrack ? Maui.FM.isFav(currentTrack.url) : false
                    icon.color: checked ? babeColor :  Kirigami.Theme.textColor
                    onClicked: if (!mainlistEmpty)
                               {
                                   mainPlaylist.list.fav(currentTrackIndex, !Maui.FM.isFav(currentTrack.url))
                               }
                },

                Maui.ToolActions
                {
                    expanded: true
                    autoExclusive: false
                    checkable: false

                    Action
                    {
                        icon.name: "media-skip-backward"
                        onTriggered: Player.previousTrack()
                        //                    onPressAndHold: Player.playAt(prevTrackIndex)
                    }
                    //ambulatorios1@clinicaantioquia.com.co, copago martha hilda restrepo, cc 22146440 eps salud total, consulta expecialista urologo, hora 3:40 pm
                    Action
                    {
                        id: playIcon
                        text: qsTr("Play and pause")
                        enabled: currentTrackIndex >= 0
                        icon.name: isPlaying ? "media-playback-pause" : "media-playback-start"
                        onTriggered: player.playing = !player.playing
                    }

                    Action
                    {
                        text: qsTr("Next")
                        icon.name: "media-skip-forward"
                        onTriggered: Player.nextTrack()
                        //                    onPressAndHold: Player.playAt(Player.shuffle())
                    }
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
    }

    Maui.Page
    {
        anchors.fill: parent
        visible: !focusView
        flickable: swipeView.currentItem.item.flickable

        MauiLab.AppViews
        {
            id: swipeView
            anchors.fill: parent

            MauiLab.AppViewLoader
            {
                MauiLab.AppView.title: qsTr("Tracks")
                MauiLab.AppView.iconName: "view-media-track"

                TracksView
                {
                    id: tracksView
                    onRowClicked: Player.quickPlay(tracksView.listModel.get(index))
                    onQuickPlayTrack: Player.quickPlay(tracksView.listModel.get(index))
                    onAppendTrack: Player.addTrack(tracksView.listModel.get(index))
                    onPlayAll: Player.playAll( tracksView.listModel.getAll())
                    onAppendAll: Player.appendAll( tracksView.listModel.getAll())
                    onQueueTrack: Player.queueTracks([tracksView.listModel.get(index)], index)
                    Connections
                    {
                        target: Vvave.Vvave
                        onRefreshTables: tracksView.list.refresh()
                    }
                }
            }

            MauiLab.AppViewLoader
            {
                MauiLab.AppView.title: qsTr("Albums")
                MauiLab.AppView.iconName: "view-media-album-cover"

                AlbumsView
                {
                    id: albumsView

                    holder.emoji: "qrc:/assets/dialog-information.svg"
                    holder.isMask: false
                    holder.title : qsTr("No Albums!")
                    holder.body: qsTr("Add new music sources")
                    holder.emojiSize: Maui.Style.iconSizes.huge
                    list.query: Albums.ALBUMS
                    list.sortBy: Albums.ALBUM

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

                    Connections
                    {
                        target: Vvave.Vvave
                        onRefreshTables: albumsView.list.refresh()
                    }
                }
            }

            MauiLab.AppViewLoader
            {
                MauiLab.AppView.title: qsTr("Artists")
                MauiLab.AppView.iconName: "view-media-artist"

                AlbumsView
                {
                    id: artistsView
                    holder.emoji: "qrc:/assets/dialog-information.svg"
                    holder.isMask: false
                    holder.title : qsTr("No Artists!")
                    holder.body: qsTr("Add new music sources")
                    holder.emojiSize: Maui.Style.iconSizes.huge
                    list.query: Albums.ARTISTS
                    list.sortBy: Albums.ARTIST
                    table.list.sortBy:  Tracks.NONE

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

                    onPlayAll: Player.playAll(artistsView.listModel.getAll())
                    onAppendAll: Player.appendAll(artistsView.listModel.getAll())

                    Connections
                    {
                        target: Vvave.Vvave
                        onRefreshTables: artistsView.list.refresh()
                    }
                }
            }

            MauiLab.AppViewLoader
            {
                MauiLab.AppView.title: qsTr("Playlists")
                MauiLab.AppView.iconName: "view-media-playlist"

                PlaylistsView
                {
                    id: playlistsView

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

            MauiLab.AppViewLoader
            {
                MauiLab.AppView.title: qsTr("Cloud")
                MauiLab.AppView.iconName: "folder-cloud"
                CloudView
                {
                    id: cloudView
                }
            }

            MauiLab.AppViewLoader
            {
                MauiLab.AppView.title: qsTr("Folders")
                MauiLab.AppView.iconName: "folder"

                FoldersView
                {
                    id: foldersView

                    Connections
                    {
                        target: Vvave.Vvave
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

            MauiLab.AppViewLoader
            {
                MauiLab.AppView.title: qsTr("YouTube")
                MauiLab.AppView.iconName: "internet-services"

                YouTube
                {
                    id: youtubeView
                }
            }
        }

        footer: SelectionBar
        {
            id: _selectionBar
            property alias listView: _selectionBar.selectionList
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)
            padding: Maui.Style.space.big
            maxListHeight: swipeView.height - Maui.Style.space.medium
            onExitClicked:
            {
                root.selectionMode = false
                clear()
            }
        }
    }

    /*CONNECTIONS*/
    Connections
    {
        target: Vvave.Vvave

        onRefreshTables:
        {
            if(size>0) root.notify("emblem-info", "Collection updated", size+" new tracks added...")
        }

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
