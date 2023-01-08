import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15

import QtGraphicalEffects 1.0

import org.mauikit.controls 1.3 as Maui

Control
{
    id: control

    parent: ApplicationWindow.overlay
    z: parent.z + 1

    Maui.Theme.inherit: false
    Maui.Theme.colorSet: Maui.Theme.Complementary

    visible: opacity > 0

    scale: focusView ? 2 : 1

    implicitHeight: _mouseArea.implicitHeight + topPadding + bottomPadding
    implicitWidth: _mouseArea.implicitWidth + leftPadding + rightPadding

    padding: Maui.Style.space.tiny

    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: _mouseArea.containsMouse && !Maui.Handy.isMobile
    ToolTip.text: root.title

    opacity: root.focusView ? 0 :  1

    Behavior on opacity
    {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Behavior on scale
    {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    y: root.height - control.implicitHeight - Maui.Style.space.medium - _mainPage.footerContainer.implicitHeight
    x: root.width - control.implicitWidth - Maui.Style.space.medium

//    Binding on x
//    {
//        when: !_mouseArea.pressed
//        value: control.x
//        restoreMode: Binding.RestoreBindingOrValue
//        delayed: true
//    }

//    Binding on y
//    {
//        when: !_mouseArea.pressed
//        value: control.y
//        restoreMode: Binding.RestoreBindingOrValue
//        delayed: true
//    }

    background: Rectangle
    {
        id: diskBg
        color: "white"
        radius: Math.min(width, height)

        layer.enabled: true
        layer.effect: DropShadow
        {
            horizontalOffset: 0
            verticalOffset: 0
            radius: _mouseArea.containsPress ? 5.0 :8.0
            samples: 17
            color: "#80000000"
        }
    }

    contentItem: MouseArea
    {
        id: _mouseArea

        implicitHeight: Maui.Style.iconSizes.large * (_mouseArea.containsPress ? 1.19 : 1.2)
         implicitWidth: implicitHeight

        hoverEnabled: true

        drag.target: control
        drag.axis: Drag.XAndYAxis

        drag.minimumX: 0
        drag.maximumX: root.width - control.width

        drag.minimumY: 0
        drag.maximumY: root.height - control.height

        onClicked: toggleFocusView()
//        onPressAndHold: toggleMiniMode()

        Image
        {
            id: miniArtwork
            focus: true
            anchors.fill: parent
            source: "image://artwork/album:"+currentTrack.artist + ":"+ currentTrack.album
            fillMode: Image.PreserveAspectFit

            layer.enabled: true
            layer.effect: OpacityMask
            {
                maskSource: Rectangle
                {
                    height: miniArtwork.height
                    width: miniArtwork.width
                    radius: Math.min(width, height)
                }
            }
        }
    }

    RotationAnimator on rotation
    {
        from: 0
        to: 360
        duration: 5000
        loops: Animation.Infinite
        running: isPlaying && Maui.Style.enableEffects
    }
}
