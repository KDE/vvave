import QtQuick 2.15
import QtQml 2.15

import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import QtGraphicalEffects 1.15

import org.mauikit.controls 1.3 as Maui

import org.maui.vvave 1.0

import "../../utils/Player.js" as Player
import "../../db/Queries.js" as Q

import "../BabeTable"

Maui.Page
{
    id: control

    Maui.Theme.colorSet: Maui.Theme.Window

    property alias listModel: table.listModel
    property alias listView : table.listView
    property alias table: table

    property alias contextMenu: table.contextMenu

    headBar.visible: false
    footBar.visible: !mainlistEmpty

    footBar.rightContent: ToolButton
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

    footBar.leftContent: ToolButton
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
            color: Maui.Theme.backgroundColor
            opacity: 0.2

            Behavior on color
            {
                Maui.ColorTransition{}
            }
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
        Maui.Theme.colorSet: Maui.Theme.Window

        holder.emoji: "qrc:/assets/view-media-track.svg"
        holder.title : "Nothing to play!"
        holder.body: i18n("Start putting together your playlist.")

        listView.header: Column
        {
            width: parent.width

            Loader
            {
                width: visible ? parent.width : 0
                height: width

                asynchronous: true
                active: !focusView && control.height > control.width*3 && currentTrackIndex >= 0
                visible: active
                sourceComponent: Item
                {
                    //                color: Maui.Theme.highlightColor
                    id: _imgHeader

                    Maui.GalleryRollTemplate
                    {
                        id: _image
                        anchors.fill: parent
                        anchors.bottomMargin: Maui.Style.space.medium
                        radius: Maui.Style.radiusV
                        interactive: true
                        fillMode: Image.PreserveAspectCrop

                        images: ["image://artwork/album:"+currentTrack.artist + ":"+ currentTrack.album, "image://artwork/artist:"+currentTrack.artist]

                    }
                }
            }

            Rectangle
            {
                visible: root.sync
                Maui.Theme.inherit: false
                Maui.Theme.colorSet:Maui.Theme.Complementary
                z: table.z + 999
                width: parent.width
                height: visible ?  Maui.Style.rowHeightAlt : 0
                color: Maui.Theme.backgroundColor

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
        }

        delegate: TableDelegate
        {
            id: delegate
            width: ListView.view.width
            height: Math.max(implicitHeight, Maui.Style.rowHeight)
            appendButton: false
            property int mindex : index
            isCurrentItem: ListView.isCurrentItem
            mouseArea.drag.axis: Drag.YAxis
            Drag.source: delegate

            number : false
            coverArt : settings.showArtwork
            draggable: true
            checkable: false
            checked: false

            onPressAndHold: if(Maui.Handy.isTouch && table.allowMenu) table.openItemMenu(index)

            onRightClicked: tryOpenContextMenu()

            function tryOpenContextMenu() : undefined
            {
                if (table.allowMenu)
                    table.openItemMenu(index)
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
                        playing: root.isPlaying && Maui.Style.enableEffects
                        anchors.centerIn: parent
                        source: "qrc:/assets/playing.gif"
                    }

                    ColorOverlay
                    {
                        anchors.fill: _playingIcon
                        source: _playingIcon
                        color: delegate.label1.color
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

                    Maui.Icon
                    {
                        color: delegate.label1.color
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
                    console.log("Move or insert ", drop.source.mindex)
                    if(typeof drop.source.mindex !== 'undefined')
                    {
                        console.log("Move ", drop.source.mindex,
                                    delegate.mindex)

                        root.playlistManager.move(drop.source.mindex, delegate.mindex)

                    }else
                    {
                        root.playlistManager.insert(String(drop.urls).split(","), delegate.mindex)
                    }

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
