import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import QtMultimedia 5.0
import QtGraphicalEffects 1.0


import org.mauikit.controls 1.3 as Maui

import org.maui.vvave 1.0 as Vvave

import "../utils/Player.js" as Player
import QtQuick.Templates 2.15 as T

T.Control
{
    id: control
    implicitHeight: visible ? implicitContentHeight : 0

    background: Rectangle
    {
        color: Maui.Theme.backgroundColor
        opacity: root.focusView ? 0 : 1

        Loader
        {
            anchors.fill: parent
            active: Maui.Style.enableEffects && !root.focusView
            sourceComponent: Item
            {
                Image
                {
                    id: artworkBg
                    height: parent.height
                    width: parent.width

                    sourceSize.width: 500
                    sourceSize.height: height

                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    source: "image://artwork/album:"+currentTrack.artist + ":"+ currentTrack.album
                }

                FastBlur
                {
                    anchors.fill: parent
                    source: artworkBg
                    radius: 64
                    transparentBorder: false
                    cached: true


                }

                Rectangle
                {
                    anchors.fill: parent
                    color: Maui.Theme.backgroundColor
                    opacity: 0.8
                    Behavior on color
                    {
                        Maui.ColorTransition{}
                    }
                }
            }
        }

        Maui.Separator
        {
            height: 0.5
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            Behavior on color
            {
                Maui.ColorTransition{}
            }
        }
    }

    contentItem: Maui.ToolBar
    {
        id: _footerLayout
        position: ToolBar.Footer

        background: Slider
        {
            id: progressBar
            visible: !focusView
            height: visible ? 16 : 0
            z: parent.z+1
            padding: 0
            from: 0
            to: 1000
            value: player.pos/player.duration*1000

            spacing: 0
            focus: true
            onMoved: player.pos = (player.duration / 1000) * value
            enabled: player.playing

            background: Rectangle
            {
                implicitWidth: progressBar.width
                implicitHeight: progressBar.height
                width: progressBar.availableWidth
                color: "transparent"
                opacity: progressBar.pressed ? 0.5 : 1
                Behavior on color
                {
                    Maui.ColorTransition{}
                }

                Rectangle
                {
                    width: progressBar.visualPosition * parent.width
                    height: progressBar.pressed ? 5 :  2
                    color: Maui.Theme.highlightColor
                    Behavior on color
                    {
                        Maui.ColorTransition{}
                    }

                }
            }

            handle: Rectangle
            {
                x: progressBar.leftPadding + progressBar.visualPosition
                   * (progressBar.availableWidth - width)
                y: 0
                radius: height
                implicitWidth: Maui.Style.iconSizes.medium
                implicitHeight: 16
                color: progressBar.pressed ? Qt.lighter(Maui.Theme.highlightColor, 1.2) : "transparent"
                Behavior on color
                {
                    Maui.ColorTransition{}
                }

            }
        }

        farLeftContent: ToolButton
        {
            icon.name: _sideBarView.sideBar.visible ? "sidebar-collapse" : "sidebar-expand"
            onClicked:  _sideBarView.sideBar.toggle()

            checked:  _sideBarView.sideBar.visible
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered
            ToolTip.text: i18n("Toogle SideBar")
        }

        rightContent: ToolButton
        {
            icon.name: root.focusView ? "go-down" : "go-up"
            onClicked: toggleFocusView()
        }


        //            ToolButton
        //        {
        //            icon.name: _volumeSlider.value === 0 ? "player-volume-muted" : "player-volume"
        //            onPressAndHold :
        //            {
        //                player.volume = player.volume === 0 ? 100 : 0
        //            }

        //            onClicked:
        //            {
        //                _sliderPopup.visible ? _sliderPopup.close() : _sliderPopup.open()
        //            }

        //            Popup
        //            {
        //                id: _sliderPopup
        //                height: 150
        //                width: parent.width
        //                y: -150
        //                x: 0

        //                Slider
        //                {
        //                    id: _volumeSlider
        //                    visible: true
        //                    height: parent.height
        //                    width: 20
        //                    anchors.horizontalCenter: parent.horizontalCenter
        //                    from: 0
        //                    to: 100
        //                    value: player.volume
        //                    orientation: Qt.Vertical

        //                    onMoved:
        //                    {
        //                        player.volume = value
        //                    }
        //                }
        //            }
        //        }

        middleContent: [

            Maui.ToolActions
            {
                Layout.alignment: Qt.AlignCenter

                //                implicitHeight: Maui.Style.iconSizes.big
                expanded: true
                autoExclusive: false
                checkable: false

                Action
                {
                    icon.name: "media-skip-backward"
                    onTriggered: Player.previousTrack()
                }

                Action
                {
                    id: playIcon
                    text: i18n("Play and pause")
                    //                    icon.width: Maui.Style.iconSizes.big
                    //                    icon.height: Maui.Style.iconSizes.big
                    enabled: currentTrackIndex >= 0
                    icon.name: isPlaying ? "media-playback-pause" : "media-playback-start"
                    onTriggered: player.playing ? player.pause() : player.play()
                }

                Action
                {
                    text: i18n("Next")
                    icon.name: "media-skip-forward"
                    onTriggered: Player.nextTrack()
                }
            }
        ]
    }
}
