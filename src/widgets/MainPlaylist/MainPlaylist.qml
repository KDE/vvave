import QtQuick 2.14
import QtQml 2.14

import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14

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

        anchors.fill: parent
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

        delegate: Rectangle
        {
            id: delegateRoot
            width: ListView.view.width
            height: delegate.implicitHeight
            property int mindex : index

            Drag.active: dragArea.held
            Drag.source: delegateRoot
            Drag.hotSpot.x: width / 2
            Drag.hotSpot.y: height / 2
            Drag.dragType: Drag.Automatic
//            Drag.supportedActions: Qt.MoveAction

            radius: delegate.radius
            color: Drag.active ? Kirigami.Theme.hoverColor : "transparent"

            TableDelegate
            {
                id: delegate
                isCurrentItem: parent.ListView.isCurrentItem
               anchors.fill: parent

                number : false
                coverArt : true
                draggable: false
                checkable: false
                checked: false

                onPressAndHold: if(Maui.Handy.isTouch && table.allowMenu) table.openItemMenu(index)

                onRightClicked:
                {
                    if(table.allowMenu) table.openItemMenu(index)
                }

                sameAlbum: control.totalMoves, evaluate(listModel.get(mindex-1))

                function evaluate(item) {
                    return coverArt && item && item.album === model.album && item.artist === model.artist
                }

                AbstractButton
                {
                    Layout.fillHeight: true
                    Layout.preferredWidth: Maui.Style.rowHeight
                    visible: (Maui.Handy.isTouch ? true : delegate.hovered)
                    icon.name: "edit-clear"
                    onClicked:
                    {
                        if(index === currentTrackIndex)
                            player.stop()

                        listModel.list.remove(index)
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

                Item
                {
                    implicitHeight: implicitWidth
                    implicitWidth: 32

                    Kirigami.Icon
                    {
                        source: "handle-left"
                        height: 22
                        width : height
                        anchors.centerIn: parent
                    }

                    MouseArea
                    {
                        id: dragArea
                        anchors.fill: parent
                        property bool held: false

                        drag.target: held ? delegateRoot : undefined
                        drag.axis: Drag.YAxis
                        drag.smoothed: false
                        preventStealing: true
                        onPressAndHold: held = true
                        onReleased:
                        {
                            held = false
                        }
                    }
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
            }


            DropArea
            {
                id: _dropArea
                anchors { fill: parent;  }

                onEntered:  {
                    console.log("Move ", drag.source.mindex,
                                delegateRoot.mindex)
                    table.list.move(
                                drag.source.mindex,
                                delegateRoot.mindex)
                    control.totalMoves++
                }
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
