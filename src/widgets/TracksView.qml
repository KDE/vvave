import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.maui.vvave 1.0 as Vvave

import "BabeTable"
import "BabeGrid"

import "../db/Queries.js" as Q
import "../utils/Player.js" as Player

BabeTable
{
    id: control
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

    listView.header: Column
    {
        width: parent.width
        spacing: Maui.Style.space.big

        Maui.SettingsSection
        {
            visible: _recentTracksList.count
            width: parent.width
            title: i18n("Popular Tracks")
            description: i18n("Play them again.")

            Maui.GridView
            {
                id: _recentTracksList
                verticalScrollBarPolicy: ScrollBar.AlwaysOff
                adaptContent: false
                horizontalScrollBarPolicy:  ScrollBar.AsNeeded
                currentIndex: -1
                Layout.fillWidth: true
                Layout.preferredHeight: 220
                flickable.flow: GridView.FlowTopToBottom
                itemSize: 160
                itemHeight: 70
                model: Maui.BaseModel
                {
                    id: _recentModel
                    list: Vvave.Tracks
                    {
                        query: Q.GET.mostPlayedTracks
                    }

                }

                Connections
                {
                    target: player
                    function onFinished()
                    {
                        _recentModel.list.refresh()
                    }
                }

                delegate: Item
                {
                    height: GridView.view.cellHeight
                    width: GridView.view.cellWidth

                    Maui.ListBrowserDelegate
                    {
                        id: _template
                        anchors.fill: parent
                        anchors.margins: Maui.Style.space.small
                        maskRadius: radius
                        label1.text: model.title
                        label2.text: model.artist
                        imageSource: "image://artwork/album:"+ model.artist+":"+model.album
                        iconVisible: true
                        label1.font.bold: true
                        label1.font.weight: Font.Bold
                        iconSource: "media-album-cover"
                        template.fillMode: Image.PreserveAspectFit
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

        Maui.SettingsSection
        {
            visible: _playlistsList.count
            width: parent.width

            title: i18n("Playlists")
            description: i18n("Recent playlists")


            Maui.ListBrowser
            {
                id: _playlistsList
                model: Maui.BaseModel
                {
                    list: Vvave.Playlists
                    {
                        id: _playlists
                        limit: 10
                    }
                }
                currentIndex: -1

                verticalScrollBarPolicy: ScrollBar.AlwaysOff
                //                horizontalScrollBarPolicy:  ScrollBar.AlwaysOff
                Layout.preferredHeight: 180
                Layout.fillWidth: true
                orientation: ListView.Horizontal
                spacing: Maui.Style.space.medium
                delegate: Item
                {
                    height: ListView.view.height
                    width: height-40

                    Maui.CollageItem
                    {
                        anchors.fill: parent
                        images: model.preview.split(",")
                        flat: true
                        label1.horizontalAlignment: Qt.AlignLeft

                        //                        isCurrentItem: parent.ListView.isCurrentItem
                        maskRadius: radius
                        label1.text: model.playlist
                        iconSource: model.icon
                        label1.font.bold: true
                        label1.font.weight: Font.Bold
                        template.labelSizeHint: 32

                        template.alignment: Qt.AlignLeft
                        template.imageSizeHint: height - 32

                        onClicked:
                        {
                            _playlistsList.currentIndex = index
                            if(Maui.Handy.singleClick)
                            {
                                swipeView.currentIndex = viewsIndex.playlists
                            }
                        }

                        onDoubleClicked:
                        {
                            _playlistsList.currentIndex = index
                            if(!Maui.Handy.singleClick)
                            {
                                swipeView.currentIndex = viewsIndex.playlists
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted:
    {
        control.listView.positionViewAtBeginning()
    }
}


