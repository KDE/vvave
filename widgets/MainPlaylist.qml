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

    property var currentTrack
    property string currentArtwork
    property bool shuffle : false

    property alias progressBar : progressBar
    property alias cover : cover
    property alias list : list
    property alias playIcon : playIcon
    property alias babeBtnIcon: babeBtnIcon
    property alias infoView : infoView
    signal coverDoubleClicked(var tracks)
    signal coverPressed(var tracks)
    //                    Component.onCompleted:
    //                    {
    //                        if(list.count>0)
    //                            root.width = columnWidth
    //                        else
    //                            root.width = columnWidth*3
    //                    }

    GridLayout
    {
        id: playlistLayout
        width: parent.width
        height: parent.height
        columns: 1
        rows: 4
        rowSpacing: 0

        Rectangle
        {
            id: cover
            Layout.row: 1
            height: columnWidth
            width: parent.width
            Layout.fillWidth: true

            visible: list.count>0

            FastBlur
            {
                anchors.fill: cover
                source: artwork
                radius: 100
            }

            Image
            {
                id: artwork
                width: parent.width < columnWidth ? parent.width : columnWidth
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

        Slider
        {
            id: progressBar
            Layout.fillWidth: true
            Layout.row: 3
            height: 16
            from: 0
            to: 1000
            value: 0
            visible: list.count>0
            spacing: 0

            onMoved: player.seek(player.duration() / 1000 * value);


            Rectangle
            {
                anchors.fill: parent
                color: bae.midColor()
                z: -999
            }

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

        Rectangle
        {
            id: playbackControls
            Layout.fillWidth: true
            Layout.row: 2
            height: 48
            visible: list.count>0
            color: bae.midColor()

            onYChanged:
            {

                if(playbackControls.y<columnWidth/4)
                {
                    cover.visible = false
                    playbackControls.y = 0

                }else
                {
                    cover.visible = true
                    playbackControls.y = columnWidth
                }
            }

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
                onClicked:
                {
                    if(!bae.isMobile())
                        cover.visible = !cover.visible
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
                        Icon
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
                        Icon
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
                        Icon {text: MdiFont.Icon.skipPrevious}
                        onClicked: Player.previousTrack()
                    }

                    ToolButton
                    {
                        id: playBtn
                        Icon {id: playIcon; text: MdiFont.Icon.play }
                        onClicked:
                        {
                            if(player.isPaused()) Player.resumeTrack()
                            else Player.pauseTrack()
                        }
                    }

                    ToolButton
                    {
                        id: nextBtn
                        Icon{text: MdiFont.Icon.skipNext}
                        onClicked: Player.nextTrack()

                    }

                    ToolButton
                    {
                        id: shuffleBtn
                        Icon { text: shuffle ? MdiFont.Icon.shuffle : MdiFont.Icon.shuffleDisabled}

                        onClicked: shuffle = !shuffle
                    }
                }

                Row
                {
                    Layout.alignment: Qt.AlignRight

                    ToolButton
                    {
                        id: menuBtn
                        Icon {text: MdiFont.Icon.dotsVertical}
                        onClicked: playlistMenu.open()
                    }
                }
            }
        }

        Rectangle
        {
            id: mainPlaylist
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.row: 4
            color: "transparent"

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
