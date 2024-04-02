import QtQuick
import QtQuick.Controls

import org.mauikit.controls as Maui
import org.maui.vvave as Vvave

import "BabeTable"
import "BabeGrid"

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

    list.query : Q.GET.allTracks
    listModel.sort : "artist"
    listModel.sortOrder : Qt.AscendingOrder
    group: true

    onRowClicked: (index) => Player.quickPlay(listModel.get(index))
    onAppendTrack: (index) => Player.addTrack(listModel.get(index))
    onQueueTrack:(index) => Player.queueTracks([listModel.get(index)], index)

    onPlayAll: Player.playAllModel(listModel.list)
    onAppendAll: Player.appendAllModel(listModel.list)
    onShuffleAll: Player.shuffleAllModel(listModel.list)
}
