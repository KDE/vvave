import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models/BabeMenu"
import "../../utils"
import ".."
import "../../utils/Player.js" as Player
import "../../utils/Help.js" as H

import org.kde.maui 1.0 as Maui

BabeMenu
{

    property int rate : 0
    property bool babe : false
    property string starColor : "#FFC107"
    property string starReg : textColor
    property string starIcon: "draw-star"

    signal trackRemoved(string url)

    property alias menuItem : customItems.children

    function queueIt(index)
    {
        Player.queueTracks([list.model.get(index)])
    }

    function rateIt(rank)
    {
        rate = rank
        if(bae.rateTrack(list.model.get(list.currentIndex).url, rate))
        {
            babeTableRoot.list.currentItem.rate(H.setStars(rate))
            babeTableRoot.ist.model.get(list.currentIndex).stars = rate
        }


        close()
    }

    function moodIt(color)
    {
        if(bae.colorTagTrack(list.model.get(list.currentIndex).url, color))
        {
            list.currentItem.trackMood = color
            list.model.get(list.currentIndex).art = color
        }

        close()
    }

    function babeIt(index)
    {
        if(list.count>0)
        {
            console.log(index);
            var url = listModel.get(index).url
            var value = listModel.get(index).babe == "1" ? false : true

            if(bae.babeTrack(url, value))
                list.model.get(index).babe = value ? "1" : "0"

            return value
        }
    }

    Label
    {
        id: titleLabel
        visible: isAndroid
        padding: isAndroid ? space.small : 0
        font.bold: true
        width: parent.width
        height: isAndroid ? iconSizes.medium : 0
        horizontalAlignment: Qt.AlignHCenter
        elide: Text.ElideRight
        text: list.currentIndex >= 0 ? list.model.get(list.currentIndex).title : ""
        color: textColor
    }

    MenuItem
    {
        text: babe == false ? "Babe it" : "UnBabe it"
        onTriggered:
        {
            babeIt(list.currentIndex)
            close()
        }
    }

    MenuItem
    {
        text: "Queue"
        onTriggered:
        {
            queueIt(list.currentIndex)
            close()
        }
    }

    MenuItem
    {
        text: "Save to..."
        onTriggered:
        {
            playlistDialog.tracks = [list.model.get(list.currentIndex).url]
            playlistDialog.open()
            close()
        }
    }

    MenuItem
    {
        text: isAndroid ? qsTr("Open with...") : qsTr("Show in folder...")

        onTriggered:
        {
            !isAndroid ?
                        bae.showFolder(list.model.get(list.currentIndex).url) :
                        bae.openFile(list.model.get(list.currentIndex).url)
            close()
        }
    }

    MenuItem
    {
        text: "Edit..."
        onTriggered: {close()}
    }

    MenuItem
    {
        text: "Share..."
        onTriggered:
        {
            isAndroid ? Maui.Android.shareDialog(list.model.get(list.currentIndex).url) :
                        shareDialog.show(list.model.get(list.currentIndex).url)
            close()
        }
    }

    MenuItem
    {
        text: "Remove"
        onTriggered:
        {
            trackRemoved(list.model.get(list.currentIndex).url)
            listModel.remove(list.currentIndex)
            close()
        }
    }

    Column
    {
        id: customItems
    }

    MenuItem
    {
        id: starsRow
        width: parent.width
        height: iconSizes.small

        RowLayout
        {
            anchors.fill: parent

            Maui.ToolButton
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                iconName: starIcon
                size: iconSizes.small
                iconColor: rate >= 1 ? starColor :starReg
                onClicked: rateIt(1)
            }

            Maui.ToolButton
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                size: iconSizes.small
                iconName: starIcon
                iconColor: rate >= 2 ? starColor :starReg
                onClicked: rateIt(2)
            }

            Maui.ToolButton
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                size: iconSizes.small
                iconName: starIcon
                iconColor: rate >= 3 ? starColor :starReg

                onClicked: rateIt(3)
            }

            Maui.ToolButton
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                size: iconSizes.small
                iconName: starIcon
                iconColor: rate >= 4 ? starColor :starReg

                onClicked: rateIt(4)
            }

            Maui.ToolButton
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                size: iconSizes.small
                iconName: starIcon
                iconColor: rate >= 5 ? starColor :starReg

                onClicked: rateIt(5)
            }
        }

    }

    MenuItem
    {
        id: colorsRow
        width: parent.width
        height:  iconSizes.small

        ColorTagsBar
        {
            anchors.fill: parent
            onColorClicked: moodIt(color)
        }
    }
}
