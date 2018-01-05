import QtQuick 2.9
import QtQuick.Controls 2.2
import QtLocation 5.9
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.0 as Kirigami

import "utils/Icons.js" as MdiFont
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

    property int defaultColumnWidth: Kirigami.Units.gridUnit * 13
    property int columnWidth: defaultColumnWidth
    property int currentView : 0
    property int iconSize

    pageStack.defaultColumnWidth: columnWidth
    pageStack.initialPage: [playlist, views]

    Connections
    {
        target: con
        onQmlSignal: console.log("lalaland")
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

        onPlaylistClicked:
        {
            con.test()
            console.log(BAE.SettingPath)
        }
    }


    Component
    {
        id: playlist

        Page
        {
            id: playlistPage
            width: parent.width
            height: parent.height

            ColumnLayout
            {
                width: parent.width
                height: parent.height

                Rectangle
                {
                    id: coverPlay
                    width: parent.width
                    height: parent.width < columnWidth ? parent.width : columnWidth

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
                        source: "qrc:/assets/test.jpg"
                    }
                }

                ProgressBar
                {
                    id: progressBar
                    width: parent.width
                    Layout.fillWidth: true
                    anchors.top: coverPlay.bottom
                    height: 16
                    value: 0.5
                }

                Rectangle
                {
                    id: playbackControls
                    anchors.top: progressBar.bottom
                    Layout.fillWidth: true
                    width: parent.width
                    height: 48
                    z: 1

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
                            }

                            ToolButton
                            {
                                id: playBtn
                                Icon{text: MdiFont.Icon.play}
                            }

                            ToolButton
                            {
                                id: pauseBtn
                                Icon{text: MdiFont.Icon.pause}
                            }

                            ToolButton
                            {
                                id: nextBtn
                                Icon{text: MdiFont.Icon.skipNext}
                            }
                        }
                    }
                }


                Rectangle
                {
                    width: parent.width
                    height: parent.height-coverPlay.height - playbackControls.height
                    anchors.top: playbackControls.bottom
                    BabeTable
                    {
                        id: mainPlaylist
                        width: parent.width
                        height: parent.height

                    }
                }
            }
        }
    }

    Component
    {
        id: views

        Page
        {
            width: parent.width /2
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

                    TracksView {}

                    AlbumsView {}

                    ArtistsView {}

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
}
