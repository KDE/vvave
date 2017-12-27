import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import "../view_models"
import "../utils/Icons.js" as MdiFont
import "../utils"

BabeGrid
{
    id:albumsView
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
                    id: albumTitle
                    width: parent.width - closeBtn
                    text: ""
                    elide: Text.ElideRight
                    font.pointSize: 12
                    font.bold: true
                    lineHeight: 0.7
                }


                ToolButton
                {
                    id: closeBtn
                    width: 64
                    height: 16
                    Icon
                    {
                        text: MdiFont.Icon.close
                    }

                    onClicked:
                    {
                        drawer.close()
                        console.log("close drawer")
                    }

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
        albumTitle.text = album
        drawer.open()
        console.log("haha: ", album, artist)
    }

}
