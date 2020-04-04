import QtQuick 2.0
import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import "../utils"
import ".."
import "../utils/Help.js" as H
import "../utils/Player.js" as Player
import "../view_models"
import "../view_models/BabeTable"

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

MauiLab.SelectionBar
{
    id: control
    width: Maui.Style.unit * 200

    property int rate : 0
    property string starColor : "#FFC107"
    property string starReg : Kirigami.Theme.textColor
    property string starIcon: "draw-star"

    signal rateClicked(int rate)

    listDelegate: TableDelegate
    {
        isCurrentItem: false
        Kirigami.Theme.inherit: true
        width: parent.width
        number: false
        coverArt: true
        showQuickActions: false
        checked: true
        checkable: true
        onToggled: control.removeAtIndex(index)
        background: Item {}
    }

    Action
    {
        text: qsTr("Play")
        icon.name: "media-playlist-play"
        onTriggered:
        {
            mainPlaylist.list.clear()
            Player.playAll(control.items)
        }
    }

    Action
    {
        text: qsTr("Append")
        icon.name: "media-playlist-append"
        onTriggered: Player.appendAll(control.items)
    }

    Action
    {
        text: qsTr("Queue")
        icon.name: "view-media-recent"
        onTriggered:
        {
            Player.queueTracks(control.items)
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


    Action
    {
        text: qsTr("Add to")
        icon.name: "document-save"
        onTriggered:
        {
            playlistDialog.tracks = control.uris
            playlistDialog.open()
        }
    }

    Action
    {
        text: qsTr("Share")
        icon.name: "document-share"
        onTriggered:
        {
            if(isAndroid)
            {
                 Maui.Android.shareDialog(control.uris)
                return
            }

            _dialogLoader.sourceComponent = _shareDialogComponent
            root.dialog.urls = control.uris
            root.dialog.open()
        }
    }

    Action
    {
        text: qsTr("Remove")
        icon.name: "edit-delete"
        Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
        onTriggered:
        {
        }
    }

//    MenuSeparator {}

//    MenuItem
//    {
//        id: starsRow
//        width: parent.width
//        height: Maui.Style.iconSizes.medium + Maui.Style.space.small

//        RowLayout
//        {
//            anchors.fill: parent

//            ToolButton
//            {
//                Layout.fillWidth: true
//                Layout.fillHeight: true
//                icon.name: starIcon
//                icon.width: Maui.Style.iconSizes.medium
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
//                icon.width: Maui.Style.iconSizes.medium
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
//                icon.width: Maui.Style.iconSizes.medium
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
//                icon.width: Maui.Style.iconSizes.medium
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
//                icon.width: Maui.Style.iconSizes.medium
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
//        height:  Maui.Style.iconSizes.medium + Maui.Style.space.small

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
