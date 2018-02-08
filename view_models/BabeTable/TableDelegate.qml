import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "../../view_models"

ItemDelegate
{
    id: delegateRoot

    width: parent.width
    height: sameAlbum ? rowHeightAlt : rowHeight
    clip: true


    signal play()
    signal rightClicked()
    signal leftClicked()

    signal artworkCoverClicked()
    signal artworkCoverDoubleClicked()

    readonly property bool sameAlbum :
    {
        if(coverArt)
        {
            if(listModel.get(index-1))
            {
                if(listModel.get(index-1).album === album) true
                else false
            }else false
        }else false
    }

    property string textColor: ListView.isCurrentItem ? highlightTextColor : foregroundColor
    property bool number : false
    property bool quickPlay : true
    property bool coverArt : false
    property bool menuItem : false
    property bool trackDurationVisible : false
    property bool trackRatingVisible: false
    //    property bool playingIndicator: false
    property string trackMood : art
    property alias trackRating : trackRating

    //    NumberAnimation on x
    //    {
    //        running: ListView.isCurrentItem
    //        from: 0; to: 100
    //    }

    Rectangle
    {
        anchors.fill: parent
        color:
        {
            if(trackMood.length > 0)
                Qt.lighter(trackMood)
            else
                index % 2 === 0 ? midColor : "transparent"
        }
        opacity: 0.3
    }

    MouseArea
    {
        anchors.fill: parent
        acceptedButtons:  Qt.RightButton
        pressAndHoldInterval: 3000
        onClicked:
        {
            if(!root.isMobile && mouse.button === Qt.RightButton)
                rightClicked()
        }
//        onPressAndHold:
//        {
//            pressAndHold(mouse)
//        }
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
            width: sameAlbum ? rowHeight : parent.height

            ToolButton
            {
                visible: !sameAlbum
                height: parent.height
                width: parent.height
                anchors.verticalCenter: parent.verticalCenter

                Image
                {
                    id: artworkCover
                    anchors.fill: parent
                    source:
                    {
                        if(artwork)
                            (artwork.length > 0 && artwork !== "NONE")? "file://"+encodeURIComponent(artwork) : "qrc:/assets/cover.png"
                        else "qrc:/assets/cover.png"
                    }
                    fillMode:  Image.PreserveAspectFit
                    cache: false
                    antialiasing: false
                    smooth: true
                }

                onDoubleClicked: artworkCoverDoubleClicked()
                onClicked: artworkCoverClicked()
                onPressAndHold: if(root.isMobile) artworkCoverDoubleClicked()

            }
        }

        Item
        {
            visible: quickPlay
            Layout.fillHeight: true
            width: sameAlbum ? rowHeight : parent.height

            BabeButton
            {
                id: playBtn
                anchors.centerIn: parent
                iconName: "media-playback-start"
                iconColor: textColor
                onClicked: play()
            }
        }


        Item
        {

            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft
            Layout.margins: contentMargins
            anchors.verticalCenter: parent.verticalCenter

            GridLayout
            {
                anchors.fill: parent
                rows:2
                columns: sameAlbum ? 4 : 3

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

                    text: track + ". "
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
                    //                     Layout.rowSpan: sameAlbum ? 2 : 1
                    Layout.column: 2
                    verticalAlignment:  Qt.AlignVCenter
                    text: title
                    font.bold: !sameAlbum
                    elide: Text.ElideRight
                    font.pointSize: 10
                    color: textColor

                }

                Label
                {
                    id: trackInfo
                    visible: coverArt ? !sameAlbum : true
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

//                Label
//                {
//                    id: trackDuration
//                    visible: trackDurationVisible
//                    Layout.alignment: Qt.AlignRight

//                    Layout.fillWidth: true
//                    Layout.fillHeight: true
//                    Layout.row: 1
//                    Layout.column: 3
//                    horizontalAlignment: Qt.AlignRight
//                    verticalAlignment:  Qt.AlignVCenter
//                    text: player.transformTime(duration)
//                    font.bold: false
//                    elide: Text.ElideRight
//                    font.pointSize: 8
//                    color: textColor
//                }


                Label
                {
                    id: trackBabe

                    font.family: "Material Design Icons"
                    visible: babe == "1"
                    Layout.alignment: Qt.AlignRight

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Layout.row: 1
                    Layout.column: trackDurationVisible && sameAlbum ? 4 : 3
                    horizontalAlignment: Qt.AlignRight
                    verticalAlignment:  Qt.AlignVCenter
                    text: babe == "1" ? "\uf2D1" : ""
                    font.bold: false
                    elide: Text.ElideRight
                    font.pointSize: 8
                    color: textColor

//                    onTextChanged: animBabe.start()

//                    SequentialAnimation
//                    {
//                        id: animBabe
//                        PropertyAnimation
//                        {
//                            target: trackBabe
//                            property: "color"
//                            easing.type: Easing.InOutQuad
//                            to: babeColor
//                            duration: 250
//                        }

//                        PropertyAnimation
//                        {
//                            target: trackBabe
//                            property: "color"
//                            easing.type: Easing.InOutQuad
//                            to: textColor
//                            duration: 500
//                        }
//                    }


                }


                Label
                {
                    font.family: "Material Design Icons"

                    id: trackRating
                    visible: trackRatingVisible
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignRight
                    Layout.row: trackRatingVisible && sameAlbum ? 1 : 2
                    Layout.column: 3
//                    Layout.columnSpan: trackRatingVisible && sameAlbum ? 4 : 3
                    horizontalAlignment: Qt.AlignRight
                    verticalAlignment:  Qt.AlignVCenter
                    text: setStars(stars)
                    font.bold: false
                    elide: Text.ElideRight
                    font.pointSize: 8
                    color: textColor
                }
            }
        }

//        Item
//        {
//            visible: menuItem
//            Layout.fillHeight: true
//            width: sameAlbum ? rowHeight : parent.height

//            BabeButton
//            {
//                id: menuBtn
//                anchors.centerIn: parent
//                iconName: "overflow-menu"
//                iconColor: textColor
//                onClicked: rightClicked()
//            }
//        }
    }

    function setStars(stars)
    {
        switch (stars)
        {
        case "0":
        case 0:
            return  " ";

        case "1":
        case 1:
            return  "\uf4CE";

        case "2":
        case 2:
            return "\uf4CE \uf4CE";

        case "3":
        case 3:
            return  "\uf4CE \uf4CE \uf4CE";

        case "4":
        case 4:
            return  "\uf4CE \uf4CE \uf4CE \uf4CE";

        case "5":
        case 5:
            return "\uf4CE \uf4CE \uf4CE \uf4CE \uf4CE";

        default: return "error";
        }
    }
}
