import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQml 2.14

import Qt.labs.settings 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.3 as Maui
import org.maui.vvave 1.0

import "utils"

import "widgets"
import "widgets/PlaylistsView"
import "widgets/MainPlaylist"
import "widgets/SettingsView"
import "widgets/CloudView"

import "view_models"
import "view_models/BabeTable"

import "view_models/BabeGrid"

//import "widgets/InfoView"

import "db/Queries.js" as Q
import "utils/Help.js" as H
import "utils/Player.js" as Player

Maui.ApplicationWindow
{
    id: root
    title: currentTrack.url ? currentTrack.title + " - " +  currentTrack.artist + " | " + currentTrack.album : ""

    /***************************************************/
    /******************** ALIASES ********************/
    /*************************************************/
    property alias selectionBar: _selectionBar
    property alias dialog : _dialogLoader.item

    /***************************************************/
    /******************** PLAYBACK ********************/
    /*************************************************/
    property alias currentTrack : playlist.currentTrack
    property alias currentTrackIndex: playlist.currentIndex

    readonly property string currentArtwork: currentTrack ?  currentTrack.artwork : ""

    readonly property string progressTimeLabel: player.transformTime((player.duration/1000) * (player.pos/ 1000))
    readonly property string durationTimeLabel: player.transformTime((player.duration/1000))

    readonly property alias isPlaying: player.playing
    property int onQueue: 0

    readonly property bool mainlistEmpty: mainPlaylist.listModel.list.count ===0

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

    readonly property bool focusView : _stackView.depth === 2
    property bool selectionMode : false

    /***************************************************/
    /******************** UI COLORS *******************/
    /*************************************************/
    readonly property color babeColor: "#f84172"

    /*HANDLE EVENTS*/
    onClosing: Player.savePlaylist()

    Settings
    {
        id: settings
        category: "Settings"
        property bool fetchArtwork: true
        property bool autoScan: true

        property string sortBy : "title"
        property int sortOrder: Qt.AscendingOrder
        property bool group: sortBy === "artist" || sortBy === "album"
    }

    Mpris2
    {
        id: mpris2Interface

        playListModel: playlist
        audioPlayer: player
        playerName: 'vvave'

        onRaisePlayer:
        {
            root.raise()
        }
    }

    Playlist
    {
        id: playlist
        model: mainPlaylist.listModel.list
        onCurrentTrackChanged: Player.playTrack()

        onMissingFile:
        {
            var message = i18n("Missing file")
            var messageBody = track.title + " by " + track.artist + " is missing.\nDo you want to remove it from your collection?"
            notify("dialog-question", message, messageBody, function ()
            {
                mainPlaylist.listModel.list.remove(mainPlaylist.table.currentIndex)
            })
        }
    }

    Player
    {
        id: player
        volume: 100
        onFinished: if (!mainlistEmpty)
                    {
                        if (currentTrack && currentTrack.url)
                            mainPlaylist.listModel.list.countUp(currentTrackIndex)

                        Player.nextTrack()
                    }
    }

    altHeader: Kirigami.SettingsisMobile
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

    //    InfoView
    //    {
    //        id: infoView
    //        maxWidth: parent.width * 0.8
    //        maxHeight: parent.height * 0.9
    //    }


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

    Component
    {
        id: _removeDialogComponent

        Maui.FileListingDialog
        {
            id: _removeDialog

            urls: selectionBar.uris

            title: i18n("Remove %1 tracks", urls.length)
            message: i18n("Are you sure you want to remove this files? This action can not be undone.")

            rejectButton.text: i18n("Delete")
            acceptButton.text: i18n("Cancel")

            onAccepted: close()

            onRejected:
            {
                Maui.FM.removeFiles(_removeDialog.urls)
                close()
            }
        }
    }

    FloatingDisk
    {
        id: _floatingDisk
    }

    mainMenu: [

        Action
        {
            text: i18n("Settings")
            icon.name: "settings-configure"
            onTriggered:
            {
                _dialogLoader.sourceComponent = _settingsDialogComponent
                dialog.open()
            }
        },

        Action
        {
            text: i18n("Open")
            icon.name: "folder-add"
            onTriggered:
            {
                _dialogLoader.sourceComponent = _fmDialogComponent
                root.dialog.settings.onlyDirs = false
                root.dialog.settings.filterType = Maui.FMList.AUDIO
                root.dialog.show(function(paths)
                {
                    Vvave.openUrls(paths)
                    root.dialog.close()
                })
            }
        }
    ]

    Playlists
    {
        id: playlistsList
    }

    Maui.TagsDialog
    {
        id: playlistDialog
        onTagsReady: composerList.updateToUrls(tags)
        composerList.strict: false
    }

    sideBar: Maui.AbstractSideBar
    {
        id: _drawer
        visible: true
        width: visible ? Math.min(Kirigami.Units.gridUnit * 16, root.width) : 0
        collapsed: !isWide
        collapsible: true
        dragMargin: Maui.Style.space.big
        overlay.visible: collapsed && position > 0 && visible
        Connections
        {
            target: _drawer.overlay
            function onClicked()
            {
                _drawer.close()
            }
        }

        onContentDropped:
        {
            if(drop.urls)
            {
                var urls = drop.urls.join(",")
                Vvave.openUrls(urls.split(","))
            }
        }

        MainPlaylist
        {
            id: mainPlaylist
            anchors.fill: parent
            Connections
            {
                target: mainPlaylist
                ignoreUnknownSignals: true

                function onCoverPressed(tracks)
                {
                    Player.appendAll(tracks)
                }

                function onCoverDoubleClicked(tracks)
                {
                    Player.playAll(tracks)
                }
            }
        }
    }

    footer: PlaybackBar
    {
        visible: !focusView
        width: parent.width
    }

    Component
    {
        id: _focusViewComponent

        FocusView { }
    }

    StackView
    {
        id: _stackView
        anchors.fill: parent

        initialItem: Maui.Page
        {
            floatingFooter: true
            flickable: swipeView.currentItem.flickable ||swipeView.currentItem.item.flickable

            Maui.AppViews
            {
                id: swipeView
                anchors.fill: parent

                TracksView
                {
                    id: tracksView

                    Maui.AppView.title: i18n("Tracks")
                    Maui.AppView.iconName: "view-media-track"
                }

                AlbumsView
                {
                    id: albumsView
                    Maui.AppView.title: i18n("Albums")
                    Maui.AppView.iconName: "view-media-album-cover"
                    holder.emoji: "qrc:/assets/dialog-information.svg"
                    holder.title : i18n("No Albums!")
                    holder.body: i18n("Add new music sources")
                    holder.emojiSize: Maui.Style.iconSizes.huge
                    list.query: Albums.ALBUMS
                }

                AlbumsView
                {
                    id: artistsView
                    Maui.AppView.title: i18n("Artists")
                    Maui.AppView.iconName: "view-media-artist"

                    holder.emoji: "qrc:/assets/dialog-information.svg"
                    holder.title : i18n("No Artists!")
                    holder.body: i18n("Add new music sources")
                    holder.emojiSize: Maui.Style.iconSizes.huge
                    list.query : Albums.ARTISTS
                }

                Maui.AppViewLoader
                {
                    Maui.AppView.title: i18n("Playlists")
                    Maui.AppView.iconName: "view-media-playlist"

                    PlaylistsView
                    {
                        id: playlistsView
                    }
                }

                Maui.AppViewLoader
                {
                    Maui.AppView.title: i18n("Cloud")
                    Maui.AppView.iconName: "folder-cloud"

                    CloudView
                    {
                        id: cloudView
                    }
                }

                Maui.AppViewLoader
                {
                    Maui.AppView.title: i18n("Folders")
                    Maui.AppView.iconName: "folder"

                    FoldersView
                    {
                        id: foldersView
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
    }

    Component.onCompleted:
    {
        Vvave.autoScan = settings.autoScan
    }

    /*CONNECTIONS*/
    Connections
    {
        target: Vvave
        ignoreUnknownSignals: true
        function onOpenFiles(tracks)
        {
            Player.appendTracksAt(tracks, 0)
            Player.playAt(0)
        }
    }

    function toggleFocusView()
    {
        if(focusView)
        {
            _stackView.pop(StackView.Immediate)
        }else
        {
            _stackView.push(_focusViewComponent, StackView.Immediate)
        }
    }
}
