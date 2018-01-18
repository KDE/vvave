import QtQuick 2.9
import QtQuick.Controls 2.2
import QtLocation 5.9
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
//import org.kde.kirigami 2.0 as Kirigami

import "utils/Icons.js" as MdiFont
import "utils/Player.js" as Player
import "utils"
import "view_models"
import "widgets"

//Kirigami.ApplicationWindow
ApplicationWindow
{
    id: root
    visible: true
    width: 400
    height: 500
    title: qsTr("Babe")


    SystemPalette { id: myPalette; colorGroup: SystemPalette.Active }


    //    property int columnWidth: Kirigami.Units.gridUnit * 13
    property int columnWidth: Math.sqrt(root.width*root.height)*0.4
    property int currentView : 0
    property int iconSize
    property alias mainPlaylist : mainPlaylist
    //    minimumWidth: columnWidth

    //    pageStack.defaultColumnWidth: columnWidth
    //    pageStack.initialPage: [playlistPage, views]


    onWidthChanged: if(bae.isMobile())
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
            var query = searchInput.text
            var queries = query.split(",")
            var res = bae.searchFor(queries)

            searchView.populate(res)
            //                albumsView.filter(res)
            currentView = 5
        }
    }

    Connections
    {
        target: player
        onPos: mainPlaylist.progressBar.value = pos
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
        size: iconSize
        currentIndex: currentView

        onPlaylistViewClicked: currentView = 0
        onTracksViewClicked: currentView = 1
        onAlbumsViewClicked: currentView = 2
        onArtistsViewClicked: currentView = 3
        onPlaylistsViewClicked: currentView = 4
        onSettingsViewClicked: settingsDrawer.visible ? settingsDrawer.close() : settingsDrawer.open()
    }

    footer: Rectangle
    {
        id: searchBox
        width: parent.width
        height: 48
        color: bae.midColor()

        TextInput
        {
            id: searchInput
            anchors.fill: parent
            anchors.centerIn: parent
            color: bae.foregroundColor()
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:  Text.AlignVCenter
            selectByMouse: !bae.isMobile()
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

            Icon
            {
                anchors.centerIn: parent
                visible: !(searchInput.focus || searchInput.text)
                id: searchBtn
                text: MdiFont.Icon.magnify
                color: bae.foregroundColor()
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

    SettingsView
    {
        id: settingsDrawer
        onIconSizeChanged: iconSize = size
    }


    Page
    {
        id: views
        width: parent.width
        height: parent.height
        clip: true

        transform: Translate {
            x: (settingsDrawer.position * views.width * 0.33)*-1
        }

        Column
        {
            width: parent.width
            height: parent.height

            SwipeView
            {
                id: swipeView
                width: parent.width
                height: parent.height

                onCurrentIndexChanged: currentView = currentIndex

                Component.onCompleted: contentItem.interactive = bae.isMobile()

                currentIndex: currentView


                MainPlaylist
                {
                    id: mainPlaylist
                    Connections
                    {
                        target: mainPlaylist
                        onCoverPressed: Player.appendAlbum(tracks)
                        onCoverDoubleClicked: Player.playAlbum(tracks)
                    }
                }


                TracksView
                {
                    id: tracksView
                    Connections
                    {
                        target: tracksView
                        onRowClicked: Player.addTrack(tracksView.model.get(index))
                        onQuickPlayTrack: Player.quickPlay(tracksView.model.get(index))
                    }

                }

                AlbumsView
                {
                    id: albumsView
                    Connections
                    {
                        target: albumsView
                        onRowClicked: Player.addTrack(track)
                        onPlayAlbum: Player.playAlbum(tracks)
                        onAppendAlbum: Player.appendAlbum(tracks)
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
                        onPlayAlbum: Player.playAlbum(tracks)
                        onAppendAlbum: Player.appendAlbum(tracks)
                        onPlayTrack: Player.quickPlay(track)
                    }
                }

                PlaylistsView {}


                SearchTable
                {
                    id: searchView
                    Connections
                    {
                        target: searchView
                        onRowClicked: Player.addTrack(searchView.model.get(index))
                        onQuickPlayTrack: Player.quickPlay(searchView.model.get(index))
                    }
                }

            }
        }
    }
}
