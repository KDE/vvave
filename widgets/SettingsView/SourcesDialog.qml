import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0
import org.kde.maui 1.0 as Maui
import "../../view_models"
import "../../view_models/BabeDialog"

BabePopup
{

    property string pathToRemove : ""

    function scanDir(folderUrl)
    {
        bae.scanDir(folderUrl)
    }


    BabeMessage
    {
        id: confirmationDialog
        onAccepted:
        {
            if(pathToRemove.length>0)
                if(bae.removeSource(pathToRemove))
                    bae.refreshCollection()

        }
    }

    BabeList
    {
        id: sources
        anchors.fill: parent
        headBarVisible: true
        headBarExit: true
        headBarTitle: qsTr("Sources")
        Layout.fillWidth: true
        Layout.fillHeight: true
        width: parent.width

        onExit: close()

        ListModel { id: listModel }

        model: listModel

        delegate: Maui.LabelDelegate
        {
            id: delegate
            label: url

            Connections
            {
                target: delegate
                onClicked: sources.currentIndex = index
            }
        }

        headBar.rightContent: [

            Maui.ToolButton
            {
                iconName: "list-remove"
                onClicked:
                {
                    close()
                    var index = sources.currentIndex
                    var url = sources.list.model.get(index).url

                    confirmationDialog.title = "Remove source"

                    if(bae.defaultSources().indexOf(url)<0)
                    {
                        pathToRemove = url
                        confirmationDialog.message = "Are you sure you want to remove the source: \n "+url
                    }
                    else
                    {
                        pathToRemove = ""
                        confirmationDialog.message = url+"\nis a default source and cannot be removed"
                    }

                    confirmationDialog.open()
                }
            },

            Maui.ToolButton
            {
                iconName: "list-add"
                onClicked:
                {
                    close()
                    fmDialog.onlyDirs = true
                    fmDialog.show(function(paths)
                    {
                        for(var i in paths)
                        {
                            listModel.append({url: paths[i]})
                            scanDir(paths[i])
                        }
                        close()

                    })
                }
            }
        ]
    }

    onOpened: getSources()

    function getSources()
    {
        sources.clearTable()
        var folders = bae.getSourcesFolders()
        for(var i in folders)
            sources.model.append({url : folders[i]})
    }
}
