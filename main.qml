import QtQuick 2.9
import QtQuick.Controls 2.2
import QtLocation 5.9
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0


import org.kde.kirigami 2.0 as Kirigami

import "utils/Icons.js" as MdiFont
import "utils/Player.js" as Player
import "utils"
import "view_models"
import "widgets"

Kirigami.ApplicationWindow
{
    id: root
    visible: true
    width: 400
    height: 500
    title: qsTr("Babe")

    property int columnWidth: Kirigami.Units.gridUnit * 13
    property int currentView : 0
    property int iconSize

    property var currentTrack
    property string currentArtwork


    signal appendTrack(var track)

    pageStack.defaultColumnWidth: columnWidth
    pageStack.initialPage: [playlistPage, views]

    Connections
    {
        target: player
        onPos: progressBar.value = pos
        onFinished: Player.nextTrack()
    }

    header: BabeBar
    {
        id: mainToolbar
        visible: true
        size: iconSize
        currentIndex: currentView

        onTracksViewClicked: currentView = 0
        onAlbumsViewClicked: currentView = 1
        onArtistsViewClicked: currentView = 2
        onPlaylistsViewClicked: currentView = 3
        onSettingsViewClicked: currentView = 4
    }

    onAppendTrack:
    {
        mainPlaylistTable.model.append(track)
    }

    Page
    {
        id: playlistPage
        width: parent.width
        height: parent.height

        Component.onCompleted:
        {
            if(mainPlaylistTable.count>0)
                root.width = columnWidth
            else
                root.width = columnWidth*3
        }

        GridLayout
        {
            id: playlistLayout
            width: parent.width
            height: parent.height
            columns: 1
            rows: 4
            rowSpacing: 0

            Rectangle
            {
                id: coverPlay
                Layout.fillWidth: true
                Layout.row: 1
                height: parent.width < columnWidth ? parent.width : columnWidth

                visible: mainPlaylistTable.count>0

                FastBlur
                {
                    anchors.fill: coverPlay
                    source: artwork
                    radius: 100
                }

                Image
                {
                    id: artwork
                    width: parent.width < columnWidth ? parent.width : columnWidth
                    height:parent.height
                    anchors.centerIn: parent
                    source: currentArtwork ? "file://"+encodeURIComponent(currentArtwork)  : "qrc:/assets/cover.png"

                }
            }

            Slider
            {
                id: progressBar
                Layout.fillWidth: true
                Layout.row: 3
                height: 16
                from: 0
                to: 1000
                value: 0
                visible: mainPlaylistTable.count>0
                spacing: 0

                onMoved:
                {
                    player.seek(player.duration() / 1000 * value);
                }
            }

            Rectangle
            {
                id: playbackControls
                Layout.fillWidth: true
                Layout.row: 2
                height: 48
                visible: mainPlaylistTable.count>0

                RowLayout
                {
                    width: parent.width
                    height: parent.height
                    anchors.fill: parent
                    Row
                    {
                        anchors.centerIn: parent
                        ToolButton
                        {
                            id: previousBtn
                            Icon {text: MdiFont.Icon.skipPrevious}
                            onClicked: Player.previousTrack()
                        }

                        ToolButton
                        {
                            id: babeBtn
                            Icon{text: MdiFont.Icon.heartOutline}
                        }

                        ToolButton
                        {
                            id: playBtn
                            Icon {id: playIcon; text: MdiFont.Icon.play }
                            onClicked:
                            {
                                if(player.isPaused())
                                    Player.resumeTrack()
                                else Player.pauseTrack()

                            }
                        }

                        ToolButton
                        {
                            id: nextBtn
                            Icon{text: MdiFont.Icon.skipNext}
                            onClicked: Player.nextTrack()

                        }
                    }
                }
            }

            Rectangle
            {
                id: mainPlaylist
                Layout.fillWidth: true
                Layout.fillHeight: true

                Layout.row: 4

                BabeTable
                {
                    id: mainPlaylistTable
                    width: parent.width
                    height: parent.height
                    onRowClicked:
                    {
                        Player.playTrack(model.get(index))
                        playIcon.text = MdiFont.Icon.pause
                    }
                }
            }
        }
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
                height: parent.height - searchBox.height

                currentIndex: currentView

                TracksView
                {
                    onRowClicked: appendTrack(model.get(index))
                }

                AlbumsView
                {
                    onRowClicked: appendTrack(track)
                    onPlayAlbum:
                    {
                        mainPlaylistTable.clearTable()
                        for(var i in tracks)
                            appendTrack(tracks[i])
                        Player.playTrack(mainPlaylistTable.model.get(0))
                    }

                }

                ArtistsView
                {
                    onRowClicked: appendTrack(track)
                    onPlayAlbum:
                    {
                        mainPlaylistTable.clearTable()
                        for(var i in tracks)
                            appendTrack(tracks[i])
                        Player.playTrack(mainPlaylistTable.model.get(0))
                    }
                }

                PlaylistsView {}

                SettingsView
                {
                    onIconSizeChanged:
                    {

                        iconSize = size
                        console.log(size)
                    }
                }

                onCurrentIndexChanged:
                {
                    currentView = currentIndex
                }
            }

            Rectangle
            {
                id: searchBox
                width: parent.width
                height: 32
                color: "white"
                TextInput
                {
                    id: searchInput
                    anchors.fill: parent
                    anchors.centerIn: parent

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
                    }

                }
            }
        }


    }
}
