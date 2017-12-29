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

    Column
    {
        id: mainView
        anchors.fill: parent

        SwipeView
        {
            id: swipeView
            width:parent.width
            height: parent.height - searchInput.height

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

        Rectangle
        {
            width: parent.width
            height: 32
            color: "white"

            TextInput
            {
                id: searchInput
                anchors.fill: parent
                anchors.centerIn: parent

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:  Text.AlignVCenter

                property string placeholderText: "Search..."

                Label
                {
                    anchors.fill: parent
                    text: searchInput.placeholderText
                    visible: !searchInput.focus || !searchInput.text
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    font.bold: true


                }

            }
        }


    }


}
