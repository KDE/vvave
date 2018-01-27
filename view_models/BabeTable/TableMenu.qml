import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../utils/Help.js" as H
import "../../utils"
import ".."

Menu
{
    id: rootMenu
    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2
    modal: root.isMobile
    focus: true


    property int rate : 0
    property string starColor : "#FFC107"
    property string starReg : bae.foregroundColor()
    property string starIcon: "draw-star"
    property int assetsize : menuItemHeight/2
    property int menuItemHeight : root.isMobile ? 48 : 32;


    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0 }
    }

    function rateIt(rank)
    {
        rate = rank
        if(bae.rateTrack(list.model.get(list.currentIndex).url, rate))
        {
            list.currentItem.trackRating.text = list.currentItem.setStars(rate)
            list.model.get(list.currentIndex).stars = rate
        }
        if(!root.isMobile)
            dismiss()
        else close()
    }

    function moodIt(color)
    {
        if(bae.moodTrack(list.model.get(list.currentIndex).url, color))
        {
            list.currentItem.trackMood = color
            list.model.get(list.currentIndex).art = color
        }
        if(!root.isMobile)
            dismiss()
        else close()
    }


    background: Rectangle
    {
        implicitWidth: 200
        implicitHeight: 40
        color: bae.altColor()
        border.color: bae.midLightColor()
        border.width: 1
        radius: 3

    }


    //    Label
    //    {
    //        id: titleLabel
    //        visible: root.isMobile
    //        padding: root.isMobile ? 10 : 0
    //        font.bold: true
    //        width: parent.width
    //        height: root.isMobile ? menuItemHeight : 0
    //        horizontalAlignment: Qt.AlignHCenter
    //        elide: Text.ElideRight
    //        text: list.currentIndex >= 0 ? list.model.get(list.currentIndex).title : ""
    //        color: root.palette["foreground"]
    //    }

    TableMenuItem
    {
        height: menuItemHeight
        txt: "Babe it"
        onTriggered: {}
    }

    TableMenuItem
    {
        height: menuItemHeight
        txt: "Queue"
        onTriggered: list.queueTrack(list.currentIndex)
    }

    TableMenuItem
    {
        height: menuItemHeight
        txt: "Edit..."
        onTriggered: {}
    }

    TableMenuItem
    {
        height: menuItemHeight
        txt: "Remove"
        onTriggered: listModel.remove(list.currentIndex)
    }

    TableMenuItem
    {
        height: menuItemHeight
        txt: "Save..."
        onTriggered: {}
    }

    TableMenuItem
    {
        height: menuItemHeight
        txt: "Send to..."
        onTriggered: {}
    }


    MenuItem
    {
        height: menuItemHeight
        hoverEnabled: true
        padding: 10

        RowLayout
        {
            anchors.fill: parent
            BabeButton
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter

                iconName: starIcon
                iconColor: rate >= 1 ? starColor :starReg
                iconSize: assetsize

                onClicked: rateIt(1)
            }
            BabeButton
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                iconName: starIcon
                iconColor: rate >= 2 ? starColor :starReg
                iconSize: assetsize
                onClicked: rateIt(2)
            }
            BabeButton
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                iconName: starIcon
                iconColor: rate >= 3 ? starColor :starReg
                iconSize: assetsize

                onClicked: rateIt(3)
            }

            BabeButton
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                iconName: starIcon
                iconColor: rate >= 4 ? starColor :starReg
                iconSize: assetsize

                onClicked: rateIt(4)
            }

            BabeButton
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                iconName: starIcon
                iconColor: rate >= 5 ? starColor :starReg
                iconSize: assetsize

                onClicked: rateIt(5)
            }
        }

    }

    MenuItem
    {
        height: menuItemHeight
        hoverEnabled: true
        padding: 10
        ColorTagsBar
        {
            anchors.fill: parent
            recSize: assetsize
            onColorClicked: moodIt(color)
        }
    }
}
