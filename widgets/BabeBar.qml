import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami

import "../utils"
import "../view_models"

ToolBar
{
    property alias babeBar : babeBar
    property string accentColor : babeColor
    property string textColor : foregroundColor
    property string bgColor : babeAltColor
    property int currentIndex : 0
    property bool accent : pageStack.wideMode || (!pageStack.wideMode && pageStack.currentIndex === 1)

    signal tracksViewClicked()
    signal albumsViewClicked()
    signal artistsViewClicked()
    signal playlistsViewClicked()
    signal babeViewClicked()
    //    signal playlistViewClicked()
    signal searchViewClicked()
    signal settingsViewClicked()

    width: parent.width
    id: babeBar

    Rectangle
    {
        anchors.fill: parent
        color: bgColor

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

        BabeButton
        {
            iconName: "love"
            iconColor: accent && currentIndex === viewsIndex.babeit ? accentColor : textColor

            onClicked: babeViewClicked()

            hoverEnabled: !isMobile
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered && !isMobile
            ToolTip.text: qsTr("Babe")
        }

        Item
        {
            Layout.fillWidth: true
        }

        BabeButton
        {
            id: tracksView

            iconName: /*"musicnote"*/ "filename-filetype-amarok"
            iconColor:  accent && currentIndex === viewsIndex.tracks ? accentColor : textColor
            onClicked: tracksViewClicked()

            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered && !isMobile
            ToolTip.text: qsTr("Tracks")
        }

        BabeButton
        {
            id: albumsView

            iconName: /*"album" */ "media-album-cover"
            iconColor:  accent && currentIndex === viewsIndex.albums ? accentColor : textColor
            onClicked: albumsViewClicked()

            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered && !isMobile
            ToolTip.text: qsTr("Albums")
        }

        BabeButton
        {
            id: artistsView

            iconName: /*"artist" */  "view-media-artist"
            iconColor:  accent && currentIndex === viewsIndex.artists ? accentColor : textColor

            onClicked: artistsViewClicked()
            hoverEnabled: true
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered && !isMobile
            ToolTip.text: qsTr("Artists")
        }

        BabeButton
        {
            id: playlistsView

            iconName: /*"library-music"*/ "view-media-playlist"
            iconColor:  accent && currentIndex === viewsIndex.playlists ? accentColor : textColor

            onClicked: playlistsViewClicked()

            hoverEnabled: !isMobile
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered && !isMobile
            ToolTip.text: qsTr("Playlists")
        }

        Item
        {
            Layout.fillWidth: true
        }
        BabeButton
        {
            id: searchView
            //                visible: !(searchInput.focus || searchInput.text)
            iconColor: accent && currentIndex === viewsIndex.search ? accentColor : textColor
            iconName: "edit-find" //"search"
            onClicked: searchViewClicked()
            hoverEnabled: !isMobile
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered && !isMobile
            ToolTip.text: qsTr("Search")
        }

    }
}

