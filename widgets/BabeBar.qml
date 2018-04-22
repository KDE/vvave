import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami
import Qt.labs.handlers 1.0

import "../utils"
import "../view_models"

ToolBar
{
    position: ToolBar.Header

    property alias babeBar : babeBar
    property string accentColor : babeColor
    property string textColor : textColor
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


    id: babeBar

    TapHandler
    {
        onTapped: if (tapCount === 2) toggleMaximized()
        gesturePolicy: TapHandler.DragThreshold
    }

    DragHandler
    {
        grabPermissions: TapHandler.CanTakeOverFromAnything
        onGrabChanged:
        {
            if (active)
            {
                var position = parent.mapToItem(root.contentItem, point.position.x, point.position.y)
                root.startSystemMove(position);
            }
        }
    }


    RowLayout
    {
        anchors.fill: parent

        Item
        {
            Layout.alignment: Qt.AlignLeft
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: toolBarIconSize*2
            Layout.maximumHeight: toolBarIconSize

            BabeButton
            {
                id: settingsView

                anchors.centerIn: parent
                anchors.left: parent.left
                iconName: "application-menu"
                iconColor: settingsDrawer.visible ? babeColor : textColor/*(pageStack.wideMode || pageStack.currentIndex === 0 ) && !isMobile ? accentColor : textColor*/
                onClicked: settingsViewClicked()

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered && !isMobile
                ToolTip.text: qsTr("Settings")
            }
        }

        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0
        }

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: tracksView.implicitWidth * 1.3
            Layout.maximumHeight: toolBarIconSize

            BabeButton
            {
                id: tracksView
                anchors.centerIn: parent

                iconName: "view-media-track"
                iconColor:  accent && currentIndex === viewsIndex.tracks ? accentColor : textColor
                onClicked: tracksViewClicked()
                text: qsTr("Tracks")
                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered && !isMobile
                ToolTip.text: qsTr("Tracks")
            }
        }

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: albumsView.implicitWidth * 1.3
            Layout.maximumHeight: toolBarIconSize

            BabeButton
            {
                id: albumsView
                anchors.centerIn: parent
                text: qsTr("Albums")
                iconName: /*"album"*/ "view-media-album-cover"
                iconColor:  accent && currentIndex === viewsIndex.albums ? accentColor : textColor
                onClicked: albumsViewClicked()

                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered && !isMobile
                ToolTip.text: qsTr("Albums")
            }
        }

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: artistsView.implicitWidth * 1.3
            Layout.maximumHeight: toolBarIconSize

            BabeButton
            {
                id: artistsView
                anchors.centerIn: parent
                text: qsTr("Artists")
                iconName: "view-media-artist"
                iconColor:  accent && currentIndex === viewsIndex.artists ? accentColor : textColor

                onClicked: artistsViewClicked()
                hoverEnabled: true
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered && !isMobile
                ToolTip.text: qsTr("Artists")
            }
        }

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: playlistsView.implicitWidth * 1.3
            Layout.maximumHeight: toolBarIconSize

            BabeButton
            {
                id: playlistsView
                anchors.centerIn: parent
                text: qsTr("Playlists")
                iconName: "view-media-playlist"
                iconColor:  accent && currentIndex === viewsIndex.playlists ? accentColor : textColor

                onClicked: playlistsViewClicked()

                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered && !isMobile
                ToolTip.text: qsTr("Playlists")
            }
        }

        //        Item
        //        {
        //            Layout.fillHeight: true
        //            Layout.fillWidth: true
        //            Layout.maximumWidth: toolBarIconSize*2
        //            Layout.maximumHeight: toolBarIconSize

        //            BabeButton
        //            {
        //                anchors.centerIn: parent

        //                iconName: "love"
        //                iconColor: accent && currentIndex === viewsIndex.babeit ? accentColor : textColor

        //                onClicked: babeViewClicked()

        //                hoverEnabled: !isMobile
        //                ToolTip.delay: 1000
        //                ToolTip.timeout: 5000
        //                ToolTip.visible: hovered && !isMobile
        //                ToolTip.text: qsTr("Babe")
        //            }
        //        }


        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 0

        }

        Item
        {
            Layout.alignment: Qt.AlignRight
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: toolBarIconSize*2
            Layout.maximumHeight: toolBarIconSize

            BabeButton
            {
                id: searchView
                anchors.centerIn: parent
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


        Item
        {
            Layout.alignment: Qt.AlignRight
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: toolBarIconSize*2
            Layout.maximumHeight: toolBarIconSize

            BabeButton
            {
                id: closeBtn
                anchors.centerIn: parent
                //                visible: !(searchInput.focus || searchInput.text)
                iconColor: down ? accentColor : textColor
                iconName: "window-close" //"search"
                onClicked: root.close()
                hoverEnabled: !isMobile
                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered && !isMobile
                ToolTip.text: qsTr("Close")
            }
        }
    }

}

