import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "../../view_models"
import "../../utils/Help.js" as H

SwipeDelegate
{
    id: delegateRoot

    readonly property int altHeight : rowHeight * 1.4
    readonly property bool sameAlbum :
    {
        if(coverArt)
        {
            if(list.get(index-1))
            {
                if(list.get(index-1).album === album && list.get(index-1).artist === artist) true
                else false
            }else false
        }else false
    }

    property bool isCurrentListItem :  ListView.isCurrentItem
    property color bgColor : backgroundColor
    property string labelColor: isCurrentListItem ? highlightedTextColor : textColor
    property bool number : false
    property bool quickPlay : true
    property bool coverArt : false
    property bool menuItem : false
    property bool trackDurationVisible : false
    property bool trackRatingVisible: false
    property bool playingIndicator: false
    property string trackMood : model.color

    property bool remoteArtwork: false

    width: parent.width
    height: sameAlbum ? rowHeight : altHeight
    padding: 0
    clip: true
    autoExclusive: true
    swipe.enabled: false
    focus: true
    focusPolicy: Qt.StrongFocus
    hoverEnabled: true

    signal play()
    signal rightClicked()
    signal leftClicked()

    signal artworkCoverClicked()
    signal artworkCoverDoubleClicked()


    background: Rectangle
    {
        height: delegateRoot.height
        color: isCurrentListItem ? highlightColor : (trackMood.length > 0 ? Qt.tint(bgColor, Qt.rgba(Qt.lighter(trackMood, 1.3).r,
                                                                                                     Qt.lighter(trackMood, 1.3).g,
                                                                                                     Qt.lighter(trackMood, 1.3).b,
                                                                                                     0.3 ) ):
                                                                            index % 2 === 0 ? Qt.lighter(bgColor) : bgColor)

    }

    swipe.right: Row
    {
        padding: space.medium
        height: delegateRoot.height
        anchors.right: parent.right
        spacing: space.medium

        Maui.ToolButton
        {
            iconName: "documentinfo"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: swipe.close()
        }

        Maui.ToolButton
        {
            iconName: "love"
            anchors.verticalCenter: parent.verticalCenter

            iconColor: model.fav === "1" ? babeColor : textColor
            onClicked:
            {
                model.fav = model.fav === "1" ? "0" : "1"
                bae.babeTrack(url, model.fav)
                swipe.close()
            }
        }

        Maui.ToolButton
        {
            iconName: "view-media-recent"
            anchors.verticalCenter: parent.verticalCenter

            onClicked:
            {
                swipe.close()
                queueTrack(index)
            }
        }

        Maui.ToolButton
        {
            iconName: "media-playback-start"
            anchors.verticalCenter: parent.verticalCenter

            onClicked:
            {
                swipe.close()
                play()
            }
        }
    }

    contentItem: Item
    {
        height: delegateRoot.height
        width: delegateRoot.width

        MouseArea
        {
            anchors.fill: parent
            acceptedButtons:  Qt.RightButton
            pressAndHoldInterval: 3000
            onClicked: if(!isMobile && mouse.button === Qt.RightButton)
                           rightClicked()

        }

        RowLayout
        {
            id: gridLayout
            anchors.fill: parent
            spacing: 0

            Item
            {
                visible: coverArt
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                width: altHeight
                height: parent.height

                ToolButton
                {
                    visible: !sameAlbum
                    anchors.fill: parent
                    flat: true

                    Image
                    {
                        id: artworkCover
                        anchors.centerIn: parent
                        height: parent.height * 0.8
                        width: height

                        sourceSize.width: parent.width
                        sourceSize.height: parent.height

                        source: typeof model.artwork === 'undefined' ?
                                    "qrc:/assets/cover.png" :
                                    remoteArtwork ? model.artwork :
                                                    ((model.artwork && model.artwork.length > 0 && model.artwork !== "NONE")? "file://"+encodeURIComponent(model.artwork) : "qrc:/assets/cover.png")


                        fillMode:  Image.PreserveAspectFit
                        cache: true
                        asynchronous: true
                        //                    antialiasing: true
                        //                    smooth: true

                        layer.enabled: coverArt
                        layer.effect: OpacityMask
                        {
                            maskSource: Item
                            {
                                width: artworkCover.width
                                height: artworkCover.height
                                Rectangle
                                {
                                    anchors.centerIn: parent
                                    width: artworkCover.adapt ? artworkCover.width : Math.min(artworkCover.width, artworkCover.height)
                                    height: artworkCover.adapt ? artworkCover.height : width
                                    radius: Kirigami.Units.devicePixelRatio *3
                                    border.color: altColor
                                    border.width: Kirigami.Units.devicePixelRatio *3
                                }
                            }
                        }
                    }

                    onDoubleClicked: artworkCoverDoubleClicked()
                    onClicked: artworkCoverClicked()
                    onPressAndHold: if(isMobile) artworkCoverDoubleClicked()
                }

                Item
                {
                    visible : playingIndicator && (currentTrackIndex === index) && isPlaying

                    height: parent.height * 0.5
                    width: height
                    anchors.centerIn: parent

                    AnimatedImage
                    {
                        source: "qrc:/assets/bars.gif"
                        anchors.centerIn: parent
                        height: parent.height
                        width: parent.width
                        playing: parent.visible
                    }
                }
            }

            Item
            {
                visible: quickPlay
                Layout.fillHeight: true
                width:  iconSize * 1.5
                height: parent.height
                Layout.leftMargin: space.small

                Maui.ToolButton
                {
                    id: playBtn
                    anchors.centerIn: parent
                    iconName: "media-playback-start"
                    iconColor: labelColor
                    size: iconSizes.medium
                    onClicked: play()
                    anim: true
                }
            }

            Item
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.margins: space.tiny
                Layout.leftMargin: space.small * (quickPlay ? 1 : 2)
                Layout.rightMargin: space.big

                GridLayout
                {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    rows: 2
                    columns: 4
                    rowSpacing: space.tiny

                    Label
                    {
                        id: trackNumber
                        visible: number
                        width: 16
                        Layout.fillHeight: true
                        Layout.row: 1
                        Layout.column: 1

                        Layout.alignment: Qt.AlignCenter
                        verticalAlignment:  Qt.AlignVCenter

                        text: model.track + ". "
                        font.bold: true
                        elide: Text.ElideRight

                        font.pointSize: fontSizes.default
                        color: labelColor
                    }

                    Label
                    {
                        id: trackTitle
                        //                        Layout.maximumWidth: gridLayout.width *0.5
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.row: 1
                        Layout.column: 2
                        Layout.alignment: Qt.AlignLeft || Qt.AlignBottom
                        verticalAlignment:  Qt.AlignVCenter
                        text: model.title
                        font.bold: !sameAlbum
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                        font.pointSize: fontSizes.default
                        color: labelColor

                    }

                    Label
                    {
                        id: trackInfo
                        visible: coverArt ? !sameAlbum : true
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignLeft || Qt.AlignTop
                        Layout.row: 2
                        Layout.column: 2
                        verticalAlignment:  Qt.AlignVCenter
                        text: model.artist + " | " + model.album
                        font.bold: false
                        elide: Text.ElideRight
                        font.pointSize: fontSizes.medium
                        color: labelColor

                    }

                    Label
                    {
                        id: trackBabe

                        font.family: "Material Design Icons"
                        visible: model.fav == "1"
                        Layout.alignment: Qt.AlignRight

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Layout.row: 1
                        Layout.column: /*trackDurationVisible &&*/ sameAlbum ? 4 : 3
                        horizontalAlignment: Qt.AlignRight
                        verticalAlignment:  Qt.AlignVCenter
                        text: model.fav ? (model.fav == "1" ? "\uf2D1" : "") : ""
                        font.bold: false
                        elide: Text.ElideRight
                        font.pointSize: fontSizes.small
                        color: labelColor
                    }


                    Label
                    {
                        font.family: "Material Design Icons"

                        id: trackRating
                        visible: trackRatingVisible
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignRight
                        Layout.row: /*trackRatingVisible && */sameAlbum ? 1 : 2
                        Layout.column: 3
                        //                    Layout.columnSpan: trackRatingVisible && sameAlbum ? 4 : 3
                        horizontalAlignment: Qt.AlignRight
                        verticalAlignment:  Qt.AlignVCenter
                        text: model.rate ? H.setStars(model.rate) : ""
                        font.bold: false
                        elide: Text.ElideRight
                        font.pointSize: fontSizes.small
                        color: labelColor
                    }
                }
            }

            Item
            {
                visible: menuItem
                Layout.fillHeight: true
//                Layout.fillWidth: true
                width: space.enormous

                MouseArea
                {
                    id: handle
                    property var downTimestamp;
                    property int startX
                    property int startMouseX
                    z: delegateRoot.z +1

                    anchors.fill: parent
                    preventStealing: true
                    onPressed:
                    {
                        startX = delegateRoot.background.x;
                        startMouseX = mouse.x;
                    }

                    onPositionChanged: swipe.position = Math.min(0, Math.max(-delegateRoot.width + height, delegateRoot.background.x - (startMouseX - mouse.x)));

                    Maui.ToolButton
                    {
                        id: menuBtn
                        visible: true
                        anchors.centerIn: parent
                        iconName: "overflow-menu"
                        iconColor:  labelColor
                        onClicked: swipe.position < 0 ? swipe.close() : swipe.open(SwipeDelegate.Right)
                    }

                }
            }
        }
    }

    function rate(stars)
    {
        trackRating.text = stars
    }
}
