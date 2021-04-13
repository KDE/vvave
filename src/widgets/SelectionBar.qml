import QtQuick 2.0
import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3

import "../utils/Player.js" as Player
import "../view_models/BabeTable"

import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.2 as Maui

Maui.SelectionBar
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
        width: ListView.view.width
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
        text: i18n("Play")
        icon.name: "media-playlist-play"
        onTriggered:
        {
            mainPlaylist.listModel.list.clear()
            Player.playAll(control.items)
        }
    }

    Action
    {
        text: i18n("Append")
        icon.name: "media-playlist-append"
        onTriggered: Player.appendAll(control.items)
    }

    Action
    {
        text: i18n("Queue")
        icon.name: "view-media-recent"
        onTriggered:
        {
            Player.queueTracks(control.items)
        }
    }

    Action
    {
        text: i18n("Tags")
        icon.name: "tag"
        onTriggered:
        {
            playlistDialog.composerList.urls = control.uris
            playlistDialog.open()
        }
    }

    Action
    {
        text: i18n("Share")
        icon.name: "document-share"
        onTriggered: Maui.Platform.shareFiles(control.uris)
    }

    Action
    {
        text: i18n("Remove")
        icon.name: "edit-delete"
        Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
        onTriggered:
        {
            _dialogLoader.sourceComponent = _removeDialogComponent
            dialog.open()
        }
    }
}
