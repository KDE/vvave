import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "../utils/Icons.js" as MdiFont
import "../utils"


Pane
{
    id: settingsView

    FolderDialog
    {
        id: folderDialog
        folder: StandardPaths.standardLocations(StandardPaths.MusicLocation)[0]
        onAccepted:
        {
            listModel.append({source: folder.toString()})
        }
    }


    Rectangle
    {
        anchors.centerIn: parent

        width: parent.width /2
        height: parent.height/2
        border.color: "#dedede"
        radius: 4

        Label
        {
            anchors.bottom: sources.top
            text: "Sources"
        }

        ListView
        {
            id: sources
            anchors.fill: parent
            width: parent.width
            height: parent.height

            ListModel
            {
                id: listModel
            }

            model: listModel

            delegate: ItemDelegate
            {
                width: parent.width

                contentItem: ColumnLayout
                {
                    spacing: 2
                    width: parent.width

                    Label
                    {
                        id: sourceUrl
                        width: parent.width
                        text: source
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        font.pointSize: 10
                    }
                }
            }


        }

        Row
        {
            anchors.top: sources.bottom
            width: parent.width

            ToolButton
            {
                id: addSource
                Icon
                {
                    text: MdiFont.Icon.plus
                }

                onClicked:
                {
                    folderDialog.open()
                }
            }

            ToolButton
            {
                id: removeSource
                Icon
                {
                    id: albumsIcon
                    text: MdiFont.Icon.minus
                }

                onClicked:
                {

                }

            }
        }

    }
}
