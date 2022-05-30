import QtQuick 2.10
import QtQuick.Controls 2.10

import QtGraphicalEffects 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.0 as Maui

Item
{
    id: control

    parent: ApplicationWindow.overlay
    z: parent.z + 1

    Maui.Theme.inherit: false
    Maui.Theme.colorSet: Maui.Theme.Complementary

    visible: opacity > 0.3 && _viewsPage.visible

    implicitHeight: Maui.Style.iconSizes.large * (_mouseArea.containsPress ? 1.19 : 1.2)
    implicitWidth: implicitHeight

    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: _mouseArea.containsMouse && !Kirigami.Settings.isMobile
    ToolTip.text: root.title

    Component.onCompleted:
    {
        control.x= root.width - control.implicitWidth - Maui.Style.space.medium
        control.y= root.height - control.implicitHeight - Maui.Style.space.medium - root.page.footerContainer.implicitHeight
    }

    Maui.Badge
    {
        anchors.fill: parent
        anchors.margins: Maui.Style.space.tiny
        visible: anim.running
        text: mainPlaylist.table.count
    }

    Connections
    {
        target: mainPlaylist.table
        ignoreUnknownSignals: true
        function onCountChanged()
        {
             anim.run(control.y)
        }
    }

    NumberAnimation on y
    {
        id: anim
        property int startY
        running: false
        from : control.y
        to: control.y - 20
        duration: 250
        loops: 2

        onStopped:
        {
            control.y = startY
        }

        function run(y)
        {
            if(y < 10)
                return
            startY = y
            anim.start()
            anim.running = true
        }
    }

    Rectangle
    {
        id: diskBg
        anchors.fill: parent
        color: "white"
        radius: Math.min(width, height)

        Image
        {
            id: miniArtwork
            focus: true
            anchors.fill: parent
            anchors.margins: Maui.Style.space.tiny
            anchors.centerIn: parent
            source: "image://artwork/album:"+currentTrack.artist + ":"+ currentTrack.album
            fillMode: Image.PreserveAspectFit
            cache: false
            antialiasing: true

            layer.enabled: true
            layer.effect: OpacityMask
            {
                maskSource: Item
                {
                    width: miniArtwork.width
                    height: miniArtwork.height
                    Rectangle
                    {
                        anchors.fill: parent
                        radius: Math.min(width, height)
                    }
                }
            }
        }
    }

    DropShadow
    {
        anchors.fill: diskBg
        horizontalOffset: 0
        verticalOffset: 0
        radius: _mouseArea.containsPress ? 5.0 :8.0
        samples: 17
        color: "#80000000"
        source: diskBg
    }

    RotationAnimator on rotation
    {
        from: 0
        to: 360
        duration: 5000
        loops: Animation.Infinite
        running: isPlaying
    }


    MouseArea
    {
        id: _mouseArea
        anchors.fill: parent
        hoverEnabled: true

        drag.target: parent
        drag.axis: Drag.XAndYAxis

        drag.minimumX: 0
        drag.maximumX: root.width - control.width

        drag.minimumY: 0
        drag.maximumY: root.height - control.height

        onClicked: toggleFocusView()
        onPressAndHold: toggleMiniMode()
  }
}
