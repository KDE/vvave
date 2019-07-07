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
    width: unit * 200

    property int rate : 0
    property bool fav : false
    property string starColor : "#FFC107"
    property string starReg : textColor
    property string starIcon: "draw-star"

    signal removeClicked()
    signal favClicked()
    signal queueClicked()
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
            H.addToSelection(listView.model.get(listView.currentIndex))
            contextMenu.close()
        }
    }

    MenuSeparator {}

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
        text: qsTr("Queue")
        onTriggered:
        {
            queueClicked()
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


    MenuItem
    {
        visible: root.showAccounts
        text: qsTr("Copy to cloud")
        onTriggered:
        {
            copyToClicked()
            close()
        }
    }

    MenuItem
    {
        text: isAndroid ? qsTr("Open with...") : qsTr("Show in folder...")

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
        Kirigami.Theme.textColor: dangerColor
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
        height: iconSizes.medium + space.small

        RowLayout
        {
            anchors.fill: parent

            Maui.ToolButton
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                iconName: starIcon
                size: iconSizes.medium
                iconColor: rate >= 1 ? starColor :starReg
                onClicked:
                {
                    rate = 1
                    rateClicked(rate)
                    close()
                }
            }

            Maui.ToolButton
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                size: iconSizes.medium
                iconName: starIcon
                iconColor: rate >= 2 ? starColor :starReg
                onClicked:
                {
                    rate = 2
                    rateClicked(rate)
                    close()
                }
            }

            Maui.ToolButton
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                size: iconSizes.medium
                iconName: starIcon
                iconColor: rate >= 3 ? starColor :starReg
                onClicked:
                {
                    rate = 3
                    rateClicked(rate)
                    close()
                }
            }

            Maui.ToolButton
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                size: iconSizes.medium
                iconName: starIcon
                iconColor: rate >= 4 ? starColor :starReg
                onClicked:
                {
                    rate = 4
                    rateClicked(rate)
                    close()
                }
            }

            Maui.ToolButton
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                size: iconSizes.medium
                iconName: starIcon
                iconColor: rate >= 5 ? starColor :starReg
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
        height:  iconSizes.medium + space.small

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
