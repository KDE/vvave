import QtQuick 2.0
import QtQuick 2.10
import QtQuick.Controls 2.10
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
    modal: true

    property bool fav : false

    signal favClicked()
    signal queueClicked()
    signal saveToClicked()
    signal openWithClicked()
    signal editClicked()
    signal shareClicked()
    signal selectClicked()
    signal infoClicked()
    signal copyToClicked()
    signal deleteClicked()

    property alias menuItem : control.contentData

    MenuItem
    {
        text: i18n("Select...")
        icon.name: "item-select"
        onTriggered:
        {
            H.addToSelection(listModel.get(listView.currentIndex))

            selectionMode = Maui.Handy.isTouch

            contextMenu.close()
        }
    }

    MenuSeparator {}

    MenuItem
    {
        text: i18n("Queue")
        icon.name: "view-media-recent"
        onTriggered:
        {
            queueClicked()
            close()
        }
    }

    MenuSeparator{}

    MenuItem
    {
        text: !fav ? i18n("Fav it"): i18n("UnFav it")
        icon.name: "love"
        onTriggered:
        {
            favClicked()
            close()
        }
    }

    MenuItem
    {
        text: i18n("Tags")
        icon.name: "tag"
        onTriggered:
        {
            saveToClicked()
            close()
        }
    }

    MenuSeparator {}

    MenuItem
    {
        text: i18n("Share")
        icon.name: "document-share"
        onTriggered:
        {
            shareClicked()
            close()
        }
    }


//    MenuItem
//    {
//        visible: Maui.App.handleAccounts
//        text: i18n("Copy to cloud")
//        onTriggered:
//        {
//            copyToClicked()
//            close()
//        }
//    }

    MenuItem
    {
        text: i18n("Show in folder")
        icon.name: "folder-open"
        visible: !Maui.Handy.isAndroid
        onTriggered:
        {
            openWithClicked()
            close()
        }
    }

    MenuSeparator {}

    MenuItem
    {
        text: i18n("Edit")
        icon.name: "document-edit"
        onTriggered:
        {
            editClicked()
            close()
        }
    }

//    Maui.MenuItem
//    {
//        text: i18n("Info...")
//        onTriggered:
//        {
//            infoClicked()
//            close()
//        }
//    }


    MenuItem
    {
        text: i18n("Delete")
        icon.name: "edit-delete"
        Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
        onTriggered:
        {
            deleteClicked()
            close()
        }
    }
 }
