import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../utils/Icons.js" as MdiFont
import "../utils/Help.js" as H
import "../utils"

Menu
{
    id: rootMenu
    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2
    modal: true

    property int rate : 0
    property string starColor : "#FFC107"
    property string starReg : "gray"
    property string starIcon: MdiFont.Icon.star
    property int starSize : 22

    signal rated(int value)

    function rateIt(rank)
    {
        rate = rank
        bae.rateTrack(list.model.get(currentRow).url, rate)
    }


    Label
    {
        padding: 10
        font.bold: true
        width: parent.width
        horizontalAlignment: Qt.AlignHCenter
        elide: Text.ElideRight
        text: currentRow >= 0 ? list.model.get(currentRow).title : ""
    }
    MenuItem
    {
        text: qsTr("Babe it")
        onTriggered: ;
    }
    MenuItem
    {
        text: qsTr("Queue")
        onTriggered:
        {
            console.log(currentRow)
            list.queueTrack(currentRow)
        }
    }
    MenuItem
    {
        text: qsTr("Edit...")
        onTriggered: ;
    }
    MenuItem
    {
        text: qsTr("Remove")
        onTriggered: ;
    }
    MenuItem
    {
        text: qsTr("Edit...")
        onTriggered: ;
    }
    MenuItem
    {
        text: qsTr("Remove")
        onTriggered: ;
    }

    MenuItem
    {
        RowLayout
        {
           anchors.fill: parent
            ToolButton
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                Icon
                {
                    text: starIcon
                    color: rate >= 1 ? starColor :starReg
                    iconSize: starSize
                }

                onClicked: rateIt(1)
            }
            ToolButton
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                Icon
                {
                    text: starIcon
                    color: rate >= 2 ? starColor :starReg
                    iconSize: starSize
                }

                onClicked: rateIt(2)
            }
            ToolButton
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                Icon
                {
                    text: starIcon
                    color: rate >= 3 ? starColor :starReg
                    iconSize: starSize
                }

                onClicked: rateIt(3)
            }

//            ToolButton
//            {
//                Layout.fillHeight: true
//                Layout.fillWidth: true
//                Layout.alignment: Qt.AlignCenter
//                Icon
//                {
//                    text: starIcon
//                    color: rate >= 4 ? starColor :starReg
//                    iconSize: starSize
//                }

//                onClicked: rateIt(4)
//            }

//            ToolButton
//            {
//                Layout.fillHeight: true
//                Layout.fillWidth: true
//                Layout.alignment: Qt.AlignCenter
//                Icon
//                {
//                    text: starIcon
//                    color: rate >= 5 ? starColor :starReg
//                    iconSize: starSize
//                }

//                onClicked: rateIt(5)
//            }



        }

    }
}
