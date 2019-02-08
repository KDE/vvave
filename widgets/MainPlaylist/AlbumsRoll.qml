import QtQuick.Controls 2.2
import QtQuick 2.9
import "../../view_models/BabeGrid"
import org.kde.kirigami 2.0 as Kirigami
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
    snapMode:ListView.SnapToOneItem
    model:  mainPlaylist.listModel

    onMovementEnded:
    {
        var index = indexAt(contentX, contentY)
        if(index !== currentTrackIndex)
            Player.playAt(index)

//         positionViewAtIndex(index, ListView.Center)
    }

    delegate: BabeAlbum
    {
        id: delegate
        itemHeight: albumsRollRoot.height
        itemWidth: albumsRollRoot.width
        albumSize : itemHeight *0.8
        albumRadius : radiusV
        showLabels: false
        showIndicator: false
        hideRepeated: false
        anchors.verticalCenter: parent.verticalCenter
        //        increaseCurrentItem : true

        Connections
        {
            target: delegate
            onClicked:
            {
                albumsRollRoot.currentIndex = index
                play(index)
            }
        }
    }

    function positionAlbum(index)
    {
        albumsRollRoot.currentIndex = index
        positionViewAtIndex(index, ListView.Center)
    }
}
