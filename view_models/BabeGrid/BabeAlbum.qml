import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3


ColumnLayout
{
    id: babeAlbumRoot


    signal albumClicked(int index)
    signal albumPressed(int index)
    property int albumSize : 150
    property int borderRadius : 2
    property int albumRadius : 0
    property bool albumCard : true
    property string fillColor: backgroundColor
    property string labelColor: textColor
    property bool hide : false

    //    height: typeof album === 'undefined' ? parseInt(albumSize+(albumSize*0.3)) : parseInt(albumSize+(albumSize*0.4))

    visible: !hide
    spacing: 0

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
        anchors.fill: parent
        color: fillColor
        radius: borderRadius
    }

    Item
    {
        height: albumSize
        width: albumSize

        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter

        Image
        {
            id: img
            width: albumSize
            height: albumSize

            sourceSize.width: albumSize
            sourceSize.height: albumSize

            fillMode: Image.PreserveAspectFit
            cache: true
            antialiasing: true

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

    Column
    {
        id: albumInfoRow
        Layout.maximumHeight: rowHeight
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: contentMargins
        spacing: 5

        Label
        {
            width: parent.width
            text:  typeof album === 'undefined'  ? artist : album
            visible: true
            horizontalAlignment: Qt.AlignHCenter
            elide: Text.ElideRight
            font.pointSize: fontSizes.medium
            font.bold: true
            color: labelColor
        }

        Label
        {
            width: parent.width
            text: typeof album === 'undefined' ? "" : artist
            visible: typeof album === 'undefined'? false : true
            horizontalAlignment: Qt.AlignHCenter
            elide: Text.ElideRight
            font.pointSize: fontSizes.small
            color: labelColor
        }
    }

    MouseArea
    {
        anchors.fill: parent
        onClicked: albumClicked(index)

        onPressAndHold: albumPressed(index)

    }
}



