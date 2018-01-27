import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "../../utils"

import "../../view_models"
import "../../db/Queries.js" as Q
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


    highlight: Rectangle
    {
        width: playlistListRoot.width
        height: playlistListRoot.currentItem.height
        color: bae.hightlightColor()
        y: playlistListRoot.currentItem.y
    }

    Rectangle
    {
        anchors.fill: parent
        color: bae.altColor()
        z: -999
    }


    AddPlaylistDialog
    {
        id:newPlaylistDialog
    }

    headerPositioning: ListView.OverlayHeader

    header: Rectangle
    {
        height: 48
        width: parent.width
        color: bae.midLightColor()
        z: 999

        RowLayout
        {
            anchors.fill: parent


            BabeButton
            {
                id: createPlaylistBtn
                Layout.fillHeight: true
                width: parent.height
                height: parent.height

                iconName: "list-add"
                onClicked: newPlaylistDialog.open()
            }


            BabeButton
            {
                id: removePlaylist
                Layout.fillHeight: true

                width: parent.height
                height: parent.height

                iconName: "list-remove"

                onClicked: appendAll()
            }

            Item
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            BabeButton
            {
                id: menuBtn
                Layout.fillHeight: true
                width: parent.height
                height: parent.height

                iconName: /*"application-menu" */"overflow-menu"
                onClicked: {}
            }

        }
    }

    BabeHolder
    {
        id: holder
        visible: playlistListRoot.count === 0
        message: "Select a playlist or create a new one"
    }

    ListModel
    {
        id: playlistListModel

        ListElement { playlist: qsTr("Most Played"); playlistIcon: "amarok_playcount"; /*query: Q.Query.mostPlayedTracks*/ }
        ListElement { playlist: qsTr("Favorites"); playlistIcon: "draw-star"}
        ListElement { playlist: qsTr("Recent"); playlistIcon: "filename-year-amarok"}
        ListElement { playlist: qsTr("Babes"); playlistIcon: "love"}
        ListElement { playlist: qsTr("Online"); playlistIcon: "internet-services"}
        ListElement { playlist: qsTr("Tags"); playlistIcon: "tag"}
        ListElement { playlist: qsTr("Relationships"); playlistIcon: "similarartists-amarok"}
        ListElement { playlist: qsTr("Popular"); playlistIcon: "office-chart-line"}
        ListElement { playlist: qsTr("Genres"); playlistIcon: "filename-track-amarok"}
    }

    model: playlistListModel
    delegate : PlaylistViewDelegate
    {
        id: delegate
        width: playlistListRoot.width

        Connections
        {
            target : delegate

            onClicked :
            {
                currentIndex = index
                var playlist = playlistListModel.get(index).playlist

                switch(playlist)
                {
                case "Most Played": playlistViewRoot.populate(Q.GET.mostPlayedTracks); break;
                case "Favorites": playlistViewRoot.populate(Q.GET.favoriteTracks); break;
                case "Recent": playlistViewRoot.populate(Q.GET.recentTracks); break;
                case "Babes": playlistViewRoot.populate(Q.GET.babedTracks); break;
                case "Online": playlistViewRoot.populate(Q.GET.favoriteTracks); break;
                case "Tags": playlistViewRoot.populate(Q.GET.favoriteTracks); break;
                case "Relationships": playlistViewRoot.populate(Q.GET.favoriteTracks); break;
                case "Popular": playlistViewRoot.populate(Q.GET.favoriteTracks); break;
                case "Genre": playlistViewRoot.populate(Q.GET.favoriteTracks); break;
                default: break
                }

                if(!playlistViewRoot.wideMode)
                    playlistViewRoot.currentIndex = 1

            }
        }
    }
}
