import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import org.mauikit.controls as Maui

Loader
{
    id: control

    asynchronous: true
    z:  Overlay.overlay.z
    x: parent.width - implicitWidth - 20
    y: parent.height - implicitHeight - 20 - _mainPage.footerContainer.implicitHeight

    visible: opacity > 0

    scale: root.focusView ? 2 : 1
    opacity: root.focusView ? 0 :  1

    property int radius:  root.focusView ? Maui.Style.radiusV : Math.min(width, height)

    Behavior on radius
    {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Behavior on opacity
    {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Behavior on scale
    {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    ScaleAnimator on scale
    {
        from: 0.2
        to: 1
        duration: Maui.Style.units.longDuration
        running: parent.visible
        easing.type: Easing.OutInQuad
    }

    // OpacityAnimator on opacity
    // {
    //     from: 0
    //     to: 1
    //     duration: Maui.Style.units.longDuration
    //     running: status === Loader.Ready
    // }

    sourceComponent: AbstractButton
    {
        id: _floatingViewer

        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: root.title

        Maui.Controls.badgeText: mainPlaylist.listModel.list.count
        implicitHeight: 80 + topPadding + bottomPadding
        implicitWidth: 80 + leftPadding + rightPadding
        hoverEnabled: !Maui.Handy.isMobile

        padding: 4

        scale: hovered || pressed ? 1.2 : 1

        Behavior on scale
        {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        Behavior on implicitHeight
        {
            NumberAnimation
            {
                duration: Maui.Style.units.shortDuration
                easing.type: Easing.InQuad
            }
        }

        onClicked:
        {
            if( mainPlaylist.listModel.list.count > 0)
            {
                toggleFocusView()
                return;
            }
        }

        background: Rectangle
        {
            color: Maui.Theme.backgroundColor

            radius: control.radius
            // property color borderColor: Maui.Theme.textColor
            // border.color: Maui.Style.trueBlack ? Qt.rgba(borderColor.r, borderColor.g, borderColor.b, 0.3) : undefined
            layer.enabled: true
            layer.effect: MultiEffect
            {
                autoPaddingEnabled: true
                shadowEnabled: true
                shadowColor: "#000000"
            }
        }

        Loader
        {
            id: _badgeLoader

            z: _floatingViewer.contentItem.z + 9999
            asynchronous: true

            active: _floatingViewer.Maui.Controls.badgeText && _floatingViewer.Maui.Controls.badgeText.length > 0 && _floatingViewer.visible
            visible: active

            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: 10
            anchors.horizontalCenterOffset: -5

            sourceComponent: Maui.Badge
            {
                text: _floatingViewer.Maui.Controls.badgeText

                padding: 2
                font.pointSize: Maui.Style.fontSizes.tiny

                Maui.Controls.status: Maui.Controls.Negative

                OpacityAnimator on opacity
                {
                    from: 0
                    to: 1
                    duration: Maui.Style.units.longDuration
                    running: parent.visible
                }

                ScaleAnimator on scale
                {
                    from: 0.5
                    to: 1
                    duration: Maui.Style.units.longDuration
                    running: parent.visible
                    easing.type: Easing.OutInQuad
                }
            }
        }

        contentItem: Item
        {
            id: miniArtwork

            Image
        {
            anchors.fill: parent
            source: "image://artwork/album:"+currentTrack.artist + ":"+ currentTrack.album
            // verticalAlignment:  Image.AlignTop
            // fillMode: Image.PreserveAspectFit

            RotationAnimator on rotation
            {
                from: 0
                to: 360
                duration: 7000
                loops: Animation.Infinite
                running: isPlaying && Maui.Style.enableEffects
            }
        }

        Rectangle
        {
            anchors.fill: parent
            color: Maui.Theme.backgroundColor
            opacity: 0.5
            visible: _floatingViewer.hovered
            Maui.Icon
            {
                anchors.centerIn: parent
                source: "quickview"
                height: 48
                width: 48
            }
        }


            layer.enabled: true

            layer.effect: MultiEffect
            {
                maskEnabled: true
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1.0
                maskSpreadAtMax: 0.0
                maskThresholdMax: 1.0
                maskSource: ShaderEffectSource
                {
                    sourceItem: Rectangle
                    {
                        width: miniArtwork.width
                        height: miniArtwork.height
                        radius: control.radius
                    }
                }
            }

        }
    }
}

