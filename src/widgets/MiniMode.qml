import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Window 2.15

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.vvave 1.0 as Vvave

import "../utils/Player.js" as Player
import org.kde.kirigami 2.14 as Kirigami

MouseArea
{
    id: control

    onDoubleClicked: toggleMiniMode()
    hoverEnabled: true

    Image
    {
        anchors.fill: parent
        source: "image://artwork/album:"+currentTrack.artist + ":"+ currentTrack.album
        fillMode: Image.PreserveAspectFit
    }

    Control
    {
        anchors.fill: parent
        visible: control.containsMouse
        background: Rectangle
        {
            color: "#000000"
            opacity: 0.7
        }

        Grid
        {
            anchors.centerIn: parent
            columns: 2
            rows: 2
            rowSpacing: Maui.Style.space.medium
            columnSpacing: rowSpacing

            ToolButton
            {
                id: babeBtnIcon
                icon.width: Maui.Style.iconSizes.big
                icon.height: Maui.Style.iconSizes.big
                icon.name: "love"
                flat: true
                enabled: root.currentTrack
                checked: root.currentTrack.url ? FB.Tagging.isFav(root.currentTrack.url) : false
                icon.color: checked ? babeColor :  Kirigami.Theme.textColor

                onClicked:
                {
                    mainPlaylist.listModel.list.fav(root.currentTrackIndex, !FB.Tagging.isFav(root.currentTrack.url))
                    root.currentTrackChanged()
                }
            }

            ToolButton
            {
                id: playIcon
                flat: true
                icon.width: Maui.Style.iconSizes.big
                icon.height: Maui.Style.iconSizes.big
                enabled: root.currentTrackIndex >= 0
                icon.color: Kirigami.Theme.textColor
                icon.name: player.playing ? "media-playback-pause" : "media-playback-start"
                onClicked: player.playing ? player.pause() : player.play()
            }

            ToolButton
            {
                id: nextBtn
                flat: true
                icon.width: Maui.Style.iconSizes.big
                icon.height: Maui.Style.iconSizes.big
                icon.name: "media-skip-forward"
                onClicked: Player.nextTrack()
            }

            ToolButton
            {
                id: shuffleBtn
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
        id: _dragHandler
        acceptedDevices: PointerDevice.GenericPointer
        grabPermissions:  PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfDifferentType | PointerHandler.ApprovesTakeOverByAnything
        onActiveChanged: if (active) { root.startSystemMove(); }
    }
}
