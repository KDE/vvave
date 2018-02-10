import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0

import "../../view_models"
import "../../view_models/FolderPicker"

BabePopup
{

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
            onPathClicked: folderPicker.load(path)

            onAccepted:
            {
                listModel.append({url: path})
                scanDir(path)
            }

            onGoBack: folderPicker.load(path)
        }
    }

    BabeList
    {
        id: sources
        headerBarVisible: true
        headerBarExit: true
        headerBarTitle: qsTr("Sources")
        Layout.fillWidth: true
        Layout.fillHeight: true
        width: parent.width

        onExit: close()

        ListModel { id: listModel }

        model: listModel

        delegate: BabeDelegate
        {
            id: delegate
            label: url

            Connections
            {
                target: delegate
                onClicked: sources.currentIndex = index
            }
        }

        headerBarRight: [

            BabeButton
            {
                iconName: "list-remove"
                onClicked:{}
            },

            BabeButton
            {
                iconName: "list-add"
                onClicked:
                {
                    if(bae.isMobile())
                    {
                        folderPicker.open()
                        folderPicker.load(bae.homeDir())
                    }else
                        folderDialog.open()
                }
            }
        ]

        Component.onCompleted:
        {
            var map = bae.get("select url from folders order by strftime(\"%s\", addDate) desc")
            for(var i in map)
                model.append(map[i])
        }
    }





}
