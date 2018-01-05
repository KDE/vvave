import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../utils/Icons.js" as MdiFont
import "../utils"


ToolBar
{
    property alias babeBar : babeBar
    property string accentColor : "#fa5a77"
    property string textColor : "#ffffff"
    property string backgroundColor : "#31363b"    
    property int size

    property int currentIndex : 0

    signal tracksViewClicked()
    signal albumsViewClicked()
    signal artistsViewClicked()
    signal playlistsViewClicked()
    signal settingsViewClicked()
    signal playlistClicked()


    id: babeBar
    visible: false

    Rectangle
    {
        anchors.fill: parent
        color: backgroundColor
    }

    RowLayout
    {
        anchors.fill: parent
        ToolButton
        {
            id: playlistView
            Icon
            {
                text: MdiFont.Icon.playCircle
                color: currentIndex === -1? accentColor : textColor
                iconSize: size
            }

            ToolTip { text: "Playlist" }

            onClicked: playlistClicked()
        }

        Row
        {
            anchors.centerIn: parent

            ToolButton
            {
                id: tracksView
                Icon
                {
                    id: tracksIcon
                    text: MdiFont.Icon.musicNote
                    color: currentIndex === 0? accentColor : textColor
                    iconSize: size

                }

                onClicked: tracksViewClicked()

                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Tracks")
            }

            ToolButton
            {
                id: albumsView
                Icon
                {
                    id: albumsIcon
                    text: MdiFont.Icon.album
                    color: currentIndex === 1? accentColor : textColor
                    iconSize: size

                }

                onClicked: albumsViewClicked()

                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Albums")
            }

            ToolButton
            {
                id: artistsView

                Icon
                {
                    id: artistsIcon
                    text: MdiFont.Icon.face
                    color: currentIndex === 2? accentColor : textColor
                    iconSize: size

                }

                onClicked: artistsViewClicked()
                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Artists")
            }

            ToolButton
            {
                id: playlistsView

                Icon
                {
                    id: playlistsIcon
                    text: MdiFont.Icon.libraryMusic
                    color: currentIndex === 3? accentColor : textColor
                    iconSize: size

                }

                onClicked: playlistsViewClicked()

                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Playlists")
            }

            ToolButton
            {
                id: settingsView

                Icon
                {
                    id: settingsIcon
                    text: MdiFont.Icon.settings
                    color: currentIndex === 4? accentColor : textColor
                    iconSize: size

                }

                onClicked: settingsViewClicked()

                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Settings")
            }
        }
    }
}

