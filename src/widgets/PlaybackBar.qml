import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui

import "../utils/Player.js" as Player

Maui.ToolBar
{
    position: ToolBar.Footer

    farLeftContent: ToolButton
    {
        icon.name: _sideBarView.sideBar.visible ? "sidebar-collapse" : "sidebar-expand"
        onClicked: _sideBarView.sideBar.toggle()
        visible: _sideBarView.sideBar.collapsed
        checked:  _sideBarView.sideBar.visible
        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: i18n("Toogle SideBar")
    }

    rightContent: ToolButton
    {
        visible: focusView
        icon.name: root.focusView ? "go-down" : "go-up"
        onClicked: toggleFocusView()
    }

    middleContent: [

        Maui.ToolActions
        {
            Layout.alignment: Qt.AlignCenter

            display: ToolButton.IconOnly
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

