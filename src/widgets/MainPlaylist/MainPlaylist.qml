import QtQuick
import QtQml

import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects

import org.mauikit.controls as Maui

import org.maui.vvave as Vvave

import "../../utils/Player.js" as Player
import "../../db/Queries.js" as Q

import "../BabeTable"

Maui.Page
{
    id: control

    Maui.Theme.colorSet: Maui.Theme.Window

    property alias listModel: table.listModel
    readonly property alias listView : table.listView
    readonly property alias table: table

    readonly property alias contextMenu: table.contextMenu

    headBar.visible: false


    BabeTable
    {
        id: table
        anchors.fill: parent
        footBar.visible: !mainlistEmpty
        footerMargins: Maui.Style.defaultPadding
        footBar.rightContent:[

            ToolButton
            {
                icon.name: "edit-delete"
                onClicked:
                {
                    player.stop()
                    listModel.list.clear()
                    root.sync = false
                    root.syncPlaylist = ""
                }
            },
            Loader
            {
                active: settings.sleepOption !== "none"
                visible: active
                sourceComponent: Label
                {
                    font.family: "Monospace"
                    text: "Zzz"
                    color: "white"
                    padding: Maui.Style.space.tiny

                    // icon.name: "clock"
                    background: Rectangle
                    {
                        color: "purple"
                        radius: 4
                    }
                }
            }]

        footBar.leftContent: [
            ToolButton
            {
                icon.name: "document-save"
                onClicked: saveList()
            },

            ToolButton
            {
                icon.name: switch(playlist.repeatMode)
                           {
                           case Vvave.Playlist.NoRepeat: return "media-repeat-none"
                           case Vvave.Playlist.RepeatOnce: return "media-playlist-repeat-song"
                           case Vvave.Playlist.Repeat: return "media-playlist-repeat"
                           }
                onClicked:
                {
                    switch(playlist.repeatMode)
                    {
                    case Vvave.Playlist.NoRepeat:
                        playlist.repeatMode = Vvave.Playlist.Repeat
                        break

                    case Vvave.Playlist.Repeat:
                        playlist.repeatMode = Vvave.Playlist.RepeatOnce
                        break

                    case Vvave.Playlist.RepeatOnce:
                        playlist.repeatMode = Vvave.Playlist.NoRepeat
                        break
                    }
                }
            },

            ToolButton
            {
                checked:  playlist.playMode === Vvave.Playlist.Shuffle
                icon.name: switch(playlist.playMode)
                           {
                           case Vvave.Playlist.Normal: return "media-playlist-normal"
                           case Vvave.Playlist.Shuffle: return "media-playlist-shuffle"
                           }

                onClicked:
                {
                    switch(playlist.playMode)
                    {
                    case Vvave.Playlist.Normal:
                        playlist.playMode = Vvave.Playlist.Shuffle
                        break

                    case Vvave.Playlist.Shuffle:
                        playlist.playMode = Vvave.Playlist.Normal
                        break
                    }
                }
            }]

        Binding on currentIndex
        {
            value: currentTrackIndex
            restoreMode: Binding.RestoreBindingOrValue
        }

        listModel.sort: ""
        listBrowser.enableLassoSelection: false
        headBar.visible: false
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
                visible: active && !mainlistEmpty
                sourceComponent: Item
                {
                    scale: _mouseArea.pressed ? 0.9 :  1

                    Behavior on scale
                    {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }

                    Maui.GalleryRollTemplate
                    {
                        anchors.fill: parent
                        anchors.bottomMargin: Maui.Style.space.medium
                        radius: Maui.Style.radiusV
                        interactive: true
                        fillMode: Image.PreserveAspectCrop

                        images: ["image://artwork/album:"+currentTrack.artist + ":"+ currentTrack.album, "image://artwork/artist:"+currentTrack.artist]
                    }

                    MouseArea
                    {
                        id:_mouseArea
                        anchors.fill: parent
                        onDoubleClicked: toggleMiniMode()
                        hoverEnabled: true

                        Rectangle
                        {
                            anchors.fill: parent
                            color: Maui.Theme.backgroundColor
                            visible: parent.containsMouse
                            opacity: parent.pressed ? 0.8 : 0.6
                        }

                        Maui.Icon
                        {
                            visible: parent.containsMouse

                            source: "window"
                            color: Maui.Theme.textColor
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.margins: Maui.Style.space.medium
                        }
                    }
                }

                OpacityAnimator on opacity
                {
                    from: 0
                    to: 1
                    duration: Maui.Style.units.longDuration
                    running: parent.status === Loader.Ready
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

            function tryOpenContextMenu()
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
                        visible: GraphicsInfo.api === GraphicsInfo.Software
                    }

                    MultiEffect
                    {
                        anchors.fill: _playingIcon
                        source: _playingIcon
                        colorization: 1.0
                        contrast: 1.0
                        colorizationColor: "#fafafa"
                        visible: GraphicsInfo.api !== GraphicsInfo.Software
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

                onContentDropped: (drop) =>
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
            let trackList = listModel.list.urls()
            if(listModel.list.count > 0)
            {
                tagUrls(trackList)
            }
        }
    }
