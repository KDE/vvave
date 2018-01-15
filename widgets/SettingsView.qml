import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "../utils/Icons.js" as MdiFont
import "../utils"

Pane
{
    id: settingsView

    signal iconSizeChanged(int size)


    FolderDialog
    {
        id: folderDialog

        folder: StandardPaths.standardLocations(StandardPaths.MusicLocation)[0]
        onAccepted:
        {
            listModel.append({url: folder.toString()})
            babe.scanDir(folder.toString())
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
            clip: true

            visible : !bae.isMobile()


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
                        text: url
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        font.pointSize: 10
                    }
                }
            }


            Component.onCompleted:
            {
                var map = bae.get("select url from sources")
                for(var i in map)
                {
                    model.append(map[i])
                }
            }
        }

        Row
        {
            id: sourceActions
            anchors.top: sources.bottom
            width: parent.width
            visible : !bae.isMobile()

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

        Row
        {
            anchors.top: sourceActions.bottom
            width: parent.width
            height: iconSize.height

            Label
            {
                width: parent.width - iconSize.width
                height: parent.height

                text: "Toolbar icon size"
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            ComboBox
            {
                id: iconSize
                width: 100
                model: ListModel
                {
                    id: sizes
                    ListElement { size: 16 }
                    ListElement { size: 24 }
                    ListElement { size: 32 }
                }

                currentIndex:  1
                onCurrentIndexChanged: iconSizeChanged(sizes.get(currentIndex).size )
            }
        }
    }
}
