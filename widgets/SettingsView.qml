import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "../utils/Icons.js" as MdiFont
import "../utils"

Drawer
{
    id: settingsView
    y: header.height
    height: parent.height - header.height
    width: bae.isMobile() ? parent.width* 0.7 : parent.width* 0.5
    edge: Qt.RightEdge
    interactive: true
    focus: true
    modal:true

    signal iconSizeChanged(int size)

    function load(folderUrl)
    {
        folderPicker.dirList.clearTable()
        var dirs = bae.getDirs(folderUrl)
        for(var path in dirs)
        {
            folderPicker.dirList.model.append(dirs[path])
        }
    }

    function scanDir(folderUrl)
    {
        bae.scanDir(folderUrl)
    }

    background: Rectangle
    {
        anchors.fill: parent
        color: bae.backgroundColor()
        z: -999
    }

    FolderDialog
    {
        id: folderDialog

        folder: bae.homeDir()
        onAccepted:
        {
            var path = folder.toString().replace("file://","")

            listModel.append({url: path})
            scanDir(path)
        }
    }
    FolderPicker
    {

        id: folderPicker
        Connections
        {
            target: folderPicker
            onPathClicked: load(path)

            onAccepted:
            {
                listModel.append({url: path})
                scanDir(path)
            }
            onGoBack: load(path)

        }
    }

    Rectangle
    {
        id: content
        anchors.fill: parent
        color: bae.midColor()
        ColumnLayout
        {
            width: settingsView.width
            height: settingsView.height


            ListView
            {
                id: sources
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                Rectangle
                {
                    anchors.fill: parent
                    z: -999
                    color: bae.altColor()
                }

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
                            color: bae.foregroundColor()
                        }
                    }
                }

                Component.onCompleted:
                {
                    var map = bae.get("select url from folders order by addDate desc")
                    for(var i in map)
                        model.append(map[i])

                }
            }

            Row
            {
                id: sourceActions
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                height: 48

                ToolButton
                {
                    id: addSource

                    Icon{text: MdiFont.Icon.plus}

                    onClicked:
                    {
                        if(bae.isMobile())
                        {
                            folderPicker.open()
                            load(bae.homeDir())
                        }else
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
                Layout.fillWidth: true
                height: 48
                Label
                {
                    padding: 20
                    text: "Toolbar icon size"
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter

                    color: bae.foregroundColor()
                }

                ComboBox
                {
                    id: iconSize

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
}
