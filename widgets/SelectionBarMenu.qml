import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../utils"
import ".."
import "../utils/Help.js" as H
import "../utils/Player.js" as Player
import "../view_models"

import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui

Menu
{
    id: control
    width: unit * 200

    property int rate : 0
    property string starColor : "#FFC107"
    property string starReg : textColor
    property string starIcon: "draw-star"

    signal rateClicked(int rate)


    MenuItem
    {
        text: qsTr("Play...")
        onTriggered:
        {
            mainPlaylist.list.clear()

            var tracks = _selectionBar.selectedItems
            for(var i in tracks)
                Player.appendTrack(tracks[i])

            Player.playAll()
        }
    }

    MenuItem
    {
        text: qsTr("Append...")
        onTriggered: Player.appendAll(_selectionBar.selectedItems)
    }

    MenuItem
    {
        text: qsTr("Queue")
        onTriggered:
        {
            Player.queueTracks(_selectionBar.selectedItems)
            close()
        }
    }

//    MenuSeparator {}


//    MenuItem
//    {
//        text: qsTr("Fav/UnFav them")
//        onTriggered:
//        {
//            for(var i= 0; i < _selectionBar.count; i++)
//                _selectionBarModelList.fav(i, !(_selectionBarModelList.get(i).fav == "1"))

//        }
//    }


    MenuItem
    {
        text: qsTr("Add to...")
        onTriggered:
        {
            playlistDialog.tracks = _selectionBar.selectedPaths
            playlistDialog.open()
            close()
        }
    }

    MenuSeparator {}

    MenuItem
    {
        text: qsTr("Share...")
        onTriggered:
        {
            isAndroid ? Maui.Android.shareDialog(_selectionBar.selectedPaths) :
                        shareDialog.show(_selectionBar.selectedPaths)
            close()
        }
    }

    MenuSeparator {}

    MenuItem
    {
        text: qsTr("Remove")
        Kirigami.Theme.textColor: dangerColor
        onTriggered:
        {
            close()
        }
    }

//    MenuSeparator {}

//    MenuItem
//    {
//        id: starsRow
//        width: parent.width
//        height: iconSizes.medium + space.small

//        RowLayout
//        {
//            anchors.fill: parent

//            ToolButton
//            {
//                Layout.fillWidth: true
//                Layout.fillHeight: true
//                icon.name: starIcon
//                icon.width: iconSizes.medium
//                icon.color: rate >= 1 ? starColor :starReg
//                onClicked:
//                {
//                    rate = 1
//                }
//            }

//            ToolButton
//            {
//                Layout.fillWidth: true
//                Layout.fillHeight: true
//                icon.width: iconSizes.medium
//                icon.name: starIcon
//                icon.color: rate >= 2 ? starColor :starReg
//                onClicked:
//                {
//                    rate = 2
//                }
//            }

//            ToolButton
//            {
//                Layout.fillWidth: true
//                Layout.fillHeight: true
//                icon.width: iconSizes.medium
//                icon.name: starIcon
//                icon.color: rate >= 3 ? starColor :starReg
//                onClicked:
//                {
//                    rate = 3
//                }
//            }

//            ToolButton
//            {
//                Layout.fillWidth: true
//                Layout.fillHeight: true
//                icon.width: iconSizes.medium
//                icon.name: starIcon
//                icon.color: rate >= 4 ? starColor :starReg
//                onClicked:
//                {
//                    rate = 4
//                }
//            }

//            ToolButton
//            {
//                Layout.fillWidth: true
//                Layout.fillHeight: true
//                icon.width: iconSizes.medium
//                icon.name: starIcon
//                icon.color: rate >= 5 ? starColor :starReg
//                onClicked:
//                {
//                    rate = 5
//                }
//            }
//        }
//    }

//    onRateChanged:
//    {
//        close()
//        for(var i= 0; i < _selectionBar.count; i++)
//            _selectionBarModelList.rate(i, control.rate)


//    }

//    MenuItem
//    {
//        id: colorsRow
//        width: parent.width
//        height:  iconSizes.medium + space.small

//        ColorTagsBar
//        {
//            anchors.fill: parent
//            onColorClicked:
//            {
//                for(var i= 0; i < _selectionBar.count; i++)
//                    _selectionBarModelList.color(i, color)
//                control.close()
//            }
//        }
//    }
}
