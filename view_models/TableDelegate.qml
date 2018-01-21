import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "../utils/Icons.js" as MdiFont
import "../utils"

ItemDelegate
{
    id: delegate
    signal play()
    signal menuClicked()

    property string textColor: bae.foregroundColor()
    property bool number : false
    property bool quickBtns : false
    property bool quickPlay : true

    property bool trackDurationVisible : false
    property bool trackRatingVisible: false

    property string trackMood : art
    property alias trackRating : trackRating

    checkable: true

    background: Rectangle
    {
        color: Qt.lighter(trackMood, 1.5) || "transparent"
        opacity: 0.4
    }

    MouseArea
    {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked:
        {
            if(!bae.isMobile())
                if (mouse.button === Qt.RightButton)
                {
                    menuClicked()

                }
        }
    }

    contentItem: GridLayout
    {
        id: gridLayout
        width: parent.width

        rows:2
        columns:4

        ToolButton
        {
            id: playBtn
            Layout.fillHeight: true
            Layout.row: 1
            Layout.column: 1
            Layout.rowSpan: 2
            visible: quickPlay
            BabeIcon { text: MdiFont.Icon.playCircle }
            onClicked: delegate.play()
        }

        Label
        {
            id: trackNumber
            visible: number
            width: 16
            Layout.fillHeight: true
            Layout.row: 1
            Layout.column: 2
            Layout.rowSpan: 2

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
            Layout.column: 3
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
            Layout.column: 3
            verticalAlignment:  Qt.AlignVCenter
            text: artist + " | " + album
            font.bold: false
            elide: Text.ElideRight
            font.pointSize: 9
            color: textColor

        }

        Label
        {
            id: trackDuration
            visible: trackDurationVisible
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.row: 1
            Layout.column: 4
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
            Layout.column: 4
            horizontalAlignment: Qt.AlignRight
            verticalAlignment:  Qt.AlignVCenter
            text: stars
            font.bold: false
            elide: Text.ElideRight
            font.pointSize: 8
            color: textColor
        }

        Row
        {
            Layout.column: 5
            Layout.row: 1
            Layout.rowSpan: 2
            Layout.alignment: Qt.AlignRight
            visible: quickBtns || menuBtn.visible

            ToolButton
            {
                id: menuBtn
                visible: bae.isMobile()
                BabeIcon { text: MdiFont.Icon.dotsVertical }
                onClicked: menuClicked()
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
