import QtQuick.Controls 2.2
import QtQuick 2.9
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtGraphicalEffects 1.0

import "../../view_models/BabeGrid"
import "../../utils/Player.js" as Player

ListView
{
    id: albumsRollRoot
    orientation: ListView.Horizontal
    clip: true
    focus: true
    interactive: true
    currentIndex: currentTrackIndex
    highlightFollowsCurrentItem: true
    highlightMoveDuration: 0
    snapMode: ListView.SnapToOneItem
    model: mainPlaylist.listModel
    highlightRangeMode: ListView.StrictlyEnforceRange
    keyNavigationEnabled: true
    keyNavigationWraps : true
    onMovementEnded:
    {
        var index = indexAt(contentX, contentY)
        if(index !== currentTrackIndex)
            Player.playAt(index)

        //         positionViewAtIndex(index, ListView.Center)
    }

    //    onCurrentIndexChanged: Player.playAt(currentIndex)


    delegate: Maui.SwipeBrowserDelegate
    {
        isCurrentItem: false
        hoverEnabled: false
        width: albumsRollRoot.width
        height: albumsRollRoot.height
        label1.text: model.title
        label2.text: model.artist + " | " + model.album
        imageSource: model.artwork
        iconVisible : true
        label1.visible : albumsRollRoot.width > height
        label2.visible : label1.visible
    }

//    MouseArea
//    {
//        anchors.fill : parent
//        preventStealing: true
////        parent: applicationWindow().overlay.parent

//        onPressed:
//        {
//            console.log("albumsroll clicked")
//            mouse.accepted = false
//        }

//        onReleased:
//        {
//            mouse.accepted = true
//        }
//    }

    function positionAlbum(index)
    {
        albumsRollRoot.currentIndex = index
        positionViewAtIndex(index, ListView.Center)
    }
}
