import QtQuick
import QtQuick.Controls
import QtQuick.Window

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

import org.maui.vvave as Vvave

import "../utils/Player.js" as Player

Maui.BaseWindow
{
    id: control

    minimumHeight: 200
    maximumHeight: 200

    minimumWidth: 200
    maximumWidth: 200

    height: 200
    width: 200

    x: Screen.width - width - 50
    y: Screen.height - height - 50

    flags: Qt.Widget | Qt.WindowStaysOnTopHint | Qt.FramelessWindowHint

    Maui.Theme.colorSet: Maui.Theme.Complementary
    Maui.Theme.inherit: false

    MouseArea
    {
        id: _mouseArea
        anchors.fill: parent

        onDoubleClicked: toggleMiniMode()
        hoverEnabled: true

        Image
        {
            anchors.fill: parent
            source: "image://artwork/album:"+currentTrack.artist + ":"+ currentTrack.album
            fillMode: Image.PreserveAspectFit
        }

        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: _mouseArea.containsMouse
        ToolTip.text:  root.title

        Control
        {
            Maui.Theme.colorSet: Maui.Theme.Complementary
            Maui.Theme.inherit: false

            anchors.fill: parent
            visible: _mouseArea.containsMouse
            background: Rectangle
            {
                color: "#000000"
                opacity: 0.7
            }

            Grid
            {
                Maui.Theme.colorSet: Maui.Theme.Complementary

                anchors.centerIn: parent
                columns: 2
                rows: 2
                rowSpacing: Maui.Style.space.medium
                columnSpacing: rowSpacing

                ToolButton
                {
                    Maui.Theme.colorSet: Maui.Theme.Complementary
                    Maui.Theme.inherit: false

                    icon.width: Maui.Style.iconSizes.big
                    icon.height: Maui.Style.iconSizes.big
                    icon.name: "love"
                    flat: true
                    enabled: root.currentTrack
                    checked: root.currentTrack.url ? FB.Tagging.isFav(root.currentTrack.url) : false
                    icon.color: checked ? babeColor :  Maui.Theme.textColor

                    onClicked:
                    {
                        mainPlaylist.listModel.list.fav(root.currentTrackIndex, !FB.Tagging.isFav(root.currentTrack.url))
                        root.currentTrackChanged()
                    }
                }

                ToolButton
                {
                    Maui.Theme.colorSet: Maui.Theme.Complementary
                    Maui.Theme.inherit: false
                    flat: true
                    icon.width: Maui.Style.iconSizes.big
                    icon.height: Maui.Style.iconSizes.big
                    enabled: root.currentTrackIndex >= 0
                    icon.color: Maui.Theme.textColor
                    icon.name: player.playing ? "media-playback-pause" : "media-playback-start"
                    onClicked: player.playing ? player.pause() : player.play()
                }

                ToolButton
                {
                    Maui.Theme.colorSet: Maui.Theme.Complementary
                    Maui.Theme.inherit: false
                    flat: true
                    icon.width: Maui.Style.iconSizes.big
                    icon.height: Maui.Style.iconSizes.big
                    icon.name: "media-skip-forward"
                    onClicked: Player.nextTrack()
                }

                ToolButton
                {
                    Maui.Theme.colorSet: Maui.Theme.Complementary
                    Maui.Theme.inherit: false

                    flat: true
                    icon.width: Maui.Style.iconSizes.big
                    icon.height: Maui.Style.iconSizes.big

                    icon.name: switch(playlist.playMode)
                               {
                               case Vvave.Playlist.Normal: return "media-playlist-normal"
                               case Vvave.Playlist.Shuffle: return "media-playlist-shuffle"
                               case Vvave.Playlist.Repeat: return "media-playlist-repeat"
                               }
                    onClicked:
                    {
                        switch(playlist.playMode)
                        {
                        case Vvave.Playlist.Normal:
                            playlist.playMode = Vvave.Playlist.Shuffle
                            break

                        case Vvave.Playlist.Shuffle:
                            playlist.playMode = Vvave.Playlist.Repeat
                            break


                        case Vvave.Playlist.Repeat:
                            playlist.playMode = Vvave.Playlist.Normal
                            break
                        }
                    }
                }
            }
        }

        DragHandler
        {
            grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfDifferentType | PointerHandler.ApprovesTakeOverByAnything
            onActiveChanged:
            {
                if (active)
                {
                    control.startSystemMove()
                }
            }
        }
    }
}
