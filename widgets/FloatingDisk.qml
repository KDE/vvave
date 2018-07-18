import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Item
{
    height:  miniArtSize * 1.1
    width: height

//    x: contentMargins
//    y: parent.height - (root.footBar.height*0.5)
    parent: ApplicationWindow.overlay
    property bool isHovered : false

    ToolTip.delay: 1000
    ToolTip.timeout: 5000
    ToolTip.visible: isHovered && !isMobile
    ToolTip.text: currentTrack.title + " - " + currentTrack.artist

    DropShadow
    {
        anchors.fill: diskBg
        visible: diskBg.visible
        horizontalOffset: 3
        verticalOffset: 5
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: diskBg
    }

    Rectangle
    {
        id: diskBg
        visible: miniArtwork.visible
        anchors.centerIn: parent
        height: parent.height
        width: height

        color: darkTextColor
        opacity: opacityLevel

        z: -999
        radius: Math.min(width, height)
    }



    RotationAnimator on rotation
    {
        from: 0
        to: 360
        duration: 5000
        loops: Animation.Infinite
        running: miniArtwork.visible && isPlaying
    }

    Image
    {
        id: miniArtwork
        visible: ((!pageStack.wideMode
                   && pageStack.currentIndex !== 0)
                  || !mainPlaylist.cover.visible) && !mainlistEmpty
        focus: true
        height: miniArtSize
        width: miniArtSize
        //                    anchors.left: parent.left
        anchors.centerIn: parent
        source:
        {
            if (currentArtwork)
                (currentArtwork.length > 0 && currentArtwork
                 !== "NONE") ? "file://" + encodeURIComponent(
                                   currentArtwork) : "qrc:/assets/cover.png"
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

    MouseArea
    {
        anchors.fill: parent
        drag.target: parent
        drag.axis: Drag.XAndYAxis
        drag.minimumX: 0
        drag.maximumX: root.width

        drag.minimumY: 0
        drag.maximumY: pageStack.height
        onClicked:
        {
            if (!isMobile && pageStack.wideMode)
                root.width = columnWidth
            pageStack.currentIndex = 0
        }


        hoverEnabled: true
        onEntered: isHovered = true
        onExited: isHovered = false
    }
}
