import QtQuick 2.9
import QtQuick.Controls 2.2
import QtLocation 5.9
import QtQuick.Layouts 1.3
import "view_models"
import "widgets"

ApplicationWindow
{
    visible: true
    width: 400
    height: 500
    title: qsTr("Babe")

    header: BabeBar
    {
        id: mainToolbar
        visible: true

        currentIndex: swipeView.currentIndex

        onTracksViewClicked: swipeView.currentIndex = 1
        onAlbumsViewClicked: swipeView.currentIndex = 2
        onArtistsViewClicked: swipeView.currentIndex = 3
        onPlaylistsViewClicked: swipeView.currentIndex = 4
        onInfoViewClicked: swipeView.currentIndex = 0
    }

    SwipeView
    {
        id: swipeView
        anchors.fill: parent
        currentIndex: 1

        Pane
        {
            width: swipeView.width
            height: swipeView.height

            Column
            {
                spacing: 40
                width: parent.width

                Label
                {
                    width: parent.width
                    wrapMode: Label.Wrap
                    horizontalAlignment: Qt.AlignHCenter
                    text: "info view"
                }
            }
        }

        TracksView
        {

        }

        AlbumsView
        {

        }

        ArtistsView
        {

        }
    }
}
