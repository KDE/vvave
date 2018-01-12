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
    property int columnWidth: 250
    property int currentView : 0
    property int iconSize
    property alias mainPlaylist : mainPlaylist

    //    minimumWidth: columnWidth

    //    pageStack.defaultColumnWidth: columnWidth
    //    pageStack.initialPage: [playlistPage, views]
    onWidthChanged: if(Qt.platform.os === "android")
                    {
                        if(root.width>root.height)
                            mainPlaylist.cover.visible = false
                        else  mainPlaylist.cover.visible = true
                    }


    onClosing: Player.savePlaylist()


    Connections
    {
        target: player
        onPos: mainPlaylist.progressBar.value = pos
        onFinished: Player.nextTrack()
    }

    Connections
    {
        target: set
        onRefreshTables:
        {
            tracksView.clearTable()
            albumsView.clearGrid()
            artistsView.clearGrid()

            tracksView.populate()
            albumsView.populate()
            artistsView.populate()
        }
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
        onSettingsViewClicked: currentView = 5
    }

    footer: Rectangle
    {
        id: searchBox
        width: parent.width
        height: 32
        color: util.midColor()

        TextInput
        {
            id: searchInput
            anchors.fill: parent
            anchors.centerIn: parent
            color: util.foregroundColor()
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment:  Text.AlignVCenter

            property string placeholderText: "Search..."

            Label
            {
                anchors.fill: parent
                text: searchInput.placeholderText
                visible: !(searchInput.focus || searchInput.text)
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:  Text.AlignVCenter
                font.bold: true
                color: util.foregroundColor()
            }

        }
    }

    Rectangle
    {
        anchors.fill: parent
        color: util.altColor()
        z: -999
    }

    Page
    {
        id: views
        width: parent.width
        height: parent.height
        clip: true

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

                Component.onCompleted:
                {
                    if(Qt.platform.os === "linux")
                        contentItem.interactive = false
                    else if(Qt.platform.os === "android")
                        contentItem.interactive = true
                }

                currentIndex: currentView


                MainPlaylist
                {
                    id: mainPlaylist
                }


                TracksView
                {
                    id: tracksView
                    onRowClicked: Player.appendTrack(model.get(index))
                }

                AlbumsView
                {
                    id: albumsView
                    onRowClicked: Player.appendTrack(track)
                    onPlayAlbum: Player.playAlbum(tracks)
                    onAppendAlbum: Player.appendAlbum(tracks)
                }

                ArtistsView
                {
                    id: artistsView
                    onRowClicked: Player.appendTrack(track)
                    onPlayAlbum: Player.playAlbum(tracks)
                    onAppendAlbum: Player.appendAlbum(tracks)
                }

                PlaylistsView {}

                SettingsView
                {
                    onIconSizeChanged: iconSize = size
                }

            }
        }
    }
}
