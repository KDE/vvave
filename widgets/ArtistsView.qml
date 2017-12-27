import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../view_models"

BabeGrid
{
    id:artistsView
    visible: true
    albumSize: 120
    borderRadius: 20


    Drawer
    {
        id: drawer
        height: parent.height * 0.4
        width: parent.width
        edge: Qt.BottomEdge
        interactive: false

        ColumnLayout
        {
            width: parent.width
            height: parent.height
            Row
            {

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 20

                Label
                {
                    id: artistTitle
                    width: parent.width
                    text: ""
                    elide: Text.ElideRight
                    font.pointSize: 12
                    font.bold: true
                    lineHeight: 0.7
                }

            }
            Row
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                BabeTable
                {
                    id: drawerList
                    width: parent.width
                }
            }
        }
    }

    onAlbumCoverClicked:
    {
        artistTitle.text = artist
        drawer.open()
        console.log("haha: ", album, artist)
    }

}
