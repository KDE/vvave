import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.2 as Kirigami

import "../InfoView"

import "../../utils/Player.js" as Player
import "../../db/Queries.js" as Q
import "../../utils"
import "../../widgets"
import "../../view_models"
import "../../view_models/BabeTable"

Item
{

    id: mainPlaylistRoot

    readonly property real opacityLevel : 0.7

    property var currentTrack
    property int currentTrackIndex : 0
    property int prevTrackIndex : 0
    property string currentArtwork
    property bool shuffle : false

    property alias progressBar : progressBar
    property alias cover : cover
    property alias list : list
    property alias playIcon : playIcon
    property alias babeBtnIcon: babeBtnIcon
    property alias infoView : infoView

    property alias durationTime : durationTime
    property alias progressTime : progressTime

    signal coverDoubleClicked(var tracks)
    signal coverPressed(var tracks)
    //                    Component.onCompleted:
    //                    {
    //                        if(list.count>0)
    //                            root.width = coverSize
    //                        else
    //                            root.width = coverSize*3
    //                    }
    Rectangle
    {
        anchors.fill: parent
        color: midLightColor
        z: -999
    }

    GridLayout
    {
        id: playlistLayout
        anchors.fill: parent
        width: parent.width
        rowSpacing: 0
        rows: 4
        columns: 1

        Item
        {
            id: cover
            Layout.row: 1
            Layout.column: 1
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? coverSize : 0
            Layout.maximumHeight: 300
            visible: list.count > 0

            Rectangle
            {
                anchors.fill: parent
                color: midColor
                z: -999
            }

            FastBlur
            {
                width: mainPlaylistRoot.width
                height: mainPlaylistItem.y
                source: artwork
                radius: 100
                transparentBorder: false
                //                opacity: 0.8
                cached: true
            }

            Image
            {
                id: artwork
                visible: cover.visible
                width: parent.height < 300 ? parent.height : 300
                height: parent.height
                anchors.centerIn: parent
                source: currentArtwork ? "file://"+encodeURIComponent(currentArtwork)  : "qrc:/assets/cover.png"
                fillMode: Image.PreserveAspectFit

                MouseArea
                {
                    anchors.fill: parent
                    onDoubleClicked: gomini()
                    //                    {
                    //                                                var query = Q.GET.albumTracks_.arg(currentTrack.album)
                    //                                                query = query.arg(currentTrack.artist)

                    //                                                var tracks = bae.get(query)
                    //                                                coverDoubleClicked(tracks)


                    //                    }

                    onPressAndHold:
                    {
                        var query = Q.GET.albumTracks_.arg(currentTrack.album)
                        query = query.arg(currentTrack.artist)
                        var tracks = bae.get(query)
                        coverPressed(tracks)
                    }

                    //                    onClicked:
                    //                    {
                    //                        if(stackView.currentItem !== list)
                    //                            stackView.pop(list)
                    //                        else
                    //                        {
                    //                            stackView.push(infoView)
                    //                            infoView.currentView = 1
                    //                        }
                    //                    }

                }
            }


        }

        Item
        {
            id: playbackControls
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            Layout.row: 2
            Layout.column: 1
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 48 : 0
            //            anchors.top: cover.bottom
            visible: list.count > 0

            Rectangle
            {
                anchors.fill: parent
                color: midLightColor
                opacity: opacityLevel
                z: -999
            }



            PlaylistMenu
            {
                id: playlistMenu
                onClearOut: Player.clearOutPlaylist()
                onHideCover: cover.visible = !cover.visible
                onClean: Player.cleanPlaylist()

                onSaveToClicked: list.saveList()
            }

            MouseArea
            {
                anchors.fill: parent
                drag.target: playbackControls
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY: coverSize

                onMouseYChanged:
                {
                    cover.height = playbackControls.y

                    if(playbackControls.y < coverSize*0.8)
                    {
                        cover.visible = false
                        playbackControls.y = 0
                    }else cover.visible = true

                }
            }

            RowLayout
            {
                anchors.fill: parent
                anchors.centerIn: parent
                //                spacing: 0
                //                Layout.margins: 0

                Item
                {
                    Layout.fillWidth: true

                    BabeButton
                    {

                        id: infoBtn
                        anchors.centerIn: parent

                        iconName: stackView.currentItem === list ? "documentinfo" : "arrow-left"
                        onClicked:
                        {
                            if( stackView.currentItem !== list)
                            {
                                cover.visible  = true
                                stackView.pop(list) }
                            else {
                                cover.visible  = false
                                stackView.push(infoView)
                            }
                        }
                    }
                }


                BabeButton
                {
                    id: babeBtnIcon
                    iconName: "love" //"love-amarok"
                    iconColor: defaultColor
                    onClicked: Player.babeTrack()
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
                    iconName: "media-playback-start"
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

                Item
                {
                    Layout.fillWidth: true
                    BabeButton
                    {
                        id: menuBtn
                        anchors.centerIn: parent
                        Layout.fillWidth: true
                        iconName: /*"application-menu"*/ "overflow-menu"
                        onClicked: root.isMobile ? playlistMenu.open() : playlistMenu.popup()
                    }
                }

            }
        }

        Item
        {
            id: slideBar
            Layout.row: 3
            Layout.column: 1
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 48 : 0

            //            height: 48
            anchors.top: playbackControls.bottom
            visible: list.count > 0

            Rectangle
            {
                anchors.fill: parent
                color: midLightColor
                opacity: opacityLevel
                z: -999
            }

            GridLayout
            {
                anchors.fill: parent
                columns:3
                rows:2

                Label
                {
                    id: progressTime
                    Layout.row: 1
                    Layout.column: 1
                    Layout.fillWidth:true
                    Layout.alignment: Qt.AlignCenter
                    horizontalAlignment: Qt.AlignHCenter
                    text: "00:00"
                    color: foregroundColor
                    font.pointSize: 8
                    elide: Text.ElideRight

                }

                Label
                {
                    id: currentTrackInfo
                    Layout.maximumWidth: parent.width*0.7
                    Layout.row: 1
                    Layout.column: 2
                    Layout.fillWidth:true
                    Layout.alignment: Qt.AlignCenter
                    horizontalAlignment: Qt.AlignHCenter
                    text: currentTrack ? (currentTrack.title ? currentTrack.title + " - " + currentTrack.artist : "--- - "+currentTrack.artist) : ""
                    color: foregroundColor
                    font.pointSize: 8
                    elide: Text.ElideRight
                }

                Label
                {
                    id: durationTime
                    Layout.row: 1
                    Layout.column: 3
                    Layout.fillWidth:true
                    Layout.alignment: Qt.AlignCenter
                    horizontalAlignment: Qt.AlignHCenter
                    text: "00:00"
                    color: foregroundColor
                    font.pointSize: 8
                    elide: Text.ElideRight

                }

                Slider
                {
                    id: progressBar

                    Layout.row: 2
                    Layout.column: 1
                    Layout.columnSpan: 3
                    Layout.fillWidth:true
                    Layout.fillHeight: true

                    from: 0
                    to: 1000
                    value: 0

                    spacing: 0

                    onMoved: player.seek(player.duration() / 1000 * value);


                    background: Rectangle
                    {
                        x: progressBar.leftPadding
                        y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 2
                        width: progressBar.availableWidth
                        height: implicitHeight
                        color: foregroundColor

                        Rectangle
                        {
                            width: progressBar.visualPosition * parent.width
                            height: parent.height
                            color: babeColor
                        }
                    }

                    handle: Rectangle
                    {
                        x: progressBar.leftPadding + progressBar.visualPosition * (progressBar.availableWidth - width)
                        y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 13
                        color: babeColor
                    }
                }
            }
        }


        Item
        {
            id: mainPlaylistItem
            Layout.row: 4
            Layout.column: 1
            Layout.fillWidth: true
            Layout.fillHeight: true
            anchors.top: slideBar.bottom


            //            anchors.bottom: mainPlaylistRoot.searchBox
            StackView
            {
                id: stackView
                anchors.fill: parent
                focus: true

                pushEnter: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 0
                        to:1
                        duration: 200
                    }
                }
                pushExit: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 1
                        to:0
                        duration: 200
                    }
                }
                popEnter: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 0
                        to:1
                        duration: 200
                    }
                }
                popExit: Transition {
                    PropertyAnimation {
                        property: "opacity"
                        from: 1
                        to:0
                        duration: 200
                    }
                }

                initialItem: BabeTable
                {
                    id: list
                    anchors.fill: parent
                    quickPlayVisible: false
                    coverArtVisible: true
                    trackRating: true
                    holder.message : "<h2>Meh!</h2><p>Start putting together your playlist!</p>"
                    holder.emoji: "qrc:/assets/face-sleeping.png"

                    Rectangle
                    {
                        anchors.fill: parent
                        color: altColor
                        z: -999

                    }

                    onRowClicked:
                    {
                        prevTrackIndex = currentTrackIndex
                        currentTrackIndex = currentIndex

                        Player.playAt(index)
                    }
                    onArtworkDoubleClicked:
                    {
                        var query = Q.GET.albumTracks_.arg(model.get(index).album)
                        query = query.arg(model.get(index).artist)

                        Player.playAll(bae.get(query))
                        //                        Player.appendTracksAt(bae.get(query),index)

                    }

                    Component.onCompleted:
                    {
                        var list = bae.lastPlaylist()
                        var n = list.length

                        if(n>0)
                        {
                            for(var i = 0; i < n; i++)
                            {
                                var where = "url = \""+list[i]+"\""
                                var query = Q.GET.tracksWhere_.arg(where)
                                var track = bae.get(query)
                                Player.appendTrack(track[0])
                            }
                        }else
                        {
                            var where = "babe = 1"
                            var query = Q.GET.tracksWhere_.arg(where)
                            var tracks = bae.get(query)

                            for(var pos=0; pos< tracks.length; pos++)
                                Player.appendTrack(tracks[pos])

                        }
                        Player.playAt(0)

                        //                                    var pos = bae.lastPlaylistPos()
                        //                                    console.log("POSSS:", pos)
                        //                                    list.currentIndex = pos
                        //                                    play(list.model.get(pos))
                    }
                }

                InfoView
                {
                    id: infoView
                    width: parent.width
                    height: parent.height
                }

            }
        }
    }

    function gomini()
    {
        if(!isMobile)
        {
            if(root.header.visible)
            {
                root.maximumWidth = columnWidth
                root.minimumWidth = columnWidth
                root.maximumHeight = mainPlaylistItem.y
                root.minimumHeight = mainPlaylistItem.y
                root.header.visible = false
                root.footer.visible = false
                infoBtn.visible = false
                menuBtn.visible = false

            }else
            {
                cover.y = 0
                root.maximumWidth = bae.screenGeometry("width")
                root.minimumWidth = columnWidth
                root.maximumHeight = bae.screenGeometry("height")
                root.minimumHeight = columnWidth

                root.width = columnWidth
                root.height = 700
                root.header.visible = true
                root.footer.visible = true
                infoBtn.visible = true
                menuBtn.visible = true
            }
        }
    }
}
