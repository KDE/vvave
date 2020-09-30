import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQml 2.14

import QtGraphicalEffects 1.0
import QtMultimedia 5.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui
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

import "widgets/InfoView"

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

    property alias durationTimeLabel: player.duration
    property string progressTimeLabel: player.transformTime((player.duration/1000) *(player.pos/ 1000))

    property alias isPlaying: player.playing
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

    property bool focusView : false
    property bool selectionMode : false

    /***************************************************/
    /******************** UI COLORS *******************/
    /*************************************************/
    readonly property color babeColor: "#f84172"

    /*HANDLE EVENTS*/
    onClosing: Player.savePlaylist()


    /*COMPONENTS*/

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

    altHeader: Kirigami.Settings.isMobile
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
        Maui.ShareDialog {}
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

    footer: Control
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

            Maui.Separator
            {
                position: Qt.Horizontal
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
                visible: player.state !== MediaPlayer.StoppedState

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
                visible: player.state !== MediaPlayer.StoppedState

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
                        enabled: currentTrack
                        checked:currentTrack.url ? Maui.FM.isFav(currentTrack.url) : false
                        icon.color: checked ? babeColor :  Kirigami.Theme.textColor
                        onClicked:
                        {
                            mainPlaylist.listModel.list.fav(currentTrackIndex, !Maui.FM.isFav(currentTrack.url))
                            root.currentTrackChanged()
                        }
                    },

                    Maui.ToolActions
                    {
                        implicitHeight: Maui.Style.iconSizes.big
                        expanded: true
                        autoExclusive: false
                        checkable: false

                        Action
                        {
                            icon.name: "media-skip-backward"
                            onTriggered: Player.previousTrack()
                        }
                        //ambulatorios1@clinicaantioquia.com.co, copago martha hilda restrepo, cc 22146440 eps salud total, consulta expecialista urologo, hora 3:40 pm
                        Action
                        {
                            id: playIcon
                            text: i18n("Play and pause")
                            icon.width: Maui.Style.iconSizes.big
                            icon.height: Maui.Style.iconSizes.big
                            enabled: currentTrackIndex >= 0
                            icon.name: isPlaying ? "media-playback-pause" : "media-playback-start"
                            onTriggered: player.playing ? player.pause() : player.play()
                        }

                        Action
                        {
                            text: i18n("Next")
                            icon.name: "media-skip-forward"
                            onTriggered: Player.nextTrack()
                            //                    onPressAndHold: Player.playAt(Player.shuffle())
                        }
                    },

                    ToolButton
                    {
                        id: shuffleBtn
                        icon.color: babeColor
                        icon.name: playlist.shuffle ? "media-playlist-shuffle" : "media-playlist-normal"
                        onClicked:
                        {
                            playlist.shuffle = !playlist.shuffle
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

                Component.onCompleted: list.query = Albums.ALBUMS
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

                Component.onCompleted: list.query = Albums.ARTISTS
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
}
