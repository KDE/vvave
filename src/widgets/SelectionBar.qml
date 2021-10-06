import QtQuick 2.0
import QtQuick.Controls 2.10

import "../utils/Player.js" as Player
import "BabeTable"

import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.2 as Maui

Maui.SelectionBar
{
    id: control

    listDelegate: TableDelegate
    {
        isCurrentItem: false
        Kirigami.Theme.inherit: true
        width: ListView.view.width
        number: false
        coverArt: true
        checked: true
        checkable: true
        onToggled: control.removeAtIndex(index)
        background: Item {}
    }

    Action
    {
        text: i18n("Play")
        icon.name: "media-playback-start"
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
        text: i18n("Tags")
        icon.name: "tag"
        onTriggered:
        {
            _dialogLoader.sourceComponent = _playlistDialogComponent
            dialog.composerList.urls = control.uris
            dialog.open()
        }
    }

    hiddenActions: [
        Action
        {
            text: i18n("Share")
            icon.name: "document-share"
            onTriggered: Maui.Platform.shareFiles(control.uris)
        },

        Action
        {
            text: i18n("Queue")
            icon.name: "view-media-recent"
            onTriggered:
            {
                Player.queueTracks(control.items)
            }
        },

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
    ]

    function addToSelection(item)
    {
        if(control.contains(String(item.url)))
        {
            control.removeAtUri(String(item.url))
            return
        }

        item.thumbnail= item.artwork
        item.icon = "audio-x-generic"
        item.label= item.title
        item.mime= "image/png"
        item.tooltip= item.url
        item.path= item.url

        control.append(item.url, item)
    }
}
