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
    property bool babe : false
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

    function babeIt(index)
    {
        var url = list.model.get(index).url
        var value = list.model.get(index).babe == "1" ? false : true

        if(bae.babeTrack(url, value))
            list.model.get(index).babe = value ? "1" : "0"
    }

    Label
    {
        id: titleLabel
        visible: root.isMobile
        padding: root.isMobile ? 10 : 0
        font.bold: true
        width: parent.width
        height: root.isMobile ? rowHeightAlt : 0
        horizontalAlignment: Qt.AlignHCenter
        elide: Text.ElideRight
        text: list.currentIndex >= 0 ? list.model.get(list.currentIndex).title : ""
        color: foregroundColor
    }

    BabeMenuItem
    {
        text: babe == false ? "Babe it" : "UnBabe it"
        onTriggered: babeIt(list.currentIndex)
    }

    BabeMenuItem
    {
        text: "Queue"
        onTriggered: list.queueTrack(list.currentIndex)
    }

    BabeMenuItem
    {
        text: "Save to..."
        onTriggered:
        {
            playlistDialog.tracks = [list.model.get(list.currentIndex).url]
            playlistDialog.open()
        }
    }

    BabeMenuItem
    {
        text: "Edit..."
        onTriggered: {}
    }

    BabeMenuItem
    {
        text: "Send to..."
        onTriggered: {}
    }

    BabeMenuItem
    {
        text: "Remove"
        onTriggered: listModel.remove(list.currentIndex)
    }

    BabeMenuItem
    {
        id: starsRow
        width: parent.width
        RowLayout
        {
            anchors.fill: parent
            width: parent.width
            BabeButton
            {
                Layout.fillWidth: true
                iconName: starIcon
                iconColor: rate >= 1 ? starColor :starReg
                onClicked: rateIt(1)
            }
            BabeButton
            {
                Layout.fillWidth: true

                iconName: starIcon
                iconColor: rate >= 2 ? starColor :starReg
                onClicked: rateIt(2)
            }
            BabeButton
            {
                Layout.fillWidth: true

                iconName: starIcon
                iconColor: rate >= 3 ? starColor :starReg

                onClicked: rateIt(3)
            }

            BabeButton
            {
                Layout.fillWidth: true

                iconName: starIcon
                iconColor: rate >= 4 ? starColor :starReg

                onClicked: rateIt(4)
            }

            BabeButton
            {
                Layout.fillWidth: true

                iconName: starIcon
                iconColor: rate >= 5 ? starColor :starReg

                onClicked: rateIt(5)
            }
        }

    }

    BabeMenuItem
    {
        id: colorsRow
        width: parent.width

        ColorTagsBar
        {
            anchors.fill: parent
            onColorClicked: moodIt(color)
        }
    }
}
