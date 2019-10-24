import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../utils"
import ".."
import "../../utils/Help.js" as H

import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.6 as Kirigami

Menu
{
    id: control
    width: Maui.Style.unit * 200

    property int rate : 0
    property bool fav : false
    property string starColor : "#FFC107"
    property string starReg : Kirigami.Theme.textColor
    property string starIcon: "draw-star"

    signal removeClicked()
    signal favClicked()
    signal queueClicked()
    signal playClicked()
    signal saveToClicked()
    signal openWithClicked()
    signal editClicked()
    signal shareClicked()
    signal selectClicked()
    signal rateClicked(int rate)
    signal colorClicked(color color)
    signal infoClicked()
    signal copyToClicked()

    property alias menuItem : control.contentData

    MenuItem
    {
        text: qsTr("Select...")
        onTriggered:
        {
            H.addToSelection(list.get(listView.currentIndex))
            contextMenu.close()
        }
    }

    MenuSeparator {}

    MenuItem
    {
        text: qsTr("Play")
        onTriggered:
        {
            playClicked()
            close()
        }
    }

    MenuItem
    {
        text: qsTr("Queue")
        onTriggered:
        {
            queueClicked()
            close()
        }
    }

    MenuItem
    {
        text: !fav ? qsTr("Fav it"): qsTr("UnFav it")
        onTriggered:
        {
            favClicked()
            close()
        }
    }   

    MenuItem
    {
        text: qsTr("Add to...")
        onTriggered:
        {
            saveToClicked()
            close()
        }
    }

    MenuSeparator {}

    MenuItem
    {
        text: qsTr("Share...")
        onTriggered:
        {
            shareClicked()
            close()
        }
    }


//    MenuItem
//    {
//        visible: Maui.App.handleAccounts
//        text: qsTr("Copy to cloud")
//        onTriggered:
//        {
//            copyToClicked()
//            close()
//        }
//    }

    MenuItem
    {
        text: qsTr("Show in folder...")
        visible: !isAndroid
        onTriggered:
        {
            openWithClicked()
            close()
        }
    }

    MenuSeparator {}

    MenuItem
    {
        visible: false
        text: qsTr("Edit...")
        onTriggered:
        {
            editClicked()
            close()
        }
    }

//    Maui.MenuItem
//    {
//        text: qsTr("Info...")
//        onTriggered:
//        {
//            infoClicked()
//            close()
//        }
//    }


    MenuItem
    {
        text: qsTr("Remove")
        Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
        onTriggered:
        {
            removeClicked()
            //            listModel.remove(list.currentIndex)
            close()
        }
    }

    MenuSeparator {}

    MenuItem
    {
        id: starsRow
        width: parent.width
        height: Maui.Style.iconSizes.medium + Maui.Style.space.small

        RowLayout
        {
            anchors.fill: parent

            ToolButton
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon.name: starIcon
                icon.width: Maui.Style.iconSizes.medium
                icon.color: rate >= 1 ? starColor :starReg
                onClicked:
                {
                    rate = 1
                    rateClicked(rate)
                    close()
                }
            }

            ToolButton
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon.width: Maui.Style.iconSizes.medium
                icon.name: starIcon
                icon.color: rate >= 2 ? starColor :starReg
                onClicked:
                {
                    rate = 2
                    rateClicked(rate)
                    close()
                }
            }

            ToolButton
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon.width: Maui.Style.iconSizes.medium
                icon.name: starIcon
                icon.color: rate >= 3 ? starColor :starReg
                onClicked:
                {
                    rate = 3
                    rateClicked(rate)
                    close()
                }
            }

            ToolButton
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon.width: Maui.Style.iconSizes.medium
                icon.name: starIcon
                icon.color: rate >= 4 ? starColor :starReg
                onClicked:
                {
                    rate = 4
                    rateClicked(rate)
                    close()
                }
            }

            ToolButton
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon.width: Maui.Style.iconSizes.medium
                icon.name: starIcon
                icon.color: rate >= 5 ? starColor :starReg
                onClicked:
                {
                    rate = 5
                    rateClicked(rate)
                    close()
                }
            }
        }
    }


    MenuItem
    {
        id: colorsRow
        width: parent.width
        height:  Maui.Style.iconSizes.medium + Maui.Style.space.small

        ColorTagsBar
        {
            anchors.fill: parent
            onColorClicked:
            {
                control.colorClicked(color)
                control.close()
            }
        }
    }
}
