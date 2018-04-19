import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3


ItemDelegate
{
    id: babeAlbumRoot

    signal albumClicked(int index)
    signal albumPressed(int index)
    property int albumSize : iconSizes.huge
    property int borderRadius : albumSize*0.05
    property int albumRadius : 0
    property bool albumCard : true
    property string fillColor: backgroundColor
    property bool hide : false

    property color labelColor : GridView.isCurrentItem  || hovered ? highlightColor : textColor
    //    height: typeof album === 'undefined' ? parseInt(albumSize+(albumSize*0.3)) : parseInt(albumSize+(albumSize*0.4))

    visible: !hide
    hoverEnabled: !isMobile
    //    spacing: 0

    background: Rectangle
    {
        color: "transparent"
    }

    DropShadow
    {
        anchors.fill: card
        visible: card.visible
        horizontalOffset: 0
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: card
    }

    Rectangle
    {
        id: card
        visible: albumCard
        width: albumSize
        height:albumSize
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        color: fillColor
        radius: borderRadius
    }


    ColumnLayout
    {
        anchors.fill: parent
        anchors.centerIn: parent

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumHeight: albumSize
            Layout.minimumHeight: albumSize

            Image
            {
                id: img
                width: albumSize
                height: albumSize

                anchors.centerIn: parent

                sourceSize.width: albumSize
                sourceSize.height: albumSize

                fillMode: Image.PreserveAspectFit
                cache: true
//                antialiasing: true

                source:
                {
                    if(artwork)
                        (artwork.length > 0 && artwork !== "NONE")? "file://"+encodeURIComponent(artwork) : "qrc:/assets/cover.png"
                    else "qrc:/assets/cover.png"
                }
                layer.enabled: albumRadius > 0
                layer.effect: OpacityMask
                {
                    maskSource: Item
                    {
                        width: img.width
                        height: img.height
                        Rectangle
                        {
                            anchors.centerIn: parent
                            width: img.adapt ? img.width : Math.min(img.width, img.height)
                            height: img.adapt ? img.height : width
                            radius: albumRadius
                            //                    radius: Math.min(width, height)
                        }
                    }
                }
            }
        }

        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: 0

            ColumnLayout
            {
                anchors.fill: parent
                spacing: space.tiny

                Item
                {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    //            Layout.margins: space.medium

                    Label
                    {
                        width: parent.width * 0.8
                        anchors.centerIn: parent
                        text:  typeof album === 'undefined'  ? artist : album
                        visible: true
                        horizontalAlignment: Qt.AlignHCenter
                        elide: Text.ElideRight
                        font.pointSize: fontSizes.default
                        font.bold: true
                        font.weight: Font.Bold
                        color: labelColor
                    }
                }

                Item
                {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    //            Layout.margins: space.medium


                    Label
                    {
                        width: parent.width*0.8
                        anchors.centerIn: parent

                        text: typeof album === 'undefined' ? "" : artist
                        visible: typeof album === 'undefined'? false : true
                        horizontalAlignment: Qt.AlignHCenter
                        elide: Text.ElideRight
                        font.pointSize: fontSizes.medium
                        color: labelColor
                    }
                }
            }

        }
    }

    MouseArea
    {
        anchors.fill: parent
        onClicked: albumClicked(index)
        onPressAndHold: albumPressed(index)

    }
}



