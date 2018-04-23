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
    spacing: space.huge
    focus: true
    interactive: true
    currentIndex: currentTrackIndex
    highlightFollowsCurrentItem: true
    highlightMoveDuration: 0
    //    snapMode: ListView.SnapToItem

    model : ListModel{}

    delegate: BabeAlbum
    {
        id: delegate
        height: coverSize
        width: coverSize
        albumSize : coverSize
        albumRadius : 0
        showLabels: false
        showIndicator: true
        anchors.verticalCenter: parent.verticalCenter

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
