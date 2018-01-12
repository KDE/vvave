import QtQuick 2.9
import QtQuick.Controls 2.2
import QtLocation 5.9
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import "../utils/Icons.js" as MdiFont
import "../utils/Player.js" as Player
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
            }
        }

        Slider
        {
            id: progressBar
            Layout.fillWidth: true
            Layout.fillHeight: true

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
                color: util.midColor()
                z: -999
            }
        }

        Rectangle
        {
            id: playbackControls
            Layout.fillWidth: true
            Layout.row: 2
            height: 48
            visible: list.count>0
            color: util.midColor()

            onYChanged:
            {
                if(playbackControls.y<columnWidth/4)
                {
                    cover.visible= false
                    playbackControls.y = 0
                }else
                {
                    cover.visible= true
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
                    if(Qt.platform.os === "linux")
                        cover.visible = !cover.visible
                }
            }

            RowLayout
            {
                width: parent.width
                height: parent.height
                anchors.fill: parent
                ToolButton
                {
                    id: menuBtn
                    Icon {text: MdiFont.Icon.dotsVertical}
                    onClicked: playlistMenu.open()
                }
                Row
                {
                    anchors.centerIn: parent
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
            }
        }

        Rectangle
        {
            id: mainPlaylist
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.row: 4
            color: "transparent"
            BabeTable
            {
                id: list
                width: parent.width
                height: parent.height
                quickBtnsVisible: false
                onRowClicked: Player.playTrack(model.get(index))
                holder.message: "Empty playlist..."
                Component.onCompleted:
                {
                    var list = util.lastPlaylist()
                    var n = list.length
                    for(var i = 0; i < n; i++)
                    {
                        var track = con.get("select * from tracks where url = \""+list[i]+"\"")
                        Player.appendTrack(track[0])
                    }

                    //                                    var pos = util.lastPlaylistPos()
                    //                                    console.log("POSSS:", pos)
                    //                                    list.currentIndex = pos
                    //                                    play(list.model.get(pos))
                }
            }
        }
    }
}
