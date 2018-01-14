import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../utils/Icons.js" as MdiFont
import "../utils"


ToolBar
{
    property alias babeBar : babeBar
    property string accentColor : bae.babeColor()
    property string textColor : bae.foregroundColor()
    property string backgroundColor : bae.backgroundColor()
    property int size //icon size
    property int currentIndex : 0

    signal tracksViewClicked()
    signal albumsViewClicked()
    signal artistsViewClicked()
    signal playlistsViewClicked()
    signal settingsViewClicked()
    signal playlistViewClicked()


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

        Row
        {
            Layout.alignment: Qt.AlignLeft

            ToolButton
            {
                id: playlistView
                Icon
                {
                    text: MdiFont.Icon.headphones
                    color: currentIndex === 0? accentColor : textColor
                    iconSize: size
                }

                onClicked: playlistViewClicked()

                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Playlist")
            }
        }

        Row
        {
            Layout.alignment: Qt.AlignCenter

            ToolButton
            {
                id: tracksView
                Icon
                {
                    id: tracksIcon
                    text: MdiFont.Icon.musicNote
                    color: currentIndex === 1? accentColor : textColor
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
                    color: currentIndex === 2? accentColor : textColor
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
                    color: currentIndex === 3? accentColor : textColor
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
                    color: currentIndex === 4? accentColor : textColor
                    iconSize: size

                }

                onClicked: playlistsViewClicked()

                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Playlists")
            }


        }

        Row
        {
            Layout.alignment: Qt.AlignRight

            ToolButton
            {
                id: settingsView

                Icon
                {
                    id: settingsIcon
                    text: MdiFont.Icon.settings
                    color: currentIndex === 5? accentColor : textColor
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

