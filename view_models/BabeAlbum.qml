import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Item
{
    signal albumClicked(int index)
    property int albumSize : 150
    property int borderRadius : 2
    property string fillColor: bae.midColor()
    property string textColor: bae.foregroundColor()
    property int fontSize : bae.isMobile()? 12 : 10
    id: root

    width: albumSize
    height: typeof album === 'undefined' ? parseInt(albumSize+(albumSize*0.3)) : parseInt(albumSize+(albumSize*0.4))

    DropShadow
    {
        anchors.fill: card
        horizontalOffset: 3
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: card
    }


    Rectangle
    {
        id: card
        anchors.fill: parent
        color: fillColor
        radius: borderRadius
    }

    ColumnLayout
    {
        Row
        {
            Layout.fillWidth: true

            Image
            {
                id: img
                width: albumSize
                height: albumSize

                fillMode: Image.PreserveAspectFit

                source: (artwork.length>0 && artwork !== "none")? "file://"+encodeURIComponent(artwork) : "qrc:/assets/cover.png"
                //                layer.enabled: true
                //                layer.effect: OpacityMask
                //                {
                //                    maskSource: Item
                //                    {
                //                        width: img.width
                //                        height: img.height
                //                        Rectangle
                //                        {
                //                            anchors.centerIn: parent
                //                            width: img.adapt ? img.width : Math.min(img.width, img.height)
                //                            height: img.adapt ? img.height : width
                //                            radius: borderRadius
                //                            //                    radius: Math.min(width, height)
                //                        }
                //                    }
                //                }
            }
        }


        Row
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 5
            Layout.topMargin: 5

            Label
            {
                width: parent.width
                text:  typeof album === 'undefined'  ? artist : album
                visible: true
                elide: Text.ElideRight
                font.pointSize: fontSize
                font.bold: true
                color: textColor
                lineHeight: 0.7
            }

        }

        Row
        {
            spacing: 0

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 5

            Label
            {
                width: parent.width
                text: typeof album === 'undefined' ? "" : artist
                visible: typeof album === 'undefined'? false : true
                horizontalAlignment : typeof album === 'undefined'? Qt.AlignHCenter : Qt.AlignLeft
                elide: Text.ElideRight
                font.pointSize: fontSize-1
                color: textColor

            }
        }
    }

    MouseArea
    {
        anchors.fill: parent
        onClicked:
        {
            parent.GridView.view.currentIndex = index
            albumClicked(index)
        }

    }
}
