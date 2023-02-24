import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.maui.vvave 1.0 as Vvave

import "BabeTable"
import "BabeGrid"

import "../db/Queries.js" as Q
import "../utils/Player.js" as Player

StackView
{
    id: control

    initialItem: Maui.Page
    {
        headBar.middleContent: Maui.SearchField
            {
                id: _searchField

                Layout.fillWidth: true
                Layout.minimumWidth: 100
                Layout.maximumWidth: 500
                Layout.alignment: Qt.AlignCenter
                placeholderText: i18n("Search collection")

                KeyNavigation.up: control.currentItem
                KeyNavigation.down: control.currentItem

                onAccepted:
                {
                    openOverviewTable( Q.GET.tracksWhere_.arg("t.title LIKE \"%"+text+"%\" OR t.artist LIKE \"%"+text+"%\" OR t.album LIKE \"%"+text+"%\" OR t.genre LIKE \"%"+text+"%\""))
                }

                onCleared: control.pop()
            }



        TracksGroup
        {
            anchors.fill: parent
            background: null
            width: parent.width
            title: i18n("Your Collection")
            description: i18n("Random tracks from your collection.")
            list.query: Q.GET.randomTracks
            implicitHeight: browser.implicitHeight + template.implicitHeight + topPadding + bottomPadding
            orientation: Qt.Vertical
            template.template.content: Button
            {
                text: i18n("View All")
                onClicked: openAllTracks()
            }

            browser.flickable.footer:  Column
            {
                id: _overviewLayout
                //                   visible: control.listModel.filter.length === 0 && control.listModel.filters.length === 0
                width: parent.width
                spacing: Maui.Style.space.big

                Item
                {
                    width: parent.width
                    implicitHeight: Maui.Style.space.huge
                }

                TracksGroup
                {
                    width: parent.width
                    title: i18n("Popular Tracks")
                    description: i18n("Play them again.")
                    list.query: Q.GET.mostPlayedTracks
                }

                GridLayout
                {
                    width: parent.width
                    columnSpacing: Maui.Style.space.big
                    rowSpacing: Maui.Style.space.big
                    columns: width >= 800 ? 2 : 1
                    rows: 2

                    TracksGroup
                    {
                        id: _recentGroup
                        list.query: Q.GET.recentTracks
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.row: 0
                        Layout.column: 0
                        Layout.rowSpan: 2

                        title: i18n("Recent Tracks")
                        description: i18n("Recently played.")

                        template.template.content: Button
                        {
                            text: i18n("More")
                            onClicked: openOverviewTable(Q.GET.recentTracks_)
                        }

                    }

                    TracksGroup
                    {
                        Layout.fillWidth: true
                        Layout.row: 0
                        Layout.column: 1

                        title: i18n("Never Played")
                        description: i18n("Give these tracks a first listen.")

                        list.query: Q.GET.neverPlayedTracks

                        template.template.content: Button
                        {
                            text: i18n("More")
                            onClicked: openOverviewTable(Q.GET.neverPlayedTracks_)
                        }
                    }

                    TracksGroup
                    {
                        Layout.row: 1
                        Layout.column: 1
                        Layout.fillWidth: true

                        title: i18n("Classics")
                        description: i18n("Oldest released tracks from your collection.")

                        list.query: Q.GET.oldTracks
                    }
                }
            }
        }
    }


    Component
    {
        id: _overviewTableComponent

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

            //            list.query: Q.GET.allTracks

            headBar.visible: true
            headBar.leftContent: ToolButton
            {
                icon.name: "go-previous"
                onClicked:
                {
                    _searchField.clear()
                    control.pop()
                }
            }

        }
    }

    function openOverviewTable(query : string)
    {
        control.push(_overviewTableComponent)
        control.currentItem.list.query = query
    }

    function openAllTracks()
    {
        control.push(_overviewTableComponent)
        control.currentItem.list.query = Q.GET.allTracks
        control.currentItem.listModel.sort = "artist"
        control.currentItem.listModel.sortOrder = Qt.AscendingOrder
        control.currentItem.group = true
    }

    function getFilterField() : Item
    {
        return _searchField
    }
}
