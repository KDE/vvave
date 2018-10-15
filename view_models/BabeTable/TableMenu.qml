import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../utils"
import ".."

import org.kde.mauikit 1.0 as Maui

Maui.Menu
{
    id: control
    property var paths : []

    property int rate : 0
    property bool babe : false
    property string starColor : "#FFC107"
    property string starReg : textColor
    property string starIcon: "draw-star"

    signal removeClicked(var paths)
    signal favClicked(var paths)
    signal queueClicked(var paths)
    signal saveToClicked(var paths)
    signal openWithClicked(var paths)
    signal editClicked(var paths)
    signal shareClicked(var paths)
    signal selectClicked(var paths)
    signal rateClicked(var paths, int rate)
    signal colorClicked(var paths, string color)

    property alias menuItem : customItems.children

    Maui.MenuItem
    {
        text: babe == false ? qsTr("Fav it"): qsTr("UnFav it")
        onTriggered:
        {
            favClicked(paths)
            close()
        }
    }

    Maui.MenuItem
    {
        text: qsTr("Queue")
        onTriggered:
        {
            queueClicked(paths)
            close()
        }
    }

    Maui.MenuItem
    {
        text: qsTr("Save to...")
        onTriggered:
        {
            saveToClicked(paths)
            close()
        }
    }

    Maui.MenuItem
    {
        text: isAndroid ? qsTr("Open with...") : qsTr("Show in folder...")

        onTriggered:
        {
            openWithClicked(paths)
            close()
        }
    }

    Maui.MenuItem
    {
        text: qsTr("Edit...")
        onTriggered:
        {
            editClicked(paths)
            close()
        }
    }

    Maui.MenuItem
    {
        text: qsTr("Share...")
        onTriggered:
        {
            shareClicked(paths)
            isAndroid ? Maui.Android.shareDialog(paths) :
                        shareDialog.show(paths)
            close()
        }
    }

    Maui.MenuItem
    {
        text: qsTr("Remove")
        onTriggered:
        {
            removeClicked(paths)
            //            listModel.remove(list.currentIndex)
            close()
        }
    }

    Column
    {
        id: customItems
        width: parent.implicitWidth
    }

    Maui.MenuItem
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
                    rateClicked(paths, rate)
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
                    rateClicked(paths, rate)
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
                    rateClicked(paths, rate)
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
                    rateClicked(paths, rate)
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
                    rateClicked(paths, rate)
                    close()
                }
            }
        }

    }


    Maui.MenuItem
    {
        id: colorsRow
        width: parent.width
        height:  iconSizes.medium + space.small

        ColorTagsBar
        {
            anchors.fill: parent
            onColorClicked: control.colorClicked(paths, color)
        }
    }

    function show(urls)
    {
        paths = urls
        contextMenu.popup()
    }
}
