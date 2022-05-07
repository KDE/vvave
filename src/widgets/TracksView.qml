import QtQuick 2.15
import QtQuick.Controls 2.15

import org.mauikit.controls 1.3 as Maui
import org.maui.vvave 1.0 as Vvave

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

    onRowClicked: Player.quickPlay(listModel.get(index))
    onAppendTrack: Player.addTrack(listModel.get(index))
    onPlayAll: Player.playAllModel(listModel.list)
    onAppendAll: Player.appendAllModel(listModel.list)
    onQueueTrack: Player.queueTracks([listModel.get(index)], index)

    list.query: Q.GET.allTracks
    listModel.sort: "artist"
    listModel.sortOrder: Qt.AscendingOrder
    group: true

    listView.header: ListView
    {
        id: _recentTracksList
        model: Maui.BaseModel
        {
            id: _recentModel
            list: Vvave.Tracks
            {
                query: Q.GET.mostPlayedTracks
            }

        }

        height: 140
        width: parent.width
        orientation: ListView.Horizontal
        spacing: Maui.Style.space.medium
        delegate: Item
        {
            height: ListView.view.height
            width: height-40

            Maui.GridBrowserDelegate
            {
                id: _template
                anchors.fill: parent

                isCurrentItem: parent.ListView.isCurrentItem
                maskRadius: radius
                label1.text: model.title
                label2.text: model.artist
                imageSource: "image://artwork/album:"+ model.artist+":"+model.album
                label1.font.bold: true
                label1.font.weight: Font.Bold
                iconSource: "media-album-cover"
                template.labelSizeHint: 40

                onClicked:
                {
                    _recentTracksList.currentIndex = index
                    if(Maui.Handy.singleClick)
                    {
                        Player.quickPlay(_recentModel.get(_recentTracksList.currentIndex))
                    }
                }

                onDoubleClicked:
                {
                    _recentTracksList.currentIndex = index
                    if(!Maui.Handy.singleClick)
                    {
                        Player.quickPlay(_recentModel.get(_recentTracksList.currentIndex))
                    }
                }
            }
        }

    }
}


