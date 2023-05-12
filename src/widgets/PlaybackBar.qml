import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import QtMultimedia 5.0
import QtGraphicalEffects 1.0
import org.mauikit.controls 1.3 as Maui

import org.maui.vvave 1.0 as Vvave

import "../utils/Player.js" as Player
import QtQuick.Templates 2.15 as T

Maui.ToolBar
{
    position: ToolBar.Footer

    farLeftContent: ToolButton
    {
        icon.name: _sideBarView.sideBar.visible ? "sidebar-collapse" : "sidebar-expand"
        onClicked:  _sideBarView.sideBar.toggle()
        visible: _sideBarView.sideBar.collapsed
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

