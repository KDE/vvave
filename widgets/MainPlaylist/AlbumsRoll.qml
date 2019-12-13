import QtQuick.Controls 2.10
import QtQuick 2.10
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtGraphicalEffects 1.0

import "../../view_models/BabeGrid"
import "../../utils/Player.js" as Player


Maui.ToolBar
{
    id: control
    visible: !mainlistEmpty
    padding: 0
    background: Item
    {
        Image
        {
            id: artworkBg
            height: parent.height
            width: parent.width

            sourceSize.width: parent.width
            sourceSize.height: parent.height

            fillMode: Image.PreserveAspectCrop
            antialiasing: true
            smooth: true
            asynchronous: true
            cache: true

            source: currentArtwork
        }

        FastBlur
        {
            id: fastBlur
            anchors.fill: parent
            source: artworkBg
            radius: 100
            transparentBorder: false
            cached: true

            Rectangle
            {
                anchors.fill: parent
                color: Kirigami.Theme.backgroundColor
                opacity: 0.8
            }
        }

        Kirigami.Separator
        {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
        }
    }

    rightContent: [
        ToolButton
        {
            icon.name: "edit-delete"
            onClicked:
            {
                player.stop()
                mainPlaylist.table.list.clear()
                root.sync = false
                root.syncPlaylist = ""
            }
        }
    ]

    leftContent:  ToolButton
    {
        icon.name: "document-save"
        onClicked: mainPlaylist.table.saveList()
    }

    middleContent: ListView
    {
        id: _listView
        Layout.fillWidth: true
        Layout.preferredHeight: Maui.Style.toolBarHeight
        orientation: ListView.Horizontal
        clip: true
        focus: true
        interactive: true
        currentIndex: currentTrackIndex
        spacing: Maui.Style.space.medium
        //        cacheBuffer: control.width * 1
        onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Center)

        highlightFollowsCurrentItem: true
        highlightMoveDuration: 0
        snapMode: ListView.SnapToOneItem
        model: mainPlaylist.listModel
        highlightRangeMode: ListView.StrictlyEnforceRange
        keyNavigationEnabled: true
        keyNavigationWraps : true
        onCurrentItemChanged:
        {
            const index = indexAt(contentX, contentY)
            if(index !== currentTrackIndex)
                Player.playAt(index)
        }

        delegate: Maui.ItemDelegate
        {
            id: _delegate
            height: _listView.height
            width: _listView.width
            padding: 0

            Kirigami.Theme.inherit: true

            Maui.ListItemTemplate
            {
                anchors.fill: parent
                iconSizeHint: height - Maui.Style.space.small
                iconVisible: false
                imageSource: model.artwork ? model.artwork : "qrc:/assets/cover.png"
                label1.text: model.title
                label2.text: model.artist + " | " + model.album
            }

            onClicked: focusView = true
            background: null
        }
    }
}


