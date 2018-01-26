import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.2 as Kirigami

import "db/Queries.js" as Q
import "utils/Player.js" as Player
import "utils"
import "widgets"
import "widgets/PlaylistsView"
import "widgets/MainPlaylist"
import "view_models"

Kirigami.ApplicationWindow
{
    id: root
    visible: true
    width: 400
    height: 500
    title: qsTr("Babe")

    //    property int columnWidth: Kirigami.Units.gridUnit * 13

    readonly property bool isMobile: bae.isMobile()

    property int columnWidth: Kirigami.Units.gridUnit * 22
    property int coverSize: columnWidth*0.6
    //    property int columnWidth: Math.sqrt(root.width*root.height)*0.4
    property int currentView : 0
    property int toolBarIconSize: isMobile ?  24 : 22
    property alias mainPlaylist : mainPlaylist
    //    minimumWidth: columnWidth

    pageStack.defaultColumnWidth: columnWidth
    pageStack.initialPage: [mainPlaylist, views]
    //    overlay.modal: Rectangle
    //    {
    //        color: "transparent"
    //    }

    //    overlay.modeless: Rectangle
    //    {
    //        color: "transparent"
    //    }

    onWidthChanged: if(root.isMobile)
                    {
                        if(root.width>root.height)
                            mainPlaylist.cover.visible = false
                        else  mainPlaylist.cover.visible = true
                    }


    onClosing: Player.savePlaylist()

    function runSearch()
    {
        if(searchInput.text)
        {
            if(searchInput !== searchView.headerTitle)
            {
                var query = searchInput.text
                searchView.headerTitle = query
                var queries = query.split(",")
                searchView.searchRes = bae.searchFor(queries)

                searchView.populate(searchView.searchRes)
            }
            //                albumsView.filter(res)
            currentView = 5
        }
    }

    function clearSearch()
    {
        searchInput.clear()
        searchView.clearTable()
        searchView.headerTitle = ""
        searchView.searchRes = []
        currentView = 0
    }

    Connections
    {
        target: player
        onPos: mainPlaylist.progressBar.value = pos
        onTiming: mainPlaylist.progressTime.text = time
        onDurationChanged: mainPlaylist.durationTime.text = time
        onFinished: Player.nextTrack()
    }

    Connections
    {
        target: bae
        onRefreshTables:
        {
            tracksView.clearTable()
            albumsView.clearGrid()
            artistsView.clearGrid()

            tracksView.populate()
            albumsView.populate()
            artistsView.populate()
        }

        onTrackLyricsReady:
        {
            if(url === root.mainPlaylist.currentTrack.url)
                root.mainPlaylist.infoView.lyrics = lyrics
        }

        onSkipTrack: Player.nextTrack()
        onBabeIt: Player.babeTrack()
    }

    header: BabeBar
    {
        id: mainToolbar
        visible: true
        size: toolBarIconSize
        currentIndex: currentView

        onPlaylistViewClicked:
        {
            pageStack.currentIndex = 0

        }
        onTracksViewClicked:
        {
            pageStack.currentIndex = 1
            currentView = 0
        }
        onAlbumsViewClicked:
        {
            pageStack.currentIndex = 1
            currentView = 1
        }
        onArtistsViewClicked:
        {
            pageStack.currentIndex = 1
            currentView = 2
        }
        onPlaylistsViewClicked:
        {
            pageStack.currentIndex = 1
            currentView = 3
        }
        onSettingsViewClicked: settingsDrawer.visible ? settingsDrawer.close() : settingsDrawer.open()
    }

    footer: Rectangle
    {
        id: searchBox
        width: parent.width
        height: 48
        color: bae.midLightColor()

        TextInput
        {
            id: searchInput
            anchors.fill: parent
            anchors.centerIn: parent
            color: bae.foregroundColor()
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:  Text.AlignVCenter
            selectByMouse: !root.isMobile
            selectionColor: bae.hightlightColor()
            selectedTextColor: bae.foregroundColor()
            property string placeholderText: "Search..."

            //            Label
            //            {
            //                text: searchInput.placeholderText
            //                visible: !(searchInput.focus || searchInput.text)
            //                horizontalAlignment: Text.AlignHCenter
            //                verticalAlignment:  Text.AlignVCenter
            //                font.bold: true
            //                color: bae.foregroundColor()
            //            }

            BabeButton
            {
                anchors.centerIn: parent
                visible: !(searchInput.focus || searchInput.text)
                id: searchBtn
                iconName: "edit-find" //"search"
            }


            BabeButton
            {
                anchors.right: parent.right
                visible: searchInput.text
                iconName: "edit-clear"

                onClicked: clearSearch()
            }






            //            onTextChanged:
            //            {
            //                if(searchInput.text.length===0)
            //                    albumsView.populate()
            //            }

            onAccepted: runSearch()
        }


    }

    background: Rectangle
    {
        anchors.fill: parent
        color: bae.altColor()
        z: -999
    }

    Component.onCompleted:
    {
        if(!isMobile)
            root.width = columnWidth*3
    }


    SettingsView
    {
        id: settingsDrawer
        onIconSizeChanged: toolBarIconSize = (size === 24 && isMobile) ? 24 : 22
    }



    MainPlaylist
    {
        id: mainPlaylist
        Connections
        {
            target: mainPlaylist
            onCoverPressed: Player.appendAll(tracks)
            onCoverDoubleClicked: Player.playAll(tracks)
        }

    }

    Page
    {
        id: views
        width: parent.width
        height: parent.height
        clip: true

        //        transform: Translate {
        //            x: (settingsDrawer.position * views.width * 0.33)*-1
        //        }

        Column
        {
            width: parent.width
            height: parent.height

            SwipeView
            {
                id: swipeView
                width: parent.width
                height: parent.height

                Component.onCompleted: contentItem.interactive = root.isMobile

                currentIndex: currentView

                onCurrentItemChanged:
                {
                    currentItem.forceActiveFocus();
                }

                onCurrentIndexChanged:
                {
                    currentView = currentIndex
                    if(currentView === 0) mainPlaylist.list.forceActiveFocus()
                    else if(currentView === 1) tracksView.forceActiveFocus()

                }

                TracksView
                {
                    id: tracksView
                    Connections
                    {
                        target: tracksView
                        onRowClicked: Player.addTrack(tracksView.model.get(index))
                        onQuickPlayTrack: Player.quickPlay(tracksView.model.get(index))
                        onPlayAll: Player.playAll(bae.get(Q.Query.allTracks))
                        onAppendAll: Player.appendAll(bae.get(Q.Query.allTracks))

                    }

                }

                AlbumsView
                {
                    id: albumsView
                    Connections
                    {
                        target: albumsView
                        onRowClicked: Player.addTrack(track)
                        onPlayAlbum: Player.playAll(tracks)
                        onAppendAlbum: Player.appendAll(tracks)
                        onPlayTrack: Player.quickPlay(track)
                    }
                }

                ArtistsView
                {
                    id: artistsView

                    Connections
                    {
                        target: artistsView
                        onRowClicked: Player.addTrack(track)
                        onPlayAlbum: Player.playAll(tracks)
                        onAppendAlbum: Player.appendAll(tracks)
                        onPlayTrack: Player.quickPlay(track)
                    }
                }

                PlaylistsView
                {
                    id: playlistsView
                    Connections
                    {
                        target: playlistsView
                        onRowClicked: Player.addTrack(track)
                        onQuickPlayTrack: Player.quickPlay(track)
                        //                        onPlayAll: Player.playAll(bae.get(Q.Query.allTracks))
                        //                        onAppendAll: Player.appendAll(bae.get(Q.Query.allTracks))
                    }
                }


                SearchTable
                {
                    id: searchView
                    Connections
                    {
                        target: searchView
                        onRowClicked: Player.addTrack(searchView.model.get(index))
                        onQuickPlayTrack: Player.quickPlay(searchView.model.get(index))
                        onPlayAll: Player.playAll(searchView.searchRes)
                        onAppendAll: Player.appendAll(searchView.searchRes)
                        onHeaderClosed: clearSearch()
                        onArtworkDoubleClicked:
                        {
                            var query = Q.Query.albumTracks_.arg(searchView.model.get(index).album)
                            query = query.arg(searchView.model.get(index).artist)

                            Player.playAll(bae.get(query))

                        }
                    }
                }

            }
        }
    }
}
