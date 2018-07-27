import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import QtQuick.Window 2.3

import "utils"

import "widgets"
import "widgets/MyBeatView"
import "widgets/PlaylistsView"
import "widgets/MainPlaylist"
import "widgets/SettingsView"
import "widgets/SearchView"

import "view_models"
import "view_models/BabeDialog"

import "services/local"
import "services/web"
import "services/web/Spotify"

import "view_models/BabeGrid"

import "db/Queries.js" as Q
import "utils/Help.js" as H
import "utils/Player.js" as Player

import org.kde.kirigami 2.2 as Kirigami
import org.kde.maui 1.0 as Maui

Maui.ApplicationWindow
{

    id: root
    //    minimumWidth: !isMobile ? columnWidth : 0
    //    minimumHeight: !isMobile ? columnWidth + 64 : 0
    //        flags: Qt.FramelessWindowHint
    title: qsTr("vvave")
    floatingBar: true
    footBarOverlap: true
    /***************************************************/
    /******************** ALIASES ********************/
    /*************************************************/
    property alias playIcon: playIcon
    property alias babeBtnIcon: babeBtnIcon
    property alias progressBar: progressBar
    property alias animFooter: animFooter
    property alias mainPlaylist: mainPlaylist

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
                                           vvave: 5,
                                           linking: 6,
                                           youtube: 7,
                                           spotify: 8

                                       })

    property string syncPlaylist: ""
    property bool sync: false
    property string infoMsg: ""
    property bool infoLabels: bae.loadSetting("LABELS", "PLAYBACK", false) == "true" ? true : false

    property bool isLinked: false
    property bool isServing: false

    /* ANDROID THEMING*/

    Material.theme: Material.Light
    Material.accent: babeColor
    Material.background: viewBackgroundColor
    Material.primary: backgroundColor
    Material.foreground: textColor


    /***************************************************/
    /******************** UI UNITS ********************/
    /*************************************************/

    readonly property real screenWidth : Screen.width
    readonly property real screenHeight : Screen.height

    property bool focusMode : false

    /***************************************************/
    /******************** UI COLORS *******************/
    /*************************************************/
    property string babeColor: bae.babeColor()

    readonly property string darkBackgroundColor: "#303030"
    readonly property string darkTextColor: "#FAFAFA"
    readonly property string darkHighlightColor: "#29B6F6"
    readonly property string darkHighlightedTextColor: darkTextColor
    readonly property string darkViewBackgroundColor: "#212121"
    readonly property string darkDarkColor: "#191919"
    readonly property string darkButtonBackgroundColor :  "#191919"


    /***************************************************/
    /**************************************************/
    /*************************************************/


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
        width: isMobile ? parent.width * 0.9 : parent.width * 0.4
        title: "Missing file"
        onAccepted: {
            bae.removeTrack(currentTrack.url)
            mainPlaylist.table.model.remove(mainPlaylist.table.currentIndex)
        }
    }


    /* UI */
    property bool accent : pageStack.wideMode || (!pageStack.wideMode && pageStack.currentIndex === 1)

    headBar.middleContent : [

        Maui.ToolButton
        {
            iconName: "view-media-track"
            iconColor:  accent && currentView === viewsIndex.tracks ? babeColor : textColor
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
            iconColor:  accent && currentView === viewsIndex.albums ? babeColor : textColor
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
            iconColor:  accent && currentView === viewsIndex.artists ? babeColor : textColor
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
            iconColor:  accent && currentView === viewsIndex.playlists ? babeColor : textColor
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

    footBar.visible: !mainlistEmpty

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
                var value = mainPlaylist.contextMenu.babeIt(
                    currentTrackIndex)
                currentBabe = value
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

    footBar.background: Rectangle
    {
        id: footerBg
        clip : true
        implicitHeight: floatingBar ? toolBarHeight * 0.7 : toolBarHeight
        height: implicitHeight
        color: darkViewBackgroundColor
        radius: floatingBar ? unit * 6 : 0
        border.color: floatingBar ? Qt.lighter(borderColor, 1.2) : "transparent"
        layer.enabled: floatingBar
        layer.effect: DropShadow
        {
            anchors.fill: footerBg
            horizontalOffset: 0
            verticalOffset: 4
            radius: 8.0
            samples: 17
            color: "#80000000"
            source: footerBg
        }

        SequentialAnimation
        {
            id: animFooter
            PropertyAnimation
            {
                target: footerBg
                property: "color"
                easing.type: Easing.InOutQuad
                from: "black"
                to: darkViewBackgroundColor
                duration: 500
            }
        }

        Rectangle
        {
            anchors.fill: parent
            color: "transparent"
            radius: footerBg.radius
            opacity: 0.3
            clip: true

            FastBlur
            {
                id: fastBlur
                width: parent.width
                height: parent.height-1
                y:1
                source: mainPlaylist.artwork
                radius: 100
                transparentBorder: false
                cached: true
                z:1
                clip: true

                layer.enabled: floatingBar
                layer.effect: OpacityMask
                {
                    maskSource: Item
                    {
                        width: footBar.width
                        height: footBar.height
                        Rectangle
                        {
                            anchors.centerIn: parent
                            width: footBar.width
                            height: footBar.height
                            radius: footerBg.radius
                        }
                    }
                }
            }
        }
    }
    Slider
    {
        id: progressBar
        height: unit * (isMobile ?  6 : 8)
        width: parent.width
        anchors
        {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        padding: 0
        from: 0
        to: 1000
        value: 0
        spacing: 0
        focus: true
        onMoved: player.seek(player.duration() / 1000 * value)

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
            y: -(progressBar.height * 0.7)
            implicitWidth: progressBar.pressed ? iconSizes.medium : 0
            implicitHeight: progressBar.pressed ? iconSizes.medium : 0
            radius: progressBar.pressed ? iconSizes.medium : 0
            color: babeColor
        }
    }

    FloatingDisk
    {
        id: floatingDisk
        anchors.centerIn: footBar
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

    menuDrawer.bannerImageSource: "qrc:/assets/banner.svg"

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
            Kirigami.Action
            {
                text: "Brainz"

                Kirigami.Action
                {
                    id: brainzToggle
                    text: checked ? "Turn OFF" : "Turn ON"
                    checked: false
                    checkable: true
                    onToggled:
                    {
                        bae.saveSetting("BRAINZ", checked === true ? true : false, "BABE")
                        bae.brainz(checked === true ? true : false)
                    }
                }
            }

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

    MainPlaylist
    {
        id: mainPlaylist
        Connections
        {
            target: mainPlaylist
            onCoverPressed: Player.appendAll(tracks)
            onCoverDoubleClicked: Player.playAll(tracks)
        }
    }

    Maui.Page
    {
        id: views
        headBarVisible: false
        margins: 0
        //        focusPolicy: Qt.WheelFocus
        //        visualFocus: true

        Column
        {
            anchors.fill: parent

            SwipeView
            {
                id: swipeView
                width: parent.width
                height: parent.height

                Component.onCompleted: contentItem.interactive = isMobile

                currentIndex: currentView

                onCurrentItemChanged: currentItem.forceActiveFocus()

                onCurrentIndexChanged:
                {
                    currentView = currentIndex
                    if (!babeitView.isConnected && currentIndex === viewsIndex.vvave)
                        babeitView.logginDialog.open()

                    if(currentView === viewsIndex.search)
                        riseContent()
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

                        onAlbumCoverClicked:
                        {
                            var query = Q.GET.albumTracks_.arg(album)
                            query = query.arg(artist)
                            albumsView.table.headBarTitle = album
                            albumsView.populateTable(query)

                            var tagq = Q.GET.albumTags_.arg(album)
                            tagq = tagq.arg(artist)

                            albumsView.tagBar.populate(bae.get(tagq))
                        }

                        onAlbumCoverPressedAndHold:
                        {
                            var query = Q.GET.albumTracks_.arg(album)
                            query = query.arg(artist)

                            var map = bae.get(query)
                            albumsView.playAlbum(map)
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
                        onAlbumCoverClicked:
                        {
                            var query = Q.GET.artistTracks_.arg(artist)
                            artistsView.table.headBarTitle = artist
                            artistsView.populateTable(query)

                            var tagq = Q.GET.artistTags_.arg(artist)

                            artistsView.tagBar.populate(bae.get(tagq))
                        }

                        onAlbumCoverPressedAndHold:
                        {
                            var query = Q.GET.artistTracks_.arg(artist)

                            var map = bae.get(query)
                            artistsView.playAlbum(map)
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

    function switchColorScheme(variant)
    {
        bae.saveSetting("THEME", variant, "BABE")

        if(variant === "Light")
        {
            backgroundColor = Kirigami.Theme.backgroundColor
            textColor = Kirigami.Theme.textColor
            highlightColor = Kirigami.Theme.highlightColor
            highlightedTextColor = Kirigami.Theme.highlightedTextColor
            buttonBackgroundColor = Kirigami.Theme.buttonBackgroundColor
            viewBackgroundColor = Kirigami.Theme.viewBackgroundColor
            altColor = Kirigami.Theme.complementaryBackgroundColor
            babeColor = bae.babeColor()

        }else if(variant === "Dark")
        {
            backgroundColor = darkBackgroundColor
            textColor = darkTextColor
            highlightColor = darkHighlightColor
            highlightedTextColor = darkHighlightedTextColor
            buttonBackgroundColor = darkButtonBackgroundColor
            viewBackgroundColor = darkViewBackgroundColor
            altColor = darkDarkColor
        }
    }

    Component.onCompleted:
    {
        var style = bae.loadSetting("THEME", "BABE", "Dark")
        if(isAndroid)
        {
            switchColorScheme(style)
            Maui.Android.statusbarColor(backgroundColor, false)
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
    }
}
