import QtQuick.Controls 2.13

import "BabeTable"

import "../db/Queries.js" as Q
import "../utils/Player.js" as Player

BabeTable
{
    trackNumberVisible: false
    coverArtVisible: false

    holder.emoji: "qrc:/assets/dialog-information.svg"
    holder.title : i18n("No Tracks!")
    holder.body: i18n("Add new music sources")
    holder.actions:[

        Action
        {
            text: i18n("Add sources")
            onTriggered: openSettingsDialog()
        },

        Action
        {
            text: i18n("Open file")
        }
    ]

    onRowClicked: Player.quickPlay(listModel.get(index))
    onAppendTrack: Player.addTrack(listModel.get(index))
    onPlayAll: Player.playAllModel(listModel.list)
    onAppendAll: Player.appendAllModel(listModel.list)
    onQueueTrack: Player.queueTracks([listModel.get(index)], index)

    list.query: Q.GET.allTracks
    listModel.sort: "artist"
    listModel.sortOrder: Qt.AscendingOrder
    group: true
}


