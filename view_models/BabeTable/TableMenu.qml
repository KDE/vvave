import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models/BabeMenu"
import "../../utils"
import ".."

BabeMenu
{

    property int rate : 0
    property string starColor : "#FFC107"
    property string starReg : foregroundColor
    property string starIcon: "draw-star"

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
        if(bae.colorTagTrack(list.model.get(list.currentIndex).url, color))
        {
            list.currentItem.trackMood = color
            list.model.get(list.currentIndex).art = color
        }
        if(!root.isMobile)
            dismiss()
        else close()
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

    BabeMenuItem
    {
        text: "Babe it"
        onTriggered: {}
    }

    BabeMenuItem
    {
        text: "Queue"
        onTriggered: list.queueTrack(list.currentIndex)
    }

    BabeMenuItem
    {
        text: "Edit..."
        onTriggered: {}
    }

    BabeMenuItem
    {
        text: "Remove"
        onTriggered: listModel.remove(list.currentIndex)
    }

    BabeMenuItem
    {
        text: "Save..."
        onTriggered: {}
    }

    BabeMenuItem
    {
        text: "Send to..."
        onTriggered: {}
    }


    BabeMenuItem
    {
        id: starsRow
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
                iconSize: starsRow.assetsize

                onClicked: rateIt(1)
            }
            BabeButton
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                iconName: starIcon
                iconColor: rate >= 2 ? starColor :starReg
                iconSize: starsRow.assetsize
                onClicked: rateIt(2)
            }
            BabeButton
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                iconName: starIcon
                iconColor: rate >= 3 ? starColor :starReg
                iconSize: starsRow.assetsize

                onClicked: rateIt(3)
            }

            BabeButton
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                iconName: starIcon
                iconColor: rate >= 4 ? starColor :starReg
                iconSize: starsRow.assetsize

                onClicked: rateIt(4)
            }

            BabeButton
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                iconName: starIcon
                iconColor: rate >= 5 ? starColor :starReg
                iconSize: starsRow.assetsize

                onClicked: rateIt(5)
            }
        }

    }

    BabeMenuItem
    {
        id: colorsRow
        hoverEnabled: true
        padding: 10
        ColorTagsBar
        {
            anchors.fill: parent
            recSize: colorsRow.assetsize
            onColorClicked: moodIt(color)
        }
    }
}
