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
    snapMode: ListView.SnapOneItem
    cacheBuffer: width
    model : ListModel{}

    onMovementEnded:
    {
        var index = indexAt(contentX, contentY)
        if(index !== currentTrackIndex)
            Player.playAt(index)
    }

    delegate: BabeAlbum
    {
        id: delegate
        itemHeight: coverSize
        itemWidth: albumsRollRoot.width
        albumSize : coverSize
        albumRadius : 0
        showLabels: false
        showIndicator: true
        hideRepeated: true
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

    function append(album)
    {
        model.insert(count, album)
    }

    function positionAlbum(index)
    {
        albumsRollRoot.currentIndex = index
        positionViewAtIndex(index, ListView.Center)
    }
}
