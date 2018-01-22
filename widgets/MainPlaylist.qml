import QtQuick 2.9
import QtQuick.Controls 2.2
import QtLocation 5.9
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import "../utils/Icons.js" as MdiFont
import "../utils/Player.js" as Player
import "../db/Queries.js" as Q
import "../utils"
import "../view_models"
import "../widgets"

Item
{

    id: mainPlaylistRoot
    property var currentTrack
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
    //                            root.width = columnWidth
    //                        else
    //                            root.width = columnWidth*3
    //                    }
    Rectangle
    {
        anchors.fill: parent
        color: bae.midLightColor()
        z: -999
    }

    GridLayout
    {
        id: playlistLayout
        anchors.fill: parent
        rowSpacing: 0
        rows: 4
        columns: 1

        Item
        {
            id: cover
            Layout.row: 1
            Layout.column: 1
            Layout.fillWidth: true
            Layout.preferredHeight: columnWidth
            Layout.maximumHeight: 300
            visible: list.count > 0

            Rectangle
            {
                anchors.fill: parent
                color: bae.midLightColor()
                z: -999
            }

            FastBlur
            {
                width: mainPlaylistRoot.width
                height: mainPlaylist.y
                source: artwork
                radius: 100
                transparentBorder: true
                cached: true
            }

            Image
            {
                id: artwork
                width: parent.height < 300 ? parent.height : 300
                height: parent.height
                anchors.centerIn: parent
                source: currentArtwork ? "file://"+encodeURIComponent(currentArtwork)  : "qrc:/assets/cover.png"
                fillMode: Image.PreserveAspectFit

                MouseArea
                {
                    anchors.fill: parent
                    onDoubleClicked:
                    {
                        var query = Q.Query.albumTracks_.arg(currentTrack.album)
                        query = query.arg(currentTrack.artist)

                        var tracks = bae.get(query)
                        coverDoubleClicked(tracks)
                    }

                    onPressAndHold:
                    {
                        var query = Q.Query.albumTracks_.arg(currentTrack.album)
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
            Layout.row: 2
            Layout.column: 1
            Layout.fillWidth: true
            height: 48
            //            anchors.top: cover.bottom
            visible: list.count > 0

            Rectangle
            {
                anchors.fill: parent
                color: bae.midLightColor()
                opacity: 0.8
                z: -999
            }
            //            onYChanged:
            //            {
            //                if(playbackControls.y<columnWidth/4)
            //                {
            //                    cover.visible = false
            //                    playbackControls.y = 0

            //                }else
            //                {
            //                    cover.visible = true
            //                    playbackControls.y = columnWidth
            //                }
            //            }

            PlaylistMenu
            {
                id: playlistMenu
                onClearOut: Player.clearOutPlaylist()
                onHideCover: cover.visible = !cover.visible
                onClean: Player.cleanPlaylist()
            }

            MouseArea
            {
                anchors.fill: parent
                drag.target: playbackControls
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY: columnWidth
                //                onClicked:
                //                {
                //                    if(!bae.isMobile())
                //                        cover.visible = !cover.visible
                //                }


                onMouseYChanged:
                {
                    cover.height = playbackControls.y

                    if(playbackControls.y < columnWidth*0.8)
                    {
                        cover.visible = false
                        playbackControls.y = 0

                    }else
                    {
                        cover.visible = true
                        //                        playbackControls.y = columnWidth
                    }
                }
            }

            RowLayout
            {
                width: parent.width
                height: parent.height
                anchors.fill: parent

                Row
                {
                    Layout.alignment: Qt.AlignLeft

                    ToolButton
                    {
                        id: infoBtn
                        BabeIcon
                        {
                            text: stackView.currentItem === list ? MdiFont.Icon.informationOutline : MdiFont.Icon.arrowLeft
                        }
                        onClicked:
                        {
                            if(stackView.currentItem !== list)
                            {
                                stackView.pop(list)
                                cover.visible = true

                            }
                            else
                            {
                                cover.visible = false
                                stackView.push(infoView)
                            }
                        }
                    }

                }

                Row
                {
                    Layout.alignment: Qt.AlignCenter
                    ToolButton
                    {
                        BabeIcon
                        {
                            id: babeBtnIcon
                            text: MdiFont.Icon.heartOutline
                            color: defaultColor
                        }

                        onClicked: Player.babeTrack()
                    }

                    ToolButton
                    {
                        id: previousBtn
                        BabeIcon {text: MdiFont.Icon.skipPrevious}
                        onClicked: Player.previousTrack()
                    }

                    ToolButton
                    {
                        id: playBtn
                        BabeIcon {id: playIcon; text: MdiFont.Icon.play }
                        onClicked:
                        {
                            if(player.isPaused()) Player.resumeTrack()
                            else Player.pauseTrack()
                        }
                    }

                    ToolButton
                    {
                        id: nextBtn
                        BabeIcon{text: MdiFont.Icon.skipNext}
                        onClicked: Player.nextTrack()

                    }

                    ToolButton
                    {
                        id: shuffleBtn
                        BabeIcon { text: shuffle ? MdiFont.Icon.shuffle : MdiFont.Icon.shuffleDisabled}

                        onClicked: shuffle = !shuffle
                    }
                }

                Row
                {
                    Layout.alignment: Qt.AlignRight

                    ToolButton
                    {
                        id: menuBtn
                        BabeIcon {text: MdiFont.Icon.dotsVertical}
                        onClicked: bae.isMobile() ? playlistMenu.open() : playlistMenu.popup()
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
            height: 48
            anchors.top: playbackControls.bottom
            visible: list.count > 0

            Rectangle
            {
                anchors.fill: parent
                color: bae.midLightColor()
                opacity: 0.8
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
                    color: bae.foregroundColor()
                    font.pointSize: 8

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
                    color: bae.foregroundColor()
                    font.pointSize: 8
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
                        color: bae.foregroundColor()

                        Rectangle
                        {
                            width: progressBar.visualPosition * parent.width
                            height: parent.height
                            color: bae.babeColor()
                        }
                    }

                    handle: Rectangle
                    {
                        x: progressBar.leftPadding + progressBar.visualPosition * (progressBar.availableWidth - width)
                        y: progressBar.topPadding + progressBar.availableHeight / 2 - height / 2
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 13
                        color: bae.babeColor()
                    }
                }

            }


        }


        Item
        {
            id: mainPlaylist
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
                    width: parent.width
                    height: parent.height
                    quickBtnsVisible: false
                    quickPlayVisible: false

                    Rectangle
                    {
                        anchors.fill: parent
                        color: bae.altColor()
                        z: -999
                    }

                    onRowClicked: Player.playTrack(model.get(index))
                    holder.message: "Empty playlist..."
                    Component.onCompleted:
                    {
                        var list = bae.lastPlaylist()
                        var n = list.length

                        if(n>0)
                        {
                            for(var i = 0; i < n; i++)
                            {
                                var where = "url = \""+list[i]+"\""
                                var query = Q.Query.tracksWhere_.arg(where)
                                var track = bae.get(query)
                                Player.appendTrack(track[0])
                            }
                        }else
                        {
                            var where = "babe = 1"
                            var query = Q.Query.tracksWhere_.arg(where)
                            var tracks = bae.get(query)

                            for(var pos=0; pos< tracks.length; pos++)
                                Player.appendTrack(tracks[pos])

                        }

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
}
