import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import org.kde.kirigami 2.2 as Kirigami

import "utils"

import "widgets"
import "widgets/MyBeatView"
import "widgets/PlaylistsView"
import "widgets/MainPlaylist"
import "widgets/SettingsView"

import "view_models"
import "view_models/BabeDialog"

import "db/Queries.js" as Q
import "utils/Player.js" as Player

Kirigami.ApplicationWindow
{
    id: root
    visible: true
    width: !isMobile ? wideSize : 400
    minimumWidth: !isMobile ? columnWidth : 0
    minimumHeight:  !isMobile ? columnWidth+64 : 0
    height: 500
    title: qsTr("Babe")
    //    wideScreen: root.width > coverSize

    /*ALIASES*/
    property alias playIcon: playIcon
    property alias babeBtnIcon: babeBtnIcon
    property alias progressBar : progressBar
    property alias animFooter : animFooter
    property alias mainPlaylist : mainPlaylist

    /*PLAYBACK*/
    property bool shuffle : false
    property var currentTrack : ({babe: "0", stars: "0"})
    property int currentTrackIndex : 0
    property int prevTrackIndex : 0
    property string currentArtwork
    property bool currentBabe : currentTrack.babe == "0" ? false : true
    property string durationTimeLabel : "00:00"
    property string progressTimeLabel : "00:00"
    property bool isPlaying : false

    /*THEMING*/
    property string babeColor : bae.babeColor()
    property string babeAltColor : bae.babeAltColor()
    property string backgroundColor : bae.backgroundColor()
    property string foregroundColor : bae.foregroundColor()
    property string textColor : bae.textColor()
    property string babeHighlightColor : bae.highlightColor()
    property string highlightTextColor : bae.highlightTextColor()
    property string midColor : bae.midColor()
    property string midLightColor : bae.midLightColor()
    property string darkColor : bae.darkColor()
    property string baseColor : bae.baseColor()
    property string altColor : bae.altColor()
    property string shadowColor : bae.shadowColor()

    readonly property string lightBackgroundColor : "#eff0f1"
    readonly property string lightForegroundColor : "#31363b"
    readonly property string lightTextColor : "#31363b"
    readonly property string lightBabeHighlightColor : "#3daee9"
    readonly property string lightHighlightTextColor : "#eff0f1"
    readonly property string lightMidColor : "#cacaca"
    readonly property string lightMidLightColor : "#dfdfdf"
    readonly property string lightDarkColor : "#7f8c8d"
    readonly property string lightBaseColor : "#fcfcfc"
    readonly property string lightAltColor : "#eeeeee"
    readonly property string lightShadowColor : "#868686"

    readonly property string darkBackgroundColor : "#333"
    readonly property string darkForegroundColor : "#FAFAFA"
    readonly property string darkTextColor : darkForegroundColor
    readonly property string darkBabeHighlightColor : "#29B6F6"
    readonly property string darkHighlightTextColor : darkForegroundColor
    readonly property string darkMidColor : "#424242"
    readonly property string darkMidLightColor : "#616161"
    readonly property string darkDarkColor : "#212121"
    readonly property string darkBaseColor : "#212121"
    readonly property string darkAltColor : "#424242"
    readonly property string darkShadowColor : "#424242"

    Material.theme: Material.Light
    Material.accent: babeColor
    Material.background: backgroundColor
    Material.primary: backgroundColor
    Material.foreground: foregroundColor

    /*READONLY PROPS*/
    readonly property var iconSizes : ({ "small" : 16, "medium" : isMobile ? 24 : 22, "big" : 32, "large" : 48 })
    readonly property var fontSizes : ({"tiny": isMobile ? 7.5 : 7, "small" : isMobile ? 9.5 : 8.5, "medium" : isMobile ? 11 :  10, "big" : isMobile ? 11.5 : 10.5, "large" : isMobile ? 12 : 11.5})
    readonly property real opacityLevel : 0.8
    readonly property bool isMobile: bae.isMobile()
    readonly property int wideSize : bae.screenGeometry("width")*0.5
    readonly property int rowHeight: isMobile ? 60 : 52
    readonly property int rowHeightAlt: isMobile ? 48 : 32
    readonly property int headerHeight: rowHeight
    readonly property int contentMargins : isMobile ? 8 : 10
    readonly property var viewsIndex : ({
                                            "babeit": 0,
                                            "tracks" : 1,
                                            "albums" : 2,
                                            "artists" : 3,
                                            "playlists" : 4,
                                            "search" : 5
                                        })
    property bool mainlistEmpty : !mainPlaylist.table.count > 0

    /*PROPS*/
    property int toolBarIconSize: bae.loadSetting("ICON_SIZE", "BABE", iconSizes.medium)
    property int toolBarHeight : isMobile ? 48 : toolBarIconSize *2

    property int columnWidth: Kirigami.Units.gridUnit * 18
    property int coverSize: isMobile ? Math.sqrt(root.width*root.height)*0.4 : columnWidth * 0.65
    property int currentView : viewsIndex.tracks

    /*USEFUL PROPS*/
    property string syncPlaylist : ""
    property bool sync : false
    property string infoMsg : ""
    property bool infoLabels : bae.loadSetting("PLAYBACKINFO", "BABE", false) == "true" ? true : false

    /*SIGNALS*/
    signal missingAlert(var track)

    /*CONF*/
    pageStack.defaultColumnWidth: columnWidth
    pageStack.initialPage: [mainPlaylist, views]
    pageStack.interactive: isMobile
    pageStack.separatorVisible: pageStack.wideMode

    overlay.modal: Rectangle
    {
        color: isMobile ? "#8f28282a" : "transparent"
    }

    overlay.modeless: Rectangle
    {
        color: "transparent"
    }

    /*HANDLE EVENTS*/
    onWidthChanged: if(isMobile)
                    {
                        if(width > height)
                            mainPlaylist.cover.visible = false
                        else  mainPlaylist.cover.visible = true
                    }

    onClosing: Player.savePlaylist()

    pageStack.onCurrentIndexChanged:
    {
        if(pageStack.currentIndex === 0 && isMobile && !pageStack.wideMode)
        {
            bae.androidStatusBarColor(babeColor)
            Material.background = babeColor
        }else
        {
            bae.androidStatusBarColor(babeAltColor)
            Material.background = babeAltColor
        }
    }

    onMissingAlert:
    {
        missingDialog.message = track.title +" by "+track.artist+" is missing"
        missingDialog.messageBody = "Do you want to remove it from your collection?"
        missingDialog.open()
    }

    Component.onCompleted:
    {
        if(isMobile) settingsDrawer.switchColorScheme(bae.loadSetting("THEME", "BABE", "Dark"))
        settingsDrawer.visible = false
    }


    /*COMPONENTS*/
    BabeNotify { id: babeNotify }

    BabeMessage
    {
        id: missingDialog
        width: isMobile ? parent.width *0.9 : parent.width*0.4
        title: "Missing file"
        onAccepted:
        {
            bae.removeTrack(currentTrack.url)
            mainPlaylist.table.model.remove(mainPlaylist.table.currentIndex)

        }
    }

    /*CONNECTIONS*/
    Connections
    {
        target: player
        onPos: progressBar.value = pos
        onTiming: progressTimeLabel = time
        onDurationChanged: durationTimeLabel = time
        onFinished: Player.nextTrack()
        onIsPlaying:  isPlaying = playing
    }

    Connections
    {
        target: bae
        onRefreshTables:
        {
            console.log("Clearing tables")
            tracksView.list.clearTable()
            albumsView.clearGrid()
            artistsView.clearGrid()

            tracksView.populate()
            albumsView.populate()
            artistsView.populate()
        }

        onTrackLyricsReady:
        {
            if(url === currentTrack.url)
                root.mainPlaylist.infoView.lyrics = lyrics
        }

        onSkipTrack: Player.nextTrack()
        onBabeIt: Player.babeTrack()
    }


    /* UI */
    header: BabeBar
    {
        height: toolBarHeight
        visible: true
        currentIndex: currentView
        bgColor: isMobile && pageStack.currentIndex === 0 && !pageStack.wideMode ? babeColor : babeAltColor
        textColor: isMobile && pageStack.currentIndex === 0 && !pageStack.wideMode ? "#FFF" : bae.foregroundColor()

        onSettingsViewClicked: settingsDrawer.visible ? settingsDrawer.close() : settingsDrawer.open()

        onTracksViewClicked:
        {
            pageStack.currentIndex = 1
            currentView = viewsIndex.tracks
        }

        onAlbumsViewClicked:
        {
            pageStack.currentIndex = 1
            currentView = viewsIndex.albums
        }

        onArtistsViewClicked:
        {
            pageStack.currentIndex = 1
            currentView = viewsIndex.artists
        }

        onPlaylistsViewClicked:
        {
            pageStack.currentIndex = 1
            currentView = viewsIndex.playlists
        }

        onBabeViewClicked:
        {
            pageStack.currentIndex = 1
            currentView = viewsIndex.babeit
        }

        onSearchViewClicked:
        {
            pageStack.currentIndex = 1
            currentView = viewsIndex.search
        }
    }

    footer: Item
    {
        id: playbackControls
        anchors.horizontalCenter: parent.horizontalCenter
        height: visible ? headerHeight : 0
        width: root.width
        visible: true

        FastBlur
        {
            anchors.fill: parent
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
            color: midLightColor
            opacity: opacityLevel
            z: -999

            SequentialAnimation
            {
                id: animFooter
                PropertyAnimation
                {
                    target: footerBg
                    property: "color"
                    easing.type: Easing.InOutQuad
                    from: darkColor
                    to: midLightColor
                    duration: 500
                }
            }
        }

        Slider
        {
            id: progressBar

                        height: 10
            width: parent.width
            z: 999
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            padding: 0
            from: 0
            to: 1000
            value: 0
            spacing: 0

            onMoved: player.seek(player.duration() / 1000 * value);

            background: Rectangle
            {
                x: progressBar.leftPadding
                y: progressBar.y
                implicitWidth: 200
                implicitHeight: 10
                width: progressBar.availableWidth
                height: implicitHeight
                color: "transparent"

                Kirigami.Separator
                {

                    Rectangle
                    {
                        anchors.fill: parent
                        color: Kirigami.Theme.viewFocusColor
                    }

                    anchors
                    {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }
                }

                Rectangle
                {
                    width: progressBar.visualPosition * parent.width
                    height: 4
                    color: babeColor
                }
            }

            handle: Rectangle
            {
                x: progressBar.leftPadding + progressBar.visualPosition * (progressBar.availableWidth - width)
                y: progressBar.y-(height/2)
                implicitWidth: progressBar.pressed ? 16 : 0
                implicitHeight: progressBar.pressed ? 16 : 0
                radius:  progressBar.pressed ? 16 : 0
                color: babeColor
            }

        }


        GridLayout
        {
            anchors.fill: parent
            height: parent.height
            width: parent.width

            rowSpacing: 0
            columnSpacing: 0
            rows: 2
            columns: 2


            Item
            {
                Layout.alignment: Qt.AlignLeft
                Layout.fillHeight: true
                Layout.maximumWidth: miniArtwork.visible ? headerHeight : 0
                Layout.minimumWidth: miniArtwork.visible ? headerHeight : 0
                Layout.minimumHeight: miniArtwork.visible ? headerHeight : 0
                Layout.maximumHeight: miniArtwork.visible ? headerHeight : 0
                Layout.row: 1
                Layout.rowSpan: 2
                Layout.column: 1

                //                height: headerHeight
                //                width:  miniArtwork.visible ? headerHeight : 0

                Image
                {
                    id: miniArtwork
                    visible: ((!pageStack.wideMode && pageStack.currentIndex !== 0) || !mainPlaylist.cover.visible) && !mainlistEmpty

                    height: headerHeight
                    width: headerHeight
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    source:
                    {
                        if(currentArtwork)
                            (currentArtwork.length > 0 && currentArtwork !== "NONE")? "file://"+encodeURIComponent(currentArtwork) : "qrc:/assets/cover.png"
                        else "qrc:/assets/cover.png"
                    }
                    fillMode:  Image.PreserveAspectFit
                    cache: false
                    antialiasing: true

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            if(!isMobile && pageStack.wideMode)
                                root.width = columnWidth
                            pageStack.currentIndex = 0
                        }
                    }
                }
            }

            Item
            {
                Layout.alignment: Qt.AlignCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.row: 2
                Layout.column: 2
                Layout.maximumHeight: playbackInfo.visible ? playbackInfo.font.pointSize*2 : 0
                Label
                {
                    id: playbackInfo

                    visible: !mainlistEmpty && infoLabels
                    //                anchors.top: playIcon.bottom
                    //                anchors.horizontalCenter: playIcon.horizontalCenter
                    width: parent.width
                    height: parent.height
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    text: progressTimeLabel  + "  /  " + (currentTrack ? (currentTrack.title ? currentTrack.title + " - " + currentTrack.artist : "--- - "+currentTrack.artist) : "") + "  /  " + durationTimeLabel
                    color: foregroundColor
                    font.pointSize: fontSizes.tiny
                    elide: Text.ElideRight
                }
            }

            RowLayout
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                Layout.row: 1
                Layout.column: 2

                BabeButton
                {
                    id: babeBtnIcon

                    iconName: "love"
                    iconColor: currentBabe ? babeColor : defaultColor
                    onClicked:
                    {
                        var value = mainPlaylist.contextMenu.babeIt(currentTrackIndex)
                        currentTrack.babe = value ? "1" : "0"
                        currentBabe = value
                    }
                }

                BabeButton
                {
                    id: previousBtn

                    iconName: "media-skip-backward"
                    onClicked: Player.previousTrack()
                    onPressAndHold: Player.playAt(prevTrackIndex)
                }

                BabeButton
                {
                    id: playIcon

                    iconName:  isPlaying ? "media-playback-pause" :  "media-playback-start"
                    onClicked:
                    {
                        if(player.isPaused()) Player.resumeTrack()
                        else Player.pauseTrack()
                    }
                }

                BabeButton
                {
                    id: nextBtn

                    iconName: "media-skip-forward"
                    onClicked: Player.nextTrack()
                    onPressAndHold: Player.playAt(Player.shuffle())
                }

                BabeButton
                {
                    id: shuffleBtn
                    iconName: shuffle ? "media-playlist-shuffle" : "media-playlist-repeat"
                    onClicked: shuffle = !shuffle
                }

            }



        }
    }

    background: Rectangle
    {
        anchors.fill: parent
        color: altColor
        z: -999
    }

    globalDrawer: SettingsView
    {
        id: settingsDrawer
        //        contentItem.implicitWidth: columnWidth
        onIconSizeChanged: toolBarIconSize = size
    }

    Item
    {
        id: message
        visible: infoMsg.length > 0
        anchors.bottom: parent.bottom
        width: pageStack.wideMode ? columnWidth : parent.width
        height: toolBarIconSize
        z:999

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
            color: foregroundColor

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
                    to: foregroundColor
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

        Column
        {
            anchors.fill: parent

            SwipeView
            {
                id: swipeView
                width: parent.width
                height: parent.height

                Component.onCompleted: contentItem.interactive = root.isMobile

                currentIndex: currentView

                onCurrentItemChanged: currentItem.forceActiveFocus()

                onCurrentIndexChanged:
                {
                    currentView = currentIndex
                    if(pageStack.currentIndex === 0) mainPlaylist.list.forceActiveFocus()
                    else if(currentView === viewsIndex.tracks) tracksView.forceActiveFocus()
                    else if(currentView === viewsIndex.search) searchView.forceActiveFocus()

                }

                LogginForm
                {
                    id: babeView
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
                        onAppendAlbum: Player.appendAll(tracks)
                        onPlayTrack: Player.quickPlay(track)
                    }
                }

                ArtistsView
                {
                    id: artistsView

                    Connections
                    {
                        target: artistsView
                        onRowClicked: Player.addTrack(track)
                        onPlayAlbum: Player.playAll(tracks)
                        onAppendAlbum: Player.appendAll(tracks)
                        onPlayTrack: Player.quickPlay(track)
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
                        onPlayAll: Player.playAll(tracks)
                        onAppendAll: Player.appendAll(tracks)
                        onPlaySync:
                        {
                            var tracks = bae.get(Q.GET.playlistTracks_.arg(playlist))
                            Player.playAll(tracks)
                            root.sync = true
                            root.syncPlaylist = playlist
                            root.infoMsg = "Syncing to "+ playlist
                            console.log("ALLOW PLAYLIOST SYNC FOR: " ,root.syncPlaylist = playlist)
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
                            var query = Q.GET.albumTracks_.arg(searchView.searchTable.model.get(index).album)
                            query = query.arg(searchView.searchTable.model.get(index).artist)

                            Player.playAll(bae.get(query))

                        }
                    }
                }

            }
        }
    }
    /*animations*/

    pageStack.layers.popEnter: Transition {
        PauseAnimation {
            duration: Kirigami.Units.longDuration
        }
    }
    pageStack.layers.popExit: Transition {
        YAnimator {
            from: 0
            to: pageStack.layers.height
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutCubic
        }
    }

    pageStack.layers.pushEnter: Transition {
        YAnimator {
            from: pageStack.layers.height
            to: 0
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutCubic
        }
    }

    pageStack.layers.pushExit: Transition {
        PauseAnimation {
            duration: Kirigami.Units.longDuration
        }
    }

    pageStack.layers.replaceEnter: Transition {
        YAnimator {
            from: pageStack.layers.width
            to: 0
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutCubic
        }
    }

    pageStack.layers.replaceExit: Transition {
        PauseAnimation {
            duration: Kirigami.Units.longDuration
        }
    }

    /*FUNCTIONS*/
    function infoMsgAnim()
    {
        animBg.running = true
        animTxt.running = true
    }

}
