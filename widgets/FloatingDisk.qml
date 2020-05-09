import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Item
{
    id: control
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    visible: opacity > 0.3 && !mainlistEmpty && !focusView

    height:  Maui.Style.iconSizes.large * (_mouseArea.containsPress ? 1.19 : 1.2)
    width: height

    x: root.footer.x + Maui.Style.space.medium
    y: parent.height - height - Maui.Style.space.medium

    parent: ApplicationWindow.overlay
    z: parent.z + 1
    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: _mouseArea.containsMouse && !Kirigami.Settings.isMobile
    ToolTip.text: currentTrack ? currentTrack.title + " - " + currentTrack.artist : ""

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
        onCountChanged: anim.run(control.y)
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
        onClicked: _drawer.visible ? _drawer.close() : _drawer.open()
        onDoubleClicked: focusView = true

        Rectangle
        {
            id: diskBg
            anchors.centerIn: parent
            height: parent.height
            width: height
            color: "white"
            radius: Math.min(width, height)

            Image
            {
                id: miniArtwork
                focus: true
                anchors.fill: parent
                anchors.margins: Maui.Style.space.tiny
                anchors.centerIn: parent
                source:
                {
                    if (currentArtwork)
                        (currentArtwork.length > 0 && currentArtwork
                         !== "NONE") ? currentArtwork: "qrc:/assets/cover.png"
                    else
                        "qrc:/assets/cover.png"
                }

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
                            anchors.centerIn: parent
                            width: miniArtwork.adapt ? miniArtwork.width : Math.min(
                                                           miniArtwork.width,
                                                           miniArtwork.height)
                            height: miniArtwork.adapt ? miniArtwork.height : width
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
    }
}
