import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models/BabeMenu"
import "../../utils"
import ".."
import "../../utils/Player.js" as Player
import "../../utils/Help.js" as H

BabeMenu
{

    property int rate : 0
    property bool babe : false
    property string starColor : "#FFC107"
    property string starReg : foregroundColor
    property string starIcon: "draw-star"

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
            list.currentItem.trackRating.text = H.setStars(rate)
            list.model.get(list.currentIndex).stars = rate
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
        console.log(index);
        var url = listModel.get(index).url
        var value = listModel.get(index).babe == "1" ? false : true

        if(bae.babeTrack(url, value))
            list.model.get(index).babe = value ? "1" : "0"

        return value
    }

    BabePopup
    {
        id: sendToPopup
        parent: babeTableRoot
        leftPadding: 1
        rightPadding: 1
        topPadding: contentMargins
        bottomPadding: contentMargins

        BabeList
        {
            id: sentToList
            headerBarVisible: false
            anchors.fill: parent
            holder.message: qsTr("There's not avalible devices")
            model:  ListModel
            {
                id: model
            }

            delegate: BabeDelegate
            {
                id: delegate
                label : name

                Connections
                {
                    target: delegate

                    onClicked:
                    {
                        sentToList.currentIndex = index
                        console.log(sentToList.model.get(index).name,sentToList.model.get(index).key)
                        bae.sendToDevice(sentToList.model.get(index).name,
                                         sentToList.model.get(index).key,
                                         babeTableRoot.model.get(babeTableRoot.currentIndex).url)
                    }
                }
            }
        }

        onOpened:
        {
            sentToList.clearTable()
            var devices = bae.getDevices()
            for( var i in devices)
                sentToList.model.append({name: devices[i].name, key: devices[i].key })
        }

    }


    Label
    {
        id: titleLabel
        visible: root.isMobile
        padding: root.isMobile ? contentMargins : 0
        font.bold: true
        width: parent.width
        height: root.isMobile ? iconSizes.medium : 0
        horizontalAlignment: Qt.AlignHCenter
        elide: Text.ElideRight
        text: list.currentIndex >= 0 ? list.model.get(list.currentIndex).title : ""
        color: foregroundColor
    }

    BabeMenuItem
    {
        text: babe == false ? "Babe it" : "UnBabe it"
        onTriggered:
        {
            babeIt(list.currentIndex)
            close()
        }
    }

    BabeMenuItem
    {
        text: "Queue"
        onTriggered:
        {
            queueIt(list.currentIndex)
            close()
        }
    }

    BabeMenuItem
    {
        text: "Save to..."
        onTriggered:
        {
            playlistDialog.tracks = [list.model.get(list.currentIndex).url]
            playlistDialog.open()
            close()
        }
    }

    BabeMenuItem
    {
        text: isMobile ? qsTr("Open with...") : qsTr("Show in folder...")

        onTriggered:
        {
            !isMobile ?
                        bae.showFolder(list.model.get(list.currentIndex).url) :
                        bae.openFile(list.model.get(list.currentIndex).url)
            close()
        }
    }

    BabeMenuItem
    {
        text: "Edit..."
        onTriggered: {close()}
    }

    BabeMenuItem
    {
        text: "Send to..."
        onTriggered:
        {
            isMobile ?
                        bae.sendTrack(list.model.get(list.currentIndex).url) :
                        sendToPopup.open()
            close()
        }
    }

    BabeMenuItem
    {
        text: "Remove"
        onTriggered:
        {
            listModel.remove(list.currentIndex)
            close()
        }
    }

    Column
    {
        id: customItems
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
