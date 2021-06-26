import org.mauikit.controls 1.3 as Maui

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
    holder.emojiSize: Maui.Style.iconSizes.huge

    onRowClicked: Player.quickPlay(listModel.get(index))
    onQuickPlayTrack: Player.quickPlay(listModel.get(index))
    onAppendTrack: Player.addTrack(listModel.get(index))
    onPlayAll: Player.playAllModel(listModel.list)
    onAppendAll: Player.appendAllModel( listModel.list)
    onQueueTrack: Player.queueTracks([listModel.get(index)], index)

    list.query: Q.GET.allTracks
    listModel.sort: "artist"
    listModel.sortOrder: Qt.AscendingOrder
    group: true
}


