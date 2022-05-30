import QtQuick 2.0
import QtQuick.Controls 2.10

import org.mauikit.controls 1.3 as Maui
import org.kde.kirigami 2.6 as Kirigami

Maui.ContextualMenu
{
    id: control

    property bool fav : false
    property int index
    property var titleInfo

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

    title: control.titleInfo.title
    subtitle: control.titleInfo.artist
    titleImageSource: "image://artwork/album:"+ control.titleInfo.artist+":"+control.titleInfo.album

    Maui.MenuItemActionRow
    {
        Action
        {
            text: !fav ? i18n("Fav it"): i18n("UnFav it")
            checked: control.fav
            checkable: true
            icon.name: "love"
            onTriggered: favClicked()
        }

        Action
        {
            text: i18n("Tags")
            icon.name: "tag"
            onTriggered: saveToClicked()
        }

        Action
        {
            text: i18n("Edit")
            icon.name: "document-edit"
            onTriggered:
            {
                editClicked()
            }
        }

        Action
        {
            text: i18n("Share")
            icon.name: "document-share"
            onTriggered: shareClicked()
        }
    }

    MenuSeparator {}

    MenuItem
    {
        text: i18n("Select...")
        icon.name: "item-select"
        onTriggered:
        {
            selectionBar.addToSelection(listModel.get(control.index))
            selectionMode = Maui.Handy.isTouch
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
        }
    }

    MenuSeparator{}



    //    MenuItem
    //    {
    //        enabled: Maui.App.handleAccounts
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
        enabled: !Maui.Handy.isAndroid
        onTriggered:
        {
            openWithClicked()
        }
    }

    MenuSeparator {}



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
        Maui.Theme.textColor: Maui.Theme.negativeTextColor
        onTriggered:
        {
            deleteClicked()
        }
    }
}
