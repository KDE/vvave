import QtQuick 2.14
import QtQml 2.14

import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
 import QtGraphicalEffects 1.15

import org.kde.kirigami 2.8 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.vvave 1.0

import "../../utils/Player.js" as Player
import "../../db/Queries.js" as Q

import "../BabeTable"

Maui.Page
{
    id: control
    flickable: table.flickable
    title: i18n("Playlist")
    showTitle: true

    Kirigami.Theme.colorSet: Kirigami.Theme.Window

    property alias listModel: table.listModel
    property alias listView : table.listView
    property alias table: table

    property alias contextMenu: table.contextMenu

    background: Rectangle
    {
        color: Kirigami.Theme.backgroundColor
        opacity: 0.2
    }

    headBar.background: null
    headBar.visible: !mainlistEmpty

    headBar.rightContent: ToolButton
    {
        icon.name: "edit-delete"
        onClicked:
        {
            player.stop()
            listModel.list.clear()
            root.sync = false
            root.syncPlaylist = ""
        }
    }

    headBar.leftContent: ToolButton
    {
        icon.name: "document-save"
        onClicked: saveList()
    }

    BabeTable
    {
        id: table
        anchors.fill: parent

        background: Rectangle
        {
            color: Kirigami.Theme.backgroundColor
            opacity: 0.2
        }

        Binding on currentIndex
        {
            value: currentTrackIndex
            restoreMode: Binding.RestoreBindingOrValue
        }

        listModel.sort: ""
        listBrowser.enableLassoSelection: false
        headBar.visible: false
        footBar.visible: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Window

        holder.emoji: "qrc:/assets/view-media-track.svg"
        holder.title : "Nothing to play!"
        holder.body: i18n("Start putting together your playlist.")

        listView.header: Rectangle
        {
            visible: root.sync
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet:Kirigami.Theme.Complementary
            z: table.z + 999
            width: table.width
            height: visible ?  Maui.Style.rowHeightAlt : 0
            color: Kirigami.Theme.backgroundColor

            RowLayout
            {
                anchors.fill: parent
                anchors.leftMargin: Maui.Style.space.small
                Label
                {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    anchors.margins: Maui.Style.space.small
                    text: i18n("Syncing to ") + root.syncPlaylist
                }

                ToolButton
                {
                    Layout.fillHeight: true
                    icon.name: "dialog-close"
                    onClicked:
                    {
                        root.sync = false
                        root.syncPlaylist = ""
                    }
                }
            }
        }

        delegate: TableDelegate
        {
            id: delegate
            width: ListView.view.width
            height: Math.max(implicitHeight, Maui.Style.rowHeight)

            property int mindex : index
            isCurrentItem: ListView.isCurrentItem
            mouseArea.drag.axis: Drag.YAxis
            Drag.source: delegate

            number : false
            coverArt : true
            draggable: true
            checkable: false
            checked: false

            onPressAndHold: if(Maui.Handy.isTouch && table.allowMenu) table.openItemMenu(index)

            onRightClicked:
            {
                if(table.allowMenu)
                {
                    table.openItemMenu(index)
                }
            }

            sameAlbum: control.totalMoves, evaluate(listModel.get(mindex-1))

            function evaluate(item)
            {
                return coverArt && item && item.album === model.album && item.artist === model.artist
            }

                Item
                {
                    visible: mindex === currentTrackIndex
                    Layout.fillHeight: true
                    Layout.preferredWidth: Maui.Style.rowHeight

                    AnimatedImage
                    {
                        id: _playingIcon
                        height: 16
                        width: height
                        playing: root.isPlaying
                        anchors.centerIn: parent
                        source: "qrc:/assets/playing.gif"
                    }

                    ColorOverlay
                    {
                        anchors.fill: _playingIcon
                        source: _playingIcon
                        color: Kirigami.Theme.textColor
                    }
                }

                AbstractButton
                {
                    Layout.fillHeight: true
                    Layout.preferredWidth: Maui.Style.rowHeight
                    visible: (Maui.Handy.isTouch ? true : delegate.hovered) && index !== currentTrackIndex
                    icon.name: "edit-clear"
                    onClicked:
                    {
                        if(index === currentTrackIndex)
                            player.stop()

                        root.playlistManager.remove(index)
                    }

                    Kirigami.Icon
                    {
                        anchors.centerIn: parent
                        height: Maui.Style.iconSizes.small
                        width: height
                        source: parent.icon.name
                    }
                    opacity: delegate.hovered ? 0.8 : 0.6
                }

                onClicked:
                {
                    table.forceActiveFocus()
                    if(Maui.Handy.isTouch)
                        Player.playAt(index)
                }

                onDoubleClicked:
                {
                    if(!Maui.Handy.isTouch)
                        Player.playAt(index)
                }


                onContentDropped:
                {
                    console.log("Move ", drop.source.mindex,
                                delegate.mindex)

                    root.playlistManager.move(drop.source.mindex, delegate.mindex)

                    control.totalMoves++
                }
            }
        }

        property int totalMoves: 0

        function saveList()
        {
            var trackList = listModel.list.urls()
            if(listModel.list.count > 0)
            {
                _dialogLoader.sourceComponent = _playlistDialogComponent
                dialog.composerList.urls = trackList
                dialog.open()
            }
        }
    }
