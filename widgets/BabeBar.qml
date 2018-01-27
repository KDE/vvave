import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami

import "../utils"
import "../view_models"

ToolBar
{
    property alias babeBar : babeBar
    property string accentColor : bae.babeColor()
    property string textColor : bae.foregroundColor()
    property string backgroundColor : bae.backgroundColor()
    property int size : 24
    property int currentIndex : 0
    property bool accent : pageStack.wideMode || (!pageStack.wideMode && pageStack.currentIndex === 1)

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

        Kirigami.Separator
        {
            Rectangle
            {
                anchors.fill: parent
                color: Kirigami.Theme.viewFocusColor
            }

            anchors
            {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
        }
    }

    RowLayout
    {
        anchors.fill: parent

        Row
        {
            Layout.alignment: Qt.AlignLeft

            BabeButton
            {
                id: playlistView
                iconName: /*"headphones"*/ "media-optical-audio"
                iconColor: pageStack.wideMode || pageStack.currentIndex === 0 ? accentColor : textColor
                iconSize: size

                onClicked: playlistViewClicked()

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Playlist")
            }
        }

        Row
        {
            Layout.alignment: Qt.AlignCenter

            BabeButton
            {
                id: tracksView
                iconName: /*"musicnote"*/ "filename-filetype-amarok"
                iconColor:  accent && currentIndex === 0? accentColor : textColor
                iconSize: size
                onClicked: tracksViewClicked()

                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Tracks")
            }

            BabeButton
            {
                id: albumsView
                iconName: /*"album" */ "media-album-cover"
                iconColor:  accent && currentIndex === 1 ? accentColor : textColor
                iconSize: size
                onClicked: albumsViewClicked()

                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Albums")
            }

            BabeButton
            {
                id: artistsView

                iconName: /*"artist" */  "view-media-artist"
                iconColor:  accent && currentIndex === 2? accentColor : textColor
                iconSize: size

                onClicked: artistsViewClicked()
                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Artists")
            }

            BabeButton
            {
                id: playlistsView

                iconName: /*"library-music"*/ "view-media-playlist"
                iconColor:  accent && currentIndex === 3? accentColor : textColor
                iconSize: size

                onClicked: playlistsViewClicked()

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Playlists")
            }
        }

        Row
        {
            Layout.alignment: Qt.AlignRight

            BabeButton
            {
                id: settingsIcon

                iconName: /*"application-menu"*/"games-config-options"
                iconColor: settingsDrawer.visible ? accentColor : textColor
                iconSize: size

                onClicked: settingsViewClicked()

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Settings")
            }
        }
    }
}

