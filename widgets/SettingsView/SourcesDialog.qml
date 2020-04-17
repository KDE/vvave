import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.10
import org.kde.mauikit 1.0 as Maui
import org.maui.vvave 1.0 as Vvave

import "../../view_models"
import "../../utils/Help.js" as H

Maui.Dialog
{
    property string pathToRemove : ""

    maxWidth: Maui.Style.unit * 600
    maxHeight: Maui.Style.unit * 500
    defaultButtons: true
    acceptButton.text: qsTr("Add")
    rejectButton.text: qsTr("Remove")
    page.margins: Maui.Style.space.medium

    onRejected:
    {
        var index = sources.currentIndex
        var url = sources.model.get(index).url
        pathToRemove = url
        confirmationDialog.title = "Remove source"
        confirmationDialog.message = "Are you sure you want to remove the source: \n "+url
        confirmationDialog.open()
    }

    onAccepted:
    {
        _dialogLoader.sourceComponent = _fmDialogComponent
        root.dialog.settings.onlyDirs = true
        root.dialog.show(function(paths)
        {

            console.log("SCAN DIR <<", paths)
            for(var i in paths)
                listModel.append({url: paths[i]})
            Vvave.Vvave.scanDir([paths])
        })

        getSources()
    }

    Maui.Dialog
    {
        id: confirmationDialog
        page.margins: Maui.Style.space.medium

        onAccepted:
        {
            if(pathToRemove.length>0)
                if( Vvave.Vvave.removeSource(pathToRemove))
                    H.refreshCollection()
            getSources()
            confirmationDialog.close()
        }
        onRejected: confirmationDialog.close()
    }

    Maui.Holder
    {
        anchors.fill: parent
        visible: !sources.count
        emoji: "qrc:/assets/MusicCloud.png"
        isMask: true
        title : qsTr("No Sources!")
        body: qsTr("Add new sources to organize and play your music collection")
        emojiSize: Maui.Style.iconSizes.huge
    }

    BabeList
    {
        id: sources
        Layout.fillHeight: true
        Layout.fillWidth: true
        headBar.visible: false
        title: qsTr("Sources")
        width: parent.width

        ListModel { id: listModel }

        model: listModel

        delegate: Maui.ListDelegate
        {
            id: delegate
            label: url

            Connections
            {
                target: delegate
                onClicked: sources.currentIndex = index
            }
        }
    }

    onOpened: getSources()

    function getSources()
    {
        sources.model.clear()
        var folders = Vvave.Vvave.getSourceFolders()
        for(var i in folders)
            sources.model.append({url : folders[i]})
    }
}
