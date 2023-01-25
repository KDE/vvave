import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Window 2.15

import Qt.labs.settings 1.0

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB
import org.mauikit.accounts 1.0 as MA

import org.maui.vvave 1.0

import "widgets"
import "widgets/PlaylistsView"
import "widgets/MainPlaylist"
import "widgets/SettingsView"
import "widgets/CloudView"
import "widgets/FoldersView"

import "utils/Player.js" as Player

Maui.ApplicationWindow
{
    id: root
    title: currentTrack.url ? currentTrack.title + " - " +  currentTrack.artist + " | " + currentTrack.album : ""
    
    Maui.Style.styleType: focusView ? Maui.Style.Adaptive :  (Maui.Handy.isAndroid ? settings.darkMode ? Maui.Style.Dark : Maui.Style.Light : undefined)
    //    flags: miniMode ? Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint | Qt.Popup | Qt.BypassWindowManagerHint : undefined

    readonly property int preferredMiniModeSize: 200
    //    minimumHeight: miniMode ? preferredMiniModeSize : 300
    //    minimumWidth: miniMode ? preferredMiniModeSize : 200

    //    maximumWidth: miniMode ? minimumWidth : Screen.desktopAvailableWidth
    //    maximumHeight: miniMode ? minimumHeight : Screen.desktopAvailableHeight

    /***************************************************/
    /******************** ALIASES ********************/
    /*************************************************/
    property alias selectionBar: _selectionBar
    property alias dialog : _dialogLoader.item
    property alias playlistManager : playlist

    /***************************************************/
    /******************** PLAYBACK ********************/
    /*************************************************/
    readonly property alias currentTrack : playlist.currentTrack
    readonly property alias currentTrackIndex: playlist.currentIndex

    readonly property alias isPlaying: player.playing
    property alias mainPlaylist : _mainPlaylistLoader.item
    readonly property bool mainlistEmpty: mainPlaylist ? mainPlaylist.listModel.list.count === 0 : false

    /***************************************************/
    /******************** HANDLERS ********************/
    /*************************************************/
    readonly property var viewsIndex: ({ tracks: 0,
                                           albums: 1,
                                           artists: 2,
                                           playlists: 3,
                                           folders: 4,
                                           cloud: 5 })

    property string syncPlaylist: ""
    property bool sync: false

    readonly property bool focusView : _stackView.currentItem.objectName === "FocusView"
    readonly property bool miniMode : _miniModeComponent.visible

    property bool selectionMode : false

    /***************************************************/
    /******************** UI COLORS *******************/
    /*************************************************/
    readonly property color babeColor: "#f84172"


    /*HANDLE EVENTS*/

    signal contextualPlayNext()

    onClosing: playlist.save()
    onFocusViewChanged: setAndroidStatusBarColor()

    // NOTE: Anything in `.dialogLabel` or `.dialogCategory` get dynamically passed to `i18n` in ShortcutsDialog.qml, and thus should have translations. They are not translated here in case that affects their uniqueness as object keys.

    property list<Shortcut> shortcuts: [
    Shortcut
    {
        readonly property string dialogLabel: "Play/Pause"
        readonly property string dialogCategory: "Playback"
        sequence: "Space"
        onActivated: {
            if(player.playing)
                player.pause()
            else
                player.play()
        }
    },

    Shortcut
    {
        readonly property string dialogLabel: "Previous"
        readonly property string dialogCategory: "Playback"
        sequence: "P"
        onActivated: Player.previousTrack()
    },

    Shortcut
    {
        readonly property string dialogLabel: "Next"
        readonly property string dialogCategory: "Playback"
        sequence: "N"
        onActivated: Player.nextTrack()
    },

    Shortcut
    {
        readonly property string dialogLabel: "Rewind 10 seconds"
        readonly property string dialogCategory: "Playback"
        sequence: "Left"
        enabled: !(activeFocusItem instanceof Maui.GridView || activeFocusItem instanceof GridView)
        onActivated: player.pos -= 10000
    },

    Shortcut
    {
        readonly property string dialogLabel: "Skip 10 seconds"
        readonly property string dialogCategory: "Playback"
        sequence: "Right"
        enabled: !(activeFocusItem instanceof Maui.GridView || activeFocusItem instanceof GridView)
        onActivated: player.pos += 10000
    },

    Shortcut
    {
        readonly property string dialogLabel: "Increase Volume"
        readonly property string dialogCategory: "Playback"
        sequence: "+"
        sequences: ["="]
        onActivated: player.volume += 5
    },

    Shortcut
    {
        readonly property string dialogLabel: "Decrease Volume"
        readonly property string dialogCategory: "Playback"
        sequence: "-"
        onActivated: player.volume -= 5
    },

    Shortcut
    {
        readonly property string dialogLabel: "Filter"
        readonly property string dialogCategory: "Navigation"
        sequence: StandardKey.Find
        onActivated: {
            console.log("FOCUS FILTER")

            let filterField = getFilterField()

            if (!filterField)
                return

            if (!filterField.activeFocus)
                filterField.forceActiveFocus()
            else
                filterField.focus = false
        }
    },

    Shortcut
    {
        readonly property string dialogLabel: "Focus View"
        readonly property string dialogCategory: "Navigation"
        sequence: StandardKey.Cancel
        onActivated: {
            // I couldn't get Keys.onShortcutOverride in each view to work. I guess this is more dynamic anyway.
            let func = getGoBackFunc()
            if (func) {
                func()
                return
            }
            toggleFocusView()
        }
    },

    Shortcut
    {
        readonly property string dialogLabel: "Next Category"
        readonly property string dialogCategory: "Navigation"
        sequence: "Ctrl+Tab" // StandardKey.NextChild and .PreviousChild seem broken on Linux.
        onActivated: swipeView.currentIndex = ((swipeView.currentIndex + 1) % swipeView.count + swipeView.count) % swipeView.count
    },

    Shortcut
    {
        readonly property string dialogLabel: "Previous Category"
        readonly property string dialogCategory: "Navigation"
        sequence: "Ctrl+Shift+Tab"
        onActivated: swipeView.currentIndex = ((swipeView.currentIndex - 1) % swipeView.count + swipeView.count) % swipeView.count
    },

    Shortcut
    {
        readonly property string dialogLabel: "Queue Track"
        readonly property string dialogCategory: "Navigation"
        sequence: "Shift+Return"
        sequences: ["Shift+Enter"]
        // StandardKey.InsertLineSeparator only gets "Enter", not "Return".
        onActivated: contextualPlayNext()
    },

    Shortcut
    {
        readonly property string dialogLabel: "Context Actions"
        readonly property string dialogCategory: "Navigation"
        sequence: "Menu"
        onActivated: {
            if (activeFocusItem) {
                let func = (activeFocusItem.currentItem ?? activeFocusItem).tryOpenContextMenu
                if (func) {
                    func()
                    return
                }
            }
            console.log("NO CONTEXT MENU", activeFocusItem, activeFocusItem.currentItem)
        }
    }
    ]

    Loader
    {
        active: (root.isPlaying && !root.mainlistEmpty)
        asynchronous: true
        sourceComponent: FloatingDisk {}
    }

    Settings
    {
        id: settings
        category: "Settings"
        property bool fetchArtwork: true
        property bool autoScan: true
        property bool darkMode : true
        property bool focusViewDefault: false
        property alias sideBarWidth : _sideBarView.sideBar.preferredWidth
        property bool showArtwork: false
    }

    Mpris2
    {
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
                console.log("REMOVE TIU MSISING", mainPlaylist.table.currentIndex)
                mainPlaylist.table.list.removeMissing(mainPlaylist.table.currentIndex)
                console.log("REMOVE TIU MSISING 2", mainPlaylist.table.currentIndex)
            })
        }
    }

    Player
    {
        id: player
        volume: 100
        onFinished:
        {
            if (!mainlistEmpty)
            {
                if (currentTrack && currentTrack.url)
                {
                    mainPlaylist.listModel.list.countUp(currentTrackIndex)
                }

                Player.nextTrack()
            }
        }
    }

    Loader
    {
        id: _dialogLoader
    }

    Component
    {
        id: _fileDialogComponent
        FB.FileDialog {}
    }

    Component
    {
        id: _shortcutsDialogComponent
        ShortcutsDialog {}
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
            message: i18n("Are you sure you want to remove these files? This action can not be undone.")

            rejectButton.text: i18n("Delete")
            acceptButton.text: i18n("Cancel")

            onAccepted: close()

            onRejected:
            {
                FB.FM.removeFiles(_removeDialog.urls)
                close()
            }
        }
    }

    Component
    {
        id: _playlistDialogComponent

        FB.TagsDialog
        {
            onTagsReady: composerList.updateToUrls(tags)
            composerList.strict: false
        }
    }

    Maui.SideBarView
    {
        id: _sideBarView
        sideBar.preferredWidth: Maui.Style.units.gridUnit * 16
        anchors.fill: parent

        sideBarContent: Item
        {
            id: _drawer
            anchors.fill: parent
            Loader
            {
                id: _mainPlaylistLoader
                anchors.fill: parent

                asynchronous: false
                sourceComponent: MainPlaylist {}
            }
        }

        Maui.Page
        {
            id: _mainPage
            anchors.fill: parent
            headBar.visible: false

            footer: Loader
            {
                id: _playbackBarLoader
                asynchronous: true
                width: parent.width
                active: visible
                sourceComponent: PlaybackBar {}
            }

            StackView
            {
                id: _stackView
                focus: true
                anchors.fill: parent
                initialItem: _focusViewComponent

                Component.onCompleted:
                {
                    if(!settings.focusViewDefault)
                    {
                        toggleFocusView()
                    }
                }

                pushExit: Transition
                {
                    ParallelAnimation
                    {
                        PropertyAnimation
                        {
                            property: "y"
                            from: 0
                            to:  _stackView.height
                            duration: 200
                            easing.type: Easing.InOutCubic
                        }

//                        PropertyAnimation
//                        {
//                            property: "x"
//                            from: 0
//                            to:  _stackView.width
//                            duration: 200
//                            easing.type: Easing.InOutCubic
//                        }

//                        PropertyAnimation
//                        {
//                            property: "scale"
//                            from: 1
//                            to:  0
//                            duration: 200
//                            easing.type: Easing.InOutCubic
//                        }


                        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 300; easing.type: Easing.InOutCubic }
                    }
                }

                pushEnter: null

                popExit: null

                popEnter: Transition
                {
                    ParallelAnimation
                    {
                        PropertyAnimation
                        {
                            property: "y"
                            from: _stackView.height
                            to: 0
                            duration: 200
                            easing.type: Easing.InOutCubic
                        }

//                        PropertyAnimation
//                        {
//                            property: "x"
//                            from: _stackView.width
//                            to: 0
//                            duration: 200
//                            easing.type: Easing.InOutCubic
//                        }

//                        PropertyAnimation
//                        {
//                            property: "scale"
//                            from: 0
//                            to: 1
//                            duration: 200
//                            easing.type: Easing.InOutCubic
//                        }

                        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200; easing.type: Easing.OutCubic }
                    }
                } //OK

                    Maui.AppViews
                    {
                        id: swipeView
                        maxViews: 3

                        floatingFooter: true
                        flickable: swipeView.currentItem.flickable || swipeView.currentItem.item.flickable
                        altHeader: Maui.Handy.isMobile
                        showCSDControls: true

                        headBar.leftContent: Loader
                        {
                            asynchronous: true

                            sourceComponent: Maui.ToolButtonMenu
                            {
                                icon.name: "application-menu"

                                MA.AccountsMenuItem{}

                                MenuItem
                                {
                                    text: i18n("Shortcuts")
                                    icon.name: "configure-shortcuts"
                                    onTriggered: openShortcutsDialog()
                                }

                                MenuItem
                                {
                                    text: i18n("Settings")
                                    icon.name: "settings-configure"
                                    onTriggered: openSettingsDialog()
                                }

                                MenuItem
                                {
                                    text: i18n("About")
                                    icon.name: "documentinfo"
                                    onTriggered: root.about()
                                }
                            }
                        }

                        footer: SelectionBar
                        {
                            id: _selectionBar
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)

                            maxListHeight: swipeView.height - Maui.Style.space.medium
                            display: ToolButton.IconOnly

                            onExitClicked:
                            {
                                root.selectionMode = false
                                clear()
                            }

                            onVisibleChanged:
                            {
                                if(!visible)
                                {
                                    root.selectionMode = false
                                }
                            }
                        }

                        Maui.AppViewLoader
                        {
                            Maui.AppView.title: i18n("Songs")
                            Maui.AppView.iconName: "view-media-track"

                            TracksView
                            {
                                Component.onCompleted:
                                {
                                    if(settings.autoScan)
                                    {
                                        Vvave.rescan()
                                    }
                                }
                            }
                        }

                        Maui.AppViewLoader
                        {
                            id: _albumsViewLoader

                            Maui.AppView.title: i18n("Albums")
                            Maui.AppView.iconName: "view-media-album-cover"

                            property var pendingAlbum : ({})

                            AlbumsView
                            {
                                holder.title : i18n("No Albums!")
                                holder.body: i18n("Add new music sources")
                                list.query: Albums.ALBUMS

                                Component.onCompleted:
                                {
                                    if(Object.keys(_albumsViewLoader.pendingAlbum).length)
                                    {
                                        populateTable(_albumsViewLoader.pendingAlbum.album, _albumsViewLoader.pendingAlbum.artist)
                                    }
                                }
                            }
                        }

                        Maui.AppViewLoader
                        {
                            id: _artistViewLoader
                            Maui.AppView.title: i18n("Artists")
                            Maui.AppView.iconName: "view-media-artist"

                            property string pendingArtist

                            AlbumsView
                            {
                                holder.title : i18n("No Artists!")
                                holder.body: i18n("Add new music sources")
                                list.query : Albums.ARTISTS

                                Component.onCompleted:
                                {
                                    if(_artistViewLoader.pendingArtist.length)
                                    {
                                        populateTable(undefined, _artistViewLoader.pendingArtist)

                                    }
                                }
                            }
                        }

                        Maui.AppViewLoader
                        {
                            Maui.AppView.title: i18n("Tags")
                            Maui.AppView.iconName: "tag"
                            PlaylistsView {}
                        }

                        Maui.AppViewLoader
                        {
                            Maui.AppView.title: i18n("Folders")
                            Maui.AppView.iconName: "folder"

                            FoldersView {}
                        }

                        Maui.AppViewLoader
                        {
                            Maui.AppView.title: i18n("Cloud")
                            Maui.AppView.iconName: "folder-cloud"

                            CloudView {}
                        }


                    data: Loader
                    {
                        width: parent.width
                        anchors.bottom: parent.bottom
                        active: Vvave.scanning
                        visible: active
                        sourceComponent: Maui.ProgressIndicator {}
                    }

                    function getFilterField() : Item
                    {
                        return currentItem.item.getFilterField()
                    }

                    function getGoBackFunc() : Function
                    {
                        return 'getGoBackFunc' in currentItem.item ?
                            currentItem.item.getGoBackFunc() :
                            null
                    }
                }

                Component
                {
                    id: _focusViewComponent

                    FocusView
                    {
                        objectName: "FocusView"
                    }
                }

                Loader
                {
                    id: _miniModeComponent
                    visible: active
                    active: StackView.status === StackView.Active
                    MiniMode
                    {
                        anchors.fill: parent
                    }
                }
            }
        }
    }

    Component.onCompleted:
    {
        Vvave.fetchArtwork = settings.fetchArtwork
        setAndroidStatusBarColor()
    }

    function setAndroidStatusBarColor()
    {
        if(Maui.Handy.isAndroid)
        {
            const isDark = Maui.ColorUtils.brightnessForColor(Maui.Theme.backgroundColor) === Maui.ColorUtils.Dark
            Maui.Android.statusbarColor(Maui.Theme.backgroundColor, !isDark)
            Maui.Android.navBarColor(Maui.Theme.backgroundColor, !isDark)
        }
    }

    function toggleFocusView()
    {
        if(focusView)
        {
            _stackView.push(swipeView)

        }else
        {
            _stackView.pop()
        }

        _stackView.currentItem.forceActiveFocus()

    }

    property int oldH : root. height
    property int oldW : root.width
    property point oldP : Qt.point(root.x, root.y)

    function toggleMiniMode()
    {
        if(Maui.Handy.isMobile)
        {
            return
        }

        if(miniMode)
        {
            _stackView.pop(StackView.Immediate)

            root.width = oldW
            root.height = oldH

            root.x = oldP.x
            root.y = oldP.y
        }else
        {
            root.oldH = root.height
            root.oldW = root.width
            root.oldP = Qt.point(root.x, root.y)

            _stackView.push(_miniModeComponent, StackView.Immediate)

            root.x = Screen.desktopAvailableWidth - root.preferredMiniModeSize - Maui.Style.space.big
            root.y = Screen.desktopAvailableHeight - root.preferredMiniModeSize - Maui.Style.space.big
        }
    }

    function openShortcutsDialog() : undefined
    {
        _dialogLoader.sourceComponent = _shortcutsDialogComponent
        dialog.open()
    }

    function openSettingsDialog()
    {
        _dialogLoader.sourceComponent = _settingsDialogComponent
        dialog.open()
    }

    function goToAlbum(artist, album)
    {
        if(root.focusView)
        {
            toggleFocusView()
        }

        swipeView.currentIndex = viewsIndex.albums
        if(_albumsViewLoader.item)
        {
            _albumsViewLoader.item.populateTable(album, artist)
        }else
        {
            _albumsViewLoader.pendingAlbum = ({'artist': artist, 'album': album})
        }
    }

    function goToArtist(artist)
    {
        if(root.focusView)
        {
            toggleFocusView()
        }

        swipeView.currentIndex = viewsIndex.artists
        if(_artistViewLoader.item)
        {
            _artistViewLoader.item.populateTable(undefined, artist)
        }else
        {
            _artistViewLoader.pendingArtist = artist
        }
    }

    function openFiles(urls)
    {
        console.log("APPEND URLS", urls)
        Player.appendUrlsAt(urls, 0)
        Player.playAt(0)
    }

    function isUrlOpen(url : string) : bool
    {
        return false;
    }

    function getFilterField() : Item
    {
        return ('getFilterField' in _stackView.currentItem) ?
            _stackView.currentItem.getFilterField() :
            null
    }

    function getGoBackFunc() : Function
    {
        let filterField = getFilterField()
        if (filterField && filterField.activeFocus) {
            return () => { filterField.focus = false }
        } else {
            return ('getGoBackFunc' in _stackView.currentItem) ?
                _stackView.currentItem.getGoBackFunc() :
                null
        }
    }

    }
