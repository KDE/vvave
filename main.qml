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

    property var currentTrack
    property string currentArtwork

    property bool shuffle : false

    //    minimumWidth: columnWidth

    //    pageStack.defaultColumnWidth: columnWidth
    //    pageStack.initialPage: [playlistPage, views]
    onWidthChanged:
    {
        if(Qt.platform.os === "android")
        {
            if(root.width>root.height)
            {
                coverPlay.visible = false

            }else  coverPlay.visible = true
        }
    }

    onClosing:
    {
        Player.savePlaylist()
        Player.savePlaylistPos()
    }

    Connections
    {
        target: player
        onPos: progressBar.value = pos
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

                Item
                {
                    id: playlistPage

                    //                    Component.onCompleted:
                    //                    {
                    //                        if(mainPlaylistTable.count>0)
                    //                            root.width = columnWidth
                    //                        else
                    //                            root.width = columnWidth*3
                    //                    }

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
                            Layout.row: 1
                            height: columnWidth
                            width: parent.width
                            Layout.fillWidth: true

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
                                height: parent.height
                                anchors.centerIn: parent
                                source: currentArtwork ? "file://"+encodeURIComponent(currentArtwork)  : "qrc:/assets/cover.png"
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        Slider
                        {
                            id: progressBar
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            Layout.row: 3
                            height: 16
                            from: 0
                            to: 1000
                            value: 0
                            visible: mainPlaylistTable.count>0
                            spacing: 0

                            onMoved: player.seek(player.duration() / 1000 * value);

                            Rectangle
                            {
                                anchors.fill: parent
                                color: util.midColor()
                                z: -999
                            }
                        }

                        Rectangle
                        {
                            id: playbackControls
                            Layout.fillWidth: true
                            Layout.row: 2
                            height: 48
                            visible: mainPlaylistTable.count>0
                            color: util.midColor()

                            onYChanged:
                            {
                                if(playbackControls.y<columnWidth/4)
                                {
                                    coverPlay.visible= false
                                    playbackControls.y = 0
                                }else
                                {
                                    coverPlay.visible= true
                                    playbackControls.y = columnWidth
                                }
                            }

                            PlaylistMenu
                            {
                                id: playlistMenu
                                onClearOut: Player.clearOutPlaylist()
                                onHideCover: coverPlay.visible = !coverPlay.visible
                                onClean: Player.cleanPlaylist()
                            }

                            MouseArea
                            {
                                anchors.fill: parent
                                drag.target: playbackControls
                                drag.axis: Drag.YAxis
                                drag.minimumY: 0
                                drag.maximumY: columnWidth

                            }

                            RowLayout
                            {
                                width: parent.width
                                height: parent.height
                                anchors.fill: parent
                                ToolButton
                                {
                                    id: menuBtn
                                    Icon {text: MdiFont.Icon.dotsVertical}
                                    onClicked: playlistMenu.open()
                                }
                                Row
                                {
                                    anchors.centerIn: parent
                                    ToolButton
                                    {
                                        Icon
                                        {
                                            id: babeBtnIcon
                                            text: MdiFont.Icon.heartOutline
                                            color: defaultColor
                                        }

                                        onClicked: Player.babeTrack()
                                    }

                                    ToolButton
                                    {
                                        id: previousBtn
                                        Icon {text: MdiFont.Icon.skipPrevious}
                                        onClicked: Player.previousTrack()
                                    }

                                    ToolButton
                                    {
                                        id: playBtn
                                        Icon {id: playIcon; text: MdiFont.Icon.play }
                                        onClicked:
                                        {
                                            if(player.isPaused()) Player.resumeTrack()
                                            else Player.pauseTrack()
                                        }
                                    }

                                    ToolButton
                                    {
                                        id: nextBtn
                                        Icon{text: MdiFont.Icon.skipNext}
                                        onClicked: Player.nextTrack()

                                    }

                                    ToolButton
                                    {
                                        id: shuffleBtn
                                        Icon { text: shuffle ? MdiFont.Icon.shuffle : MdiFont.Icon.shuffleDisabled}

                                        onClicked: shuffle = !shuffle
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
                            color: "transparent"
                            BabeTable
                            {
                                id: mainPlaylistTable
                                width: parent.width
                                height: parent.height
                                onRowClicked: Player.playTrack(model.get(index))
                                holder.message: "Empty playlist..."
                                Component.onCompleted:
                                {
                                    var list = util.lastPlaylist()
                                    var n = list.length
                                    for(var i = 0; i < n; i++)
                                    {
                                        var track = con.get("select * from tracks where url = \""+list[i]+"\"")
                                        Player.appendTrack(track[0])
                                    }

                                    //                                    var pos = util.lastPlaylistPos()
                                    //                                    console.log("POSSS:", pos)
                                    //                                    mainPlaylistTable.currentIndex = pos
                                    //                                    play(mainPlaylistTable.model.get(pos))
                                }
                            }
                        }
                    }
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
