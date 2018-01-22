import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "../utils/Icons.js" as MdiFont
import "../utils"

ItemDelegate
{
    id: delegate

    width: parent.width
    height: 64

    signal play()
    signal rightClicked()

    property string textColor: bae.foregroundColor()
    property bool number : false
    property bool quickPlay : true
    property bool coverArt : false

    property bool trackDurationVisible : false
    property bool trackRatingVisible: false
    //    property bool playingIndicator: false
    property string trackMood : art
    property alias trackRating : trackRating

    checkable: true

    background: Rectangle
    {
        color:
        {
            if(trackMood.length>0)
                Qt.lighter(trackMood)
            else
                index % 2 === 0 ? bae.midColor() : "transparent"
        }

        opacity: 0.3
    }
    MouseArea
    {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked:
        {
            if(!bae.isMobile() && mouse.button === Qt.RightButton)
                rightClicked()
        }
    }

    contentItem: RowLayout
    {
        id: gridLayout
        height: delegate.height
        width: delegate.width
        spacing: 20

        Item
        {
            visible: coverArt
            Layout.fillHeight: true
            //            Layout.fillWidth: true
            //            height: parent.height
            width: parent.height
            ToolButton
            {
                height: delegate.height
                width: delegate.height
                anchors.verticalCenter: parent.verticalCenter

                Image
                {
                    id: artworkCover
                    anchors.fill: parent
                    source: (artwork.length>0 && artwork !== "none" && artwork)? "file://"+encodeURIComponent(artwork) : "qrc:/assets/cover.png"
                    fillMode: Image.PreserveAspectFit
                    cache: false
                    antialiasing: true
                }

            }
        }

        Item
        {
            visible: quickPlay
            Layout.fillHeight: true
            //            Layout.fillWidth: true
            //            height: parent.height
            width: parent.height
            ToolButton
            {
                id: playBtn
                anchors.centerIn: parent

                BabeIcon { text: MdiFont.Icon.playCircle }
                onClicked: delegate.play()
            }
        }


        Item
        {
            height: delegate.height

            Layout.fillHeight: true
            Layout.fillWidth: true

            Layout.alignment: Qt.AlignVCenter

            GridLayout
            {
                anchors.fill: parent
                rows:2
                columns:3

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

                    text: track
                    font.bold: true
                    elide: Text.ElideRight

                    font.pointSize: 10
                    color: textColor
                }


                Label
                {
                    id: trackTitle

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.row: 1
                    Layout.column: 2
                    verticalAlignment:  Qt.AlignVCenter
                    text: title
                    font.bold: true
                    elide: Text.ElideRight

                    font.pointSize: 10
                    color: textColor

                }

                Label
                {
                    id: trackInfo

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.row: 2
                    Layout.column: 2
                    verticalAlignment:  Qt.AlignVCenter
                    text: artist + " | " + album
                    font.bold: false
                    elide: Text.ElideRight
                    font.pointSize: 9
                    color: textColor

                }


                //        Item
                //        {
                //            Layout.row: 1
                //            Layout.rowSpan: 2
                //            Layout.column: 4
                //            height: 48
                //            width: height
                //            Layout.fillWidth: true
                //            Layout.fillHeight: true
                //            Layout.alignment: Qt.AlignCenter

                //            AnimatedImage
                //            {
                //                id: animation
                //                cache: true
                //                visible: playingIndicator
                //                height: 22
                //                width: 22
                //                horizontalAlignment: Qt.AlignLeft
                //                verticalAlignment:  Qt.AlignVCenter
                //                source: "qrc:/assets/bars.gif"
                //            }
                //        }

                Label
                {
                    id: trackDuration
                    visible: trackDurationVisible
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.row: 1
                    Layout.column: 3
                    horizontalAlignment: Qt.AlignRight
                    verticalAlignment:  Qt.AlignVCenter
                    text: player.transformTime(duration)
                    font.bold: false
                    elide: Text.ElideRight
                    font.pointSize: 8
                    color: textColor
                }

                Label
                {
                    id: trackRating
                    visible: trackRatingVisible
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.row: 2
                    Layout.column: 3
                    horizontalAlignment: Qt.AlignRight
                    verticalAlignment:  Qt.AlignVCenter
                    text: stars
                    font.bold: false
                    elide: Text.ElideRight
                    font.pointSize: 8
                    color: textColor
                }
            }
        }
    }

    function setStars(stars)
    {

        switch (parseInt(stars))
        {
        case 0:
            return  " ";

        case 1:
            return  "\xe2\x98\x86 ";

        case 2:
            return "\xe2\x98\x86 \xe2\x98\x86 ";

        case 3:
            return  "\xe2\x98\x86 \xe2\x98\x86 \xe2\x98\x86 ";

        case 4:
            return  "\xe2\x98\x86 \xe2\x98\x86 \xe2\x98\x86 \xe2\x98\x86 ";

        case 5:
            return "\xe2\x98\x86 \xe2\x98\x86 \xe2\x98\x86 \xe2\x98\x86 \xe2\x98\x86 ";

        default: return "error";
        }
    }
}
