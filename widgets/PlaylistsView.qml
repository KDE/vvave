import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

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

    Rectangle
    {
        anchors.fill: parent
        color: bae.altColor()
        z: -999
    }


    footerPositioning: ListView.OverlayFooter

    footer: ColorTagsBar
    {
        width: parent.width
        height: 48
        recSize: 22
//        onColorClicked: moodIt(color)
    }

    BabeHolder
    {
        id: holder
        visible: playlistListRoot.count === 0
    }

    ListModel
    {
        id: playlistListModel

        ListElement { playlist: qsTr("Most Played"); playlistIcon: "trendingUp"}
        ListElement { playlist: qsTr("Favorites"); playlistIcon: "starCircle"}
        ListElement { playlist: qsTr("Recent"); playlistIcon: "clock"}
        ListElement { playlist: qsTr("Babes"); playlistIcon: "heart"}
        ListElement { playlist: qsTr("Online"); playlistIcon: "youtubePlay"}
        ListElement { playlist: qsTr("Tags"); playlistIcon: "tagMultiple"}
        ListElement { playlist: qsTr("Rleationships"); playlistIcon: "tagFaces"}
        ListElement { playlist: qsTr("Popular"); playlistIcon: "fire"}
        ListElement { playlist: qsTr("Genres"); playlistIcon: "attachment"}
    }

    model: playlistListModel
    delegate : PlaylistViewDelegate
    {
        id: delegate
        width: playlistListRoot.width
    }
}
