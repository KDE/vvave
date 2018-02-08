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
            id: settingsView
            iconName: /*"headphones"*/ /*"media-optical-audio"*/ "application-menu"
            iconColor: settingsDrawer.visible ? babeColor : textColor/*(pageStack.wideMode || pageStack.currentIndex === 0 ) && !isMobile ? accentColor : textColor*/
            onClicked: settingsViewClicked()/*playlistViewClicked()*/

            hoverEnabled: !isMobile
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered && !isMobile
            ToolTip.text: qsTr("Settings")
        }

        Item
        {
            Layout.fillWidth: true
        }

        BabeButton
        {
            id: tracksView

            iconName: /*"musicnote"*/ "filename-filetype-amarok"
            iconColor:  accent && currentIndex === 0? accentColor : textColor
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
            iconColor:  accent && currentIndex === 1 ? accentColor : textColor
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
            iconColor:  accent && currentIndex === 2? accentColor : textColor

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
            iconColor:  accent && currentIndex === 3? accentColor : textColor

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
            iconColor: accent && currentIndex === 5? accentColor : textColor
            //                visible: !(searchInput.focus || searchInput.text)
            iconName: "edit-find" //"search"
            onClicked: searchViewClicked()
            hoverEnabled: !isMobile
            ToolTip.delay: 1000
            ToolTip.timeout: 5000
            ToolTip.visible: hovered && !isMobile
            ToolTip.text: qsTr("Search")
        }


        //        BabeButton
        //        {
        //            iconName: "love"
        //            iconColor: accent && currentIndex === 4? accentColor : textColor

        //            onClicked: babeViewClicked()

        //            hoverEnabled: !isMobile
        //            ToolTip.delay: 1000
        //            ToolTip.timeout: 5000
        //            ToolTip.visible: hovered && !isMobile
        //            ToolTip.text: qsTr("Babe")
        //        }




    }
}

