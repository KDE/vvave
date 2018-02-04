import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.2 as Kirigami
import QtQuick.Controls.Material 2.1

import "db/Queries.js" as Q
import "utils/Player.js" as Player
import "utils"
import "widgets"
import "widgets/MyBeatView"
import "widgets/PlaylistsView"
import "widgets/MainPlaylist"
import "widgets/SettingsView"
import "view_models"
import "view_models/BabeDialog"

Kirigami.ApplicationWindow
{
    id: root
    visible: true
    width: !isMobile ? wideSize : 400
    minimumWidth: !isMobile ? columnWidth : 0
    minimumHeight:  !isMobile ? columnWidth+64 : 0
    height: 500
    title: qsTr("Babe")
    wideScreen: root.width > coverSize

    /*THEMING*/

    property int toolBarIconSize: bae.loadSetting("ICON_SIZE", "BABE", isMobile ?  24 : 22)
    property int toolBarHeight : isMobile ? 48 : toolBarIconSize *2
    property int contentMargins : 15

    property string infoMsg : ""

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

    Material.theme: Material.Light
    Material.accent: babeColor
    Material.background: backgroundColor
    Material.primary: backgroundColor
    Material.foreground: foregroundColor

    /*SIGNALS*/

    signal missingAlert(var track)

    /*READONLY PROPS*/
    readonly property real opacityLevel : 0.7
    readonly property bool isMobile: bae.isMobile()
    readonly property int wideSize : bae.screenGeometry("width")*0.5
    readonly property int rowHeight: isMobile ? 64 : 52
    readonly property int rowHeightAlt: isMobile ? 48 : 32

    /*PROPS*/

    property int columnWidth: Kirigami.Units.gridUnit * 20
    property int coverSize: isMobile ? Math.sqrt(root.width*root.height)*0.4 : columnWidth * 0.65
    property int currentView : 0

    property alias mainPlaylist : mainPlaylist

    /*USEFUL PROPS*/
    property string syncPlaylist : ""
    property bool sync : false

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

    onWidthChanged: if(root.isMobile)
                    {
                        if(root.width>root.height)
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

    Component.onCompleted:
    {
        if(isMobile) settingsDrawer.switchColorScheme(bae.loadSetting("THEME", "BABE", "Dark"))
    }

    BabeNotify
    {
        id: babeNotify
    }

    BabeMessage
    {
        id: missingDialog
        width: isMobile ? parent.width *0.9 : parent.width*0.4
        title: "Missing file"
        onAccepted:
        {
            bae.removeTrack(mainPlaylist.currentTrack.url)
            mainPlaylist.list.model.remove(mainPlaylist.list.currentIndex)

        }
    }

    onMissingAlert:
    {
        missingDialog.message = track.title +" by "+track.artist+" is missing"
        missingDialog.messageBody = "Do you want to remove it from your collection?"
        missingDialog.open()
    }


    function runSearch()
    {
        if(searchInput.text)
        {
            if(searchInput !== searchView.headerTitle)
            {
                var query = searchInput.text
                searchView.headerTitle = query
                var queries = query.split(",")
                searchView.searchRes = bae.searchFor(queries)

                searchView.populate(searchView.searchRes)
            }
            //                albumsView.filter(res)
            currentView = 5
            pageStack.currentIndex = 1
        }
    }

    function clearSearch()
    {
        searchInput.clear()
        searchView.clearTable()
        searchView.headerTitle = ""
        searchView.searchRes = []
        //        currentView = 0
    }

    function infoMsgAnim()
    {
        animBg.running = true
        animTxt.running = true
    }

    Connections
    {
        target: player
        onPos: mainPlaylist.progressBar.value = pos
        onTiming: mainPlaylist.progressTime.text = time
        onDurationChanged: mainPlaylist.durationTime.text = time
        onFinished: Player.nextTrack()
    }

    Connections
    {
        target: bae
        onRefreshTables:
        {
            tracksView.clearTable()
            albumsView.clearGrid()
            artistsView.clearGrid()

            tracksView.populate()
            albumsView.populate()
            artistsView.populate()
        }

        onTrackLyricsReady:
        {
            if(url === root.mainPlaylist.currentTrack.url)
                root.mainPlaylist.infoView.lyrics = lyrics
        }

        onSkipTrack: Player.nextTrack()
        onBabeIt: Player.babeTrack()
    }

    header: BabeBar
    {
        id: mainToolbar
        visible: true
        currentIndex: currentView
        bgColor: isMobile && pageStack.currentIndex === 0 && !pageStack.wideMode ? babeColor : babeAltColor
        textColor: isMobile && pageStack.currentIndex === 0 && !pageStack.wideMode ? "#FFF" : bae.foregroundColor()

        onPlaylistViewClicked:
        {
            if(!isMobile && pageStack.wideMode)
                root.width = columnWidth

            pageStack.currentIndex = 0
        }

        onTracksViewClicked:
        {
            //            if(!isMobile && !pageStack.wideMode)
            //                root.width = wideSize

            pageStack.currentIndex = 1
            currentView = 0
        }

        onAlbumsViewClicked:
        {
            //            if(!isMobile && !pageStack.wideMode)
            //                root.width = wideSize

            pageStack.currentIndex = 1
            currentView = 1
        }

        onArtistsViewClicked:
        {
            //            if(!isMobile && !pageStack.wideMode)
            //                root.width = wideSize

            pageStack.currentIndex = 1
            currentView = 2
        }

        onPlaylistsViewClicked:
        {
            //            if(!isMobile && !pageStack.wideMode)
            //                root.width = wideSize

            pageStack.currentIndex = 1
            currentView = 3
        }

        onBabeViewClicked:
        {
            //            if(!isMobile && !pageStack.wideMode)
            //                root.width = wideSize

            pageStack.currentIndex = 1
            currentView = 4
        }
    }

    footer: Rectangle
    {
        id: searchBox
        height: toolBarHeight
        color: searchInput.activeFocus ? midColor : midLightColor

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

        RowLayout
        {
            anchors.fill: parent
            height: parent.height

            Item
            {
                Layout.fillWidth: true
                Layout.fillHeight: true

                TextInput
                {
                    id: searchInput
                    color: foregroundColor
                    anchors.fill: parent
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    selectByMouse: !root.isMobile
                    selectionColor: babeHighlightColor
                    selectedTextColor: foregroundColor
                    property string placeholderText: "Search..."

                    onAccepted: runSearch()

                    BabeButton
                    {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        visible: searchInput.activeFocus
                        iconName: "edit-clear"
                        onClicked: clearSearch()
                    }
                }
            }

            BabeButton
            {
                id: searchBtn
                iconColor: currentView === 5 ? babeColor : foregroundColor
                //                visible: !(searchInput.focus || searchInput.text)
                iconName: "edit-find" //"search"
                onClicked:
                {
                    if(searchView.count>0)
                    {
                        currentView = 5
                        pageStack.currentIndex = 1

                    }else
                        searchInput.forceActiveFocus()

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
            font.pointSize: 9
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

                onCurrentItemChanged:
                {
                    currentItem.forceActiveFocus();
                }
                onCurrentIndexChanged:
                {
                    currentView = currentIndex
                    if(currentView === 0) mainPlaylist.list.forceActiveFocus()
                    else if(currentView === 1) tracksView.forceActiveFocus()

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

                LogginForm
                {
                    id: babeView
                }


                SearchTable
                {
                    id: searchView
                    Connections
                    {
                        target: searchView
                        onRowClicked: Player.addTrack(searchView.model.get(index))
                        onQuickPlayTrack: Player.quickPlay(searchView.model.get(index))
                        onPlayAll: Player.playAll(searchView.searchRes)
                        onAppendAll: Player.appendAll(searchView.searchRes)
                        //                        onHeaderClosed: clearSearch()
                        onArtworkDoubleClicked:
                        {
                            var query = Q.GET.albumTracks_.arg(searchView.model.get(index).album)
                            query = query.arg(searchView.model.get(index).artist)

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
}
