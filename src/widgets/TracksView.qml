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
        height: visible ? implicitHeight : 0
        visible: control.listModel.filter.length === 0 && control.listModel.filters.length === 0
        width: parent.width
        spacing: Maui.Style.space.big

        TracksGroup
        {
            width: parent.width
            title: i18n("Popular Tracks")
            description: i18n("Play them again.")
            list.query: Q.GET.mostPlayedTracks
        }

        TracksGroup
        {
            width: parent.width
            title: i18n("New Tracks")
            description: i18n("Newly added.")
            list.query: Q.GET.newTracks
        }

        GridLayout
        {
            Maui.Theme.colorSet: Maui.Theme.Window
            Maui.Theme.inherit: false

            width: parent.width
            columnSpacing: Maui.Style.space.big
            rowSpacing: Maui.Style.space.big
            columns: width >= 800 ? 2 : 1
            rows: 2

            TracksGroup
            {

                list.query: Q.GET.recentTracks
                Layout.minimumWidth: 400
                Layout.fillWidth: true
                
                title: i18n("Recent Tracks")
                description: i18n("Recently played.")
                padding: Maui.Style.space.medium
                
                background: Rectangle
                {
                    color: Maui.Theme.backgroundColor
                    radius: Maui.Style.radiusV
                }
            }

            TracksGroup
            {
                Layout.minimumWidth: 400
                Layout.fillWidth: true

                title: i18n("Never Played")
                description: i18n("Dust off.")

                padding: Maui.Style.space.medium
                list.query: Q.GET.neverPlayedTracks

                background: Rectangle
                {
                    color: Maui.Theme.backgroundColor
                    radius: Maui.Style.radiusV
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
                orientation: Qt.Horizontal
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


