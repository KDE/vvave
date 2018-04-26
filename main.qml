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

import "db/Queries.js" as Q
import "utils/Player.js" as Player
import "utils/Help.js" as H

import org.kde.kirigami 2.2 as Kirigami
import Link.Codes 1.0

Kirigami.ApplicationWindow
{

    id: root
    visible: true
    width: Screen.width * (isMobile ? 1 : 0.4)
    minimumWidth: !isMobile ? columnWidth : 0
    minimumHeight: !isMobile ? columnWidth + 64 : 0
    height: Screen.height * (isMobile ? 1 : 0.4)
    //    flags: Qt.FramelessWindowHint
    title: qsTr("vvave")

    //    wideScreen: root.width > coverSize

    /*ALIASES*/
    property alias playIcon: playIcon
    property alias babeBtnIcon: babeBtnIcon
    property alias progressBar: progressBar
    property alias animFooter: animFooter
    property alias mainPlaylist: mainPlaylist


    readonly property bool isMobile : Kirigami.Settings.isMobile
    readonly property bool isAndroid: bae.isAndroid()

    /***************************************************/
    /******************** PLAYBACK ********************/
    /*************************************************/

    property bool isShuffle: false
    property var currentTrack: ({
                                    babe: "0",
                                    stars: "0"
                                })

    property int currentTrackIndex: 0
    property int prevTrackIndex: 0
    property string currentArtwork: !mainlistEmpty ? mainPlaylist.list.model.get(
                                                         0).artwork : ""
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

    readonly property int wideSize: Screen.width * 0.5

    readonly property int rowHeight: (defaultFontSize * 2) + space.large
    readonly property int rowHeightAlt: (defaultFontSize*2) + space.big

    readonly property int headerHeight: rowHeight

    property int toolBarIconSize: bae.loadSetting("ICON_SIZE", "BABE",
                                                  iconSizes.medium)
    property int toolBarHeight: Kirigami.Units.iconSizes.medium + (Kirigami.Settings.isMobile ?  Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing)
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
    property bool infoLabels: bae.loadSetting("PLAYBACKINFO", "BABE",
                                              false) == "true" ? true : false

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

    property int iconSize : iconSizes.medium


    readonly property real factor : Kirigami.Units.gridUnit * (isMobile ? 0.2 : 0.2)

    readonly property int contentMargins: space.medium
    readonly property int defaultFontSize: Kirigami.Theme.defaultFont.pointSize
    readonly property var fontSizes: ({
                                          tiny: defaultFontSize * 0.7,

                                          small: (isMobile ? defaultFontSize * 0.7 :
                                                             defaultFontSize * 0.8),

                                          medium: (isMobile ? defaultFontSize * 0.8 :
                                                              defaultFontSize * 0.9),

                                          default: (isMobile ? defaultFontSize * 0.9 :
                                                               defaultFontSize),

                                          big: (isMobile ? defaultFontSize :
                                                           defaultFontSize * 1.1),

                                          large: (isMobile ? defaultFontSize * 1.1 :
                                                             defaultFontSize * 1.2)
                                      })

    readonly property var space : ({
                                       tiny: Kirigami.Units.smallSpacing,
                                       small: Kirigami.Units.smallSpacing*2,
                                       medium: Kirigami.Units.largeSpacing,
                                       big: Kirigami.Units.largeSpacing*2,
                                       large: Kirigami.Units.largeSpacing*3,
                                       huge: Kirigami.Units.largeSpacing*4,
                                       enormus: Kirigami.Units.largeSpacing*5
                                   })

    readonly property var iconSizes : ({
                                           tiny : Kirigami.Units.iconSizes.small*0.5,

                                           small :  (isMobile ? Kirigami.Units.iconSizes.small*0.5:
                                                                Kirigami.Units.iconSizes.small),

                                           medium : (isMobile ? (isAndroid ? 22 : Kirigami.Units.iconSizes.small) :
                                                                Kirigami.Units.iconSizes.smallMedium),

                                           big:  (isMobile ? Kirigami.Units.iconSizes.smallMedium :
                                                             Kirigami.Units.iconSizes.medium),

                                           large: (isMobile ? Kirigami.Units.iconSizes.medium :
                                                              Kirigami.Units.iconSizes.large),

                                           huge: (isMobile ? Kirigami.Units.iconSizes.large :
                                                             Kirigami.Units.iconSizes.huge),

                                           enormous: (isMobile ? Kirigami.Units.iconSizes.huge :
                                                                 Kirigami.Units.iconSizes.enormous)

                                       })

    /***************************************************/
    /**************************************************/
    /*************************************************/

    readonly property real screenWidth : Screen.width
    readonly property real screenHeight : Screen.height

    property bool focusMode : false

    /***************************************************/
    /******************** UI COLORS *******************/
    /*************************************************/

    property string backgroundColor: Kirigami.Theme.backgroundColor
    property string textColor: Kirigami.Theme.textColor
    property string highlightColor: Kirigami.Theme.highlightColor
    property string highlightedTextColor: Kirigami.Theme.highlightedTextColor
    property string buttonBackgroundColor: Kirigami.Theme.buttonBackgroundColor
    property string viewBackgroundColor: Kirigami.Theme.viewBackgroundColor
    property string altColor: Kirigami.Theme.complementaryBackgroundColor
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

    overlay.modal: Rectangle
    {
        color: isAndroid ? darkColor : "transparent"
        opacity: 0.5
        height: root.height - playbackControls.height - toolbar.height
        y: toolbar.height
    }

    overlay.modeless: Rectangle
    {
        color: "transparent"
    }

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

    FloatingDisk
    {
        id: floatingDisk
    }


    /* UI */
    header: BabeBar
    {
        id: toolbar

        width: root.width
        height: toolBarHeight

        visible: !focusMode
        currentIndex: currentView
        onSettingsViewClicked: settingsDrawer.visible ? settingsDrawer.close() :
                                                        settingsDrawer.open()


        onTracksViewClicked:
        {
            pageStack.currentIndex = 1
            currentView = viewsIndex.tracks
        }

        onAlbumsViewClicked:
        {
            pageStack.currentIndex = 1
            albumsView.currentIndex = 0
            currentView = viewsIndex.albums
        }

        onArtistsViewClicked:
        {
            pageStack.currentIndex = 1
            artistsView.currentIndex = 0
            currentView = viewsIndex.artists
        }

        onPlaylistsViewClicked:
        {
            pageStack.currentIndex = 1
            currentView = viewsIndex.playlists
        }

        onSearchViewClicked:
        {
            pageStack.currentIndex = 1
            currentView = viewsIndex.search
            searchView.searchInput.forceActiveFocus()
        }
    }


    footer: ToolBar
    {
        id: playbackControls
        position: ToolBar.Footer
        height: toolBarHeight
        width: root.width

        visible: true
        focus: true
        leftPadding: 0
        rightPadding: 0

        FastBlur
        {
            width: parent.width
            height: parent.height-1
            y:1
            source: mainPlaylist.artwork
            radius: 100
            transparentBorder: false
            cached: true
            z: -999
        }

        Rectangle
        {
            id: footerBg
            anchors.fill: parent
            color: darkViewBackgroundColor
            opacity: focusMode ? 0.2 : opacityLevel
            z: -999

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
        }

        Slider
        {
            id: progressBar

            height: iconSizes.big
            width: parent.width
            anchors.left:  parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            padding: 0
            from: 0
            to: 1000
            value: 0
            spacing: 0
            focus: true

            onMoved: player.seek(player.duration() / 1000 * value)

            background: Rectangle
            {
                x: progressBar.leftPadding
                y: progressBar.y
                implicitWidth: 200
                implicitHeight: Kirigami.Units.devicePixelRatio * 3
                width: progressBar.availableWidth
                height: implicitHeight
                color: "transparent"

                Rectangle
                {
                    width: progressBar.visualPosition * parent.width
                    height: Kirigami.Units.devicePixelRatio * 3
                    color: babeColor
                }
            }

            handle: Rectangle
            {
                x: progressBar.leftPadding + progressBar.visualPosition
                   * (progressBar.availableWidth - width)
                y: progressBar.y - (height / 2)
                implicitWidth: progressBar.pressed ? iconSizes.medium : 0
                implicitHeight: progressBar.pressed ? iconSizes.medium : 0
                radius: progressBar.pressed ? iconSizes.medium : 0
                color: babeColor
            }
        }

//        Item
//        {
//            Layout.alignment: Qt.AlignCenter
//            Layout.fillWidth: true
//            Layout.fillHeight: true
//            Layout.row: 2
//            Layout.column: 2
//            Layout.maximumHeight: playbackInfo.visible ? playbackInfo.font.pointSize * 2 : 0

//            Label
//            {
//                id: playbackInfo

//                visible: !mainlistEmpty && infoLabels
//                //                anchors.top: playIcon.bottom
//                //                anchors.horizontalCenter: playIcon.horizontalCenter
//                width: parent.width
//                height: parent.height
//                horizontalAlignment: Qt.AlignHCenter
//                verticalAlignment: Qt.AlignVCenter
//                text: progressTimeLabel + "  /  " + (currentTrack ? (currentTrack.title ? currentTrack.title + " - " + currentTrack.artist : "--- - " + currentTrack.artist) : "") + "  /  " + durationTimeLabel
//                color: darkTextColor
//                font.pointSize: fontSizes.small
//                elide: Text.ElideRight
//            }
//        }

        RowLayout
        {
            anchors.fill: parent

            Item
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 0
            }

            Item
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumWidth: babeBtnIcon.implicitWidth * 1.3
                Layout.maximumHeight: toolBarIconSize

                BabeButton
                {
                    id: babeBtnIcon
                    anchors.centerIn: parent

                    iconName: "love"
                    iconColor: currentBabe ? babeColor : darkTextColor
                    onClicked: if (!mainlistEmpty)
                               {
                                   var value = mainPlaylist.contextMenu.babeIt(
                                               currentTrackIndex)
                                   currentBabe = value
                               }
                }
            }

            Item
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumWidth: previousBtn.implicitWidth * 1.3
                Layout.maximumHeight: toolBarIconSize

                BabeButton
                {
                    id: previousBtn
                    anchors.centerIn: parent

                    iconColor: darkTextColor
                    iconName: "media-skip-backward"
                    onClicked: Player.previousTrack()
                    onPressAndHold: Player.playAt(prevTrackIndex)
                }
            }

            Item
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumWidth: playIcon.implicitWidth * 1.3
                Layout.maximumHeight: toolBarIconSize

                BabeButton
                {
                    id: playIcon
                    anchors.centerIn: parent

                    iconColor: darkTextColor
                    iconName: isPlaying ? "media-playback-pause" : "media-playback-start"
                    onClicked:
                    {
                        if (isPlaying)
                            Player.pauseTrack()
                        else
                            Player.resumeTrack()
                    }
                }
            }

            Item
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumWidth: nextBtn.implicitWidth * 1.3
                Layout.maximumHeight: toolBarIconSize

                BabeButton
                {
                    id: nextBtn
                    anchors.centerIn: parent

                    iconColor: darkTextColor
                    iconName: "media-skip-forward"
                    onClicked: Player.nextTrack()
                    onPressAndHold: Player.playAt(Player.shuffle())
                }
            }

            Item
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.maximumWidth: shuffleBtn.implicitWidth * 1.3
                Layout.maximumHeight: toolBarIconSize

                BabeButton
                {
                    id: shuffleBtn
                    anchors.centerIn: parent

                    iconColor: darkTextColor
                    iconName: isShuffle ? "media-playlist-shuffle" : "media-playlist-repeat"
                    onClicked: isShuffle = !isShuffle
                }
            }

            Item
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 0
            }

        }
    }

//    background: Rectangle
//    {
//        anchors.fill: parent
//        color: altColor
//        z: -999
//    }

    globalDrawer: SettingsView
    {
        id: settingsDrawer
        //        contentItem.implicitWidth: columnWidth
        onIconSizeChanged: toolBarIconSize = size
    }

    Item
    {
        id: message
        visible: infoMsg.length > 0 && sync
        anchors.bottom: parent.bottom
        width: pageStack.wideMode ? columnWidth : parent.width
        height: toolBarIconSize
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
        anchors.fill: parent
        clip: true

        Connections
        {
            target: mainPlaylist
            onCoverPressed: Player.appendAll(tracks)
            onCoverDoubleClicked: Player.playAll(tracks)
        }
    }

    Page
    {
        id: views
        anchors.fill: parent
        clip: true

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
                    if (!babeitView.isConnected
                            && currentIndex === viewsIndex.vvave)
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

                    Connections
                    {
                        target: albumsView
                        onRowClicked: Player.addTrack(track)
                        onPlayAlbum: Player.playAll(tracks)
                        onPlayTrack: Player.quickPlay(track)

                        onAlbumCoverClicked:
                        {
                            var query = Q.GET.albumTracks_.arg(album)
                            query = query.arg(artist)
                            albumsView.table.headerBarTitle = album
                            albumsView.populateTable(query)
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


                    Connections
                    {
                        target: artistsView
                        onRowClicked: Player.addTrack(track)
                        onAppendAlbum: Player.appendAll(tracks)
                        onPlayTrack: Player.quickPlay(track)
                        onAlbumCoverClicked:
                        {
                            var query = Q.GET.artistTracks_.arg(artist)
                            artistsView.table.headerBarTitle = artist
                            artistsView.populateTable(query)
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
    pageStack.layers.popEnter: Transition
    {
        PauseAnimation
        {
            duration: Kirigami.Units.longDuration
        }
    }
    pageStack.layers.popExit: Transition
    {
        YAnimator
        {
            from: 0
            to: pageStack.layers.height
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutCubic
        }
    }

    pageStack.layers.pushEnter: Transition
    {
        YAnimator
        {
            from: pageStack.layers.height
            to: 0
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutCubic
        }
    }

    pageStack.layers.pushExit: Transition
    {
        PauseAnimation
        {
            duration: Kirigami.Units.longDuration
        }
    }

    pageStack.layers.replaceEnter: Transition
    {
        YAnimator
        {
            from: pageStack.layers.width
            to: 0
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutCubic
        }
    }

    pageStack.layers.replaceExit: Transition
    {
        PauseAnimation
        {
            duration: Kirigami.Units.longDuration
        }
    }

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

    Component.onCompleted:
    {
        var style = bae.loadSetting("THEME", "BABE", "Dark")
        if(isAndroid)
        {
            settingsDrawer.switchColorScheme(style)
            bae.androidStatusBarColor(viewBackgroundColor, style !== "Dark")
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
