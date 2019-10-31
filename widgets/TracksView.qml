import QtQuick 2.9
import org.kde.mauikit 1.0 as Maui
import "../view_models/BabeTable"
import "../view_models"
import "../db/Queries.js" as Q
import "../utils/Help.js" as H

BabeTable
{
    id: tracksViewTable
    trackNumberVisible: false
    headBar.visible: !holder.visible
    coverArtVisible: false
    holder.emoji: "qrc:/assets/dialog-information.svg"
    holder.title : qsTr("No Tracks!")
    holder.body: qsTr("Add new music sources")
    holder.emojiSize: Maui.Style.iconSizes.huge
    list.query: Q.GET.allTracks
}


