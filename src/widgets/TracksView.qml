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
        headBar.middleContent: Loader
        {
            id: _filterLoader
            asynchronous: true
            active: listModel.list.count > 1
            visible: active

            Layout.fillWidth: true
            Layout.minimumWidth: 100
            Layout.maximumWidth: 500
            Layout.alignment: Qt.AlignCenter

            sourceComponent: Maui.SearchField
            {
                placeholderText: i18n("Search collection")

                KeyNavigation.up: control.currentItem
                KeyNavigation.down: control.currentItem

                onAccepted:
                {
                    openOverviewTable( Q.GET.tracksWhere_.arg("t.title LIKE \"%"+text+"%\" OR t.artist LIKE \"%"+text+"%\" OR t.album LIKE \"%"+text+"%\" OR t.genre LIKE \"%"+text+"%\""))
                }

                onCleared: listModel.clearFilters()
            }
        }

        ScrollView
        {
            anchors.fill: parent
            padding: Maui.Style.space.medium

            Flickable
            {
                width: parent.width
                //                contentWidth: availableWidth
                contentHeight: _overviewLayout.implicitHeight

                Column
                {
                    id: _overviewLayout
                    //                   visible: control.listModel.filter.length === 0 && control.listModel.filters.length === 0
                    width: parent.width
                    spacing: Maui.Style.space.big



                    TracksGroup
                    {
                        Maui.Theme.colorSet: Maui.Theme.Window
                        Maui.Theme.inherit: false

                        width: parent.width
                        title: i18n("New Tracks")
                        description: i18n("Newly added.")
                        list.query: Q.GET.newTracks

                        template.template.content: Button
                        {
                            text: i18n("View All")
                            onClicked: openAllTracks()
                        }
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

                        Maui.SettingsSection
                        {
                            Layout.fillWidth: true
                            Layout.row: 0
                            Layout.column: 0
                            title: i18n("Recent Artists")
                            description: i18n("Newly added.")
                            padding: Maui.Style.space.medium
                            template.template.content: Button
                            {
                                text: i18n("More")
                                onClicked:  swipeView.currentIndex = viewsIndex.artists
                            }

                            background: Rectangle
                            {
                                color: Maui.Theme.backgroundColor
                                radius: Maui.Style.radiusV
                            }

                            Maui.ListBrowser
                            {
                                id: _recentArtistsView
                                Layout.fillWidth: true
                                Layout.preferredHeight: 160
                                orientation: ListView.Horizontal
                                clip: true

                                model: Maui.BaseModel
                                {
                                    list: Vvave.Tracks
                                    {
                                        query: Q.GET.recentArtists
                                    }
                                }

                                delegate:  Maui.GridBrowserDelegate
                                {
                                    height: 140
                                    width: 100

                                    label1.text: model.album ? model.album : model.artist
                                    label2.text: model.artist && model.album ? model.artist : ""
                                    imageSource: "image://artwork/%1:".arg("artist")+ model.artist
                                    label1.font.bold: true
                                    label1.font.weight: Font.Bold
                                    iconSource: "media-album-cover"
                                    template.labelSizeHint: 40
                                    template.alignment: Qt.AlignLeft
                                    maskRadius: 100
                                    template.fillMode: Image.PreserveAspectFit

                                    onClicked:
                                    {
                                        _recentArtistsView.currentIndex = index
                                        if(Maui.Handy.singleClick)
                                        {
                                            goToArtist(_recentArtistsView.model.get(_recentArtistsView.currentIndex).artist)
                                        }
                                    }

                                    onDoubleClicked:
                                    {
                                        _recentArtistsView.currentIndex = index
                                        if(!Maui.Handy.singleClick)
                                        {
                                            goToArtist(_recentArtistsView.model.get(_recentArtistsView.currentIndex).artist)
                                        }
                                    }
                                }

                            }
                        }

                        Maui.SettingsSection
                        {

                            Layout.fillWidth: true
                            Layout.row: 1
                            Layout.column: 0
                            title: i18n("Recent Albums")
                            description: i18n("Newly added.")
                            template.template.content: Button
                            {
                                text: i18n("More")
                                onClicked:  swipeView.currentIndex = viewsIndex.albums
                            }



                            Maui.ListBrowser
                            {
                                id: _recentAlbumsView
                                Layout.fillWidth: true
                                Layout.preferredHeight: 160
                                orientation: ListView.Horizontal
                                clip: true
                                model: Maui.BaseModel
                                {
                                    list: Vvave.Tracks
                                    {
                                        query: Q.GET.recentAlbums
                                    }
                                }

                                delegate:  Maui.GridBrowserDelegate
                                {
                                    height: 140
                                    width: 100

                                    label1.text: model.album ? model.album : model.artist
                                    label2.text: model.artist && model.album ? model.artist : ""
                                    imageSource: "image://artwork/%1:".arg("album")+ model.artist+":"+model.album
                                    label1.font.bold: true
                                    label1.font.weight: Font.Bold
                                    iconSource: "media-album-cover"
                                    template.labelSizeHint: 40
                                    template.alignment: Qt.AlignLeft
                                    maskRadius: Maui.Style.radiusV
                                    template.fillMode: Image.PreserveAspectFit

                                    onClicked:
                                    {
                                        _recentAlbumsView.currentIndex = index
                                        if(Maui.Handy.singleClick)
                                        {
                                            let item = _recentAlbumsView.model.get(_recentAlbumsView.currentIndex)
                                            goToAlbum(item.artist, item.album)
                                        }
                                    }

                                    onDoubleClicked:
                                    {
                                        _recentAlbumsView.currentIndex = index
                                        if(!Maui.Handy.singleClick)
                                        {
                                            let item = _recentAlbumsView.model.get(_recentAlbumsView.currentIndex)
                                            goToAlbum(item.artist, item.album)
                                        }
                                    }
                                }

                            }
                        }

                        TracksGroup
                        {

                            Layout.fillWidth: true
                            Layout.row: 0
                            Layout.rowSpan: 2
                            Layout.column: 1
                            Layout.fillHeight: true

                            title: i18n("Popular Tracks")
                            description: i18n("Play them again.")
                            list.query: Q.GET.mostPlayedTracks
                        }

//                        Maui.SettingsSection
//                        {
//                            Layout.fillWidth: true
//                            Layout.row: 0
//                            Layout.rowSpan: 2
//                            Layout.column: 1
//                            Layout.fillHeight: true
//                            title: i18n("Geners")
//                            description: i18n("Newly added.")
//                            padding: Maui.Style.space.medium
//                            template.template.content: Button
//                            {
//                                text: i18n("More")
//                                onClicked: openOverviewTable(Q.GET.recentTracks_)
//                            }

//                            background: Rectangle
//                            {
//                                color: Maui.Theme.backgroundColor
//                                radius: Maui.Style.radiusV
//                            }

//                            Maui.ListBrowser
//                            {
//                                id: _genersView
//                                Layout.fillWidth: true
//                                Layout.fillHeight: true
//                                clip: true

//                                model: Maui.BaseModel
//                                {
//                                    list: Vvave.Tracks
//                                    {
//                                        query: Q.GET.recentArtists
//                                    }
//                                }

//                                delegate:  Maui.ListBrowserDelegate
//                                {
//                                    width: ListView.view.width
////                                    width: 140
//                                    height: Maui.Style.rowHeight

//                                    label1.text: model.album ? model.album : model.artist
//                                    label2.text: model.artist && model.album ? model.artist : ""
//                                    imageSource: "image://artwork/%1:".arg("artist")+ model.artist
//                                    label1.font.bold: true
//                                    label1.font.weight: Font.Bold
//                                    iconSource: "media-album-cover"
//                                }

//                            }
//                        }


                    }

                    Maui.SettingsSection
                    {
                        Maui.Theme.colorSet: Maui.Theme.Window
                        Maui.Theme.inherit: false

                        visible: _playlistsList.count
                        width: parent.width

                        title: i18n("Playlists")
                        description: i18n("Recent playlists")

                        padding: Maui.Style.space.medium

                        template.template.content: Button
                        {
                            text: i18n("More")
                            onClicked: swipeView.currentIndex = viewsIndex.playlists
                        }

                        background: Rectangle
                        {
                            color: Maui.Theme.backgroundColor
                            radius: Maui.Style.radiusV
                        }

                        Maui.ListBrowser
                        {
                            id: _playlistsList
                            clip: true

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
                            id: _recentGroup
                            list.query: Q.GET.recentTracks
                            orientation: Qt.Vertical
                            Layout.minimumWidth: 400
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
                            Layout.minimumWidth: 400
                            Layout.fillWidth: true
                            Layout.row: 0
                            Layout.column: 1

                            title: i18n("Never Played")
                            description: i18n("Dust off.")

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
                            Layout.minimumWidth: 400
                            Layout.fillWidth: true

                            title: i18n("Classics")
                            description: i18n("Dust off.")

                            list.query: Q.GET.oldTracks
                        }
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


            headBar.leftContent: ToolButton
            {
                icon.name: "go-previous"
                onClicked: control.pop()
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

}
