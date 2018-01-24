import QtQuick 2.9
import "../view_models"

ListView
{
    id: playlistListRoot

    clip: true

    focus: true
    interactive: true
    highlightFollowsCurrentItem: false
    keyNavigationWraps: !isMobile
    keyNavigationEnabled : !isMobile

    Keys.onUpPressed: decrementCurrentIndex()
    Keys.onDownPressed: incrementCurrentIndex()
    Keys.onReturnPressed: rowClicked(currentIndex)

    boundsBehavior: isMobile? Flickable.StopAtBounds : Flickable.DragAndOvershootBounds
    flickableDirection: Flickable.AutoFlickDirection

    snapMode: ListView.SnapToItem

    addDisplaced: Transition
    {
        NumberAnimation { properties: "x,y"; duration: 1000 }
    }

    BabeHolder
    {
        id: holder
        visible: playlistListRoot.count === 0
    }


}
