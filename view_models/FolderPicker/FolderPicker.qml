import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models"

Popup
{
    width: parent.width
    height: parent.height
    id: folderPickerRoot   
    modal: true
    focus: true
    clip: true
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0 }
    }

    property int current : 0

    property alias dirList : dirList
    signal pathClicked(var path)
    signal accepted(var path)
    signal goBack(var path)

    background: Rectangle
    {
        anchors.fill: parent
        color: bae.altColor()
        z: -999
    }

    Column
    {
        anchors.fill: parent

        RowLayout
        {
            width:parent.width

            BabeButton
            {
                Layout.alignment: Qt.AlignLeft
                id: closeBtn
                iconName: "window-close"
                onClicked: close()
            }

            BabeButton
            {  
                id: homeBtn
                iconName: "gohome"
                onClicked: load(bae.homeDir())
            }

            BabeButton
            {
                id: sdBtn
                iconName: "sd"
                onClicked: load(bae.sdDir())
            }

            Button
            {
                Layout.alignment: Qt.AlignRight
                onClicked: {accepted(dirList.currentUrl); close()}
                contentItem: Text
                {
                    color: bae.foregroundColor()
                    text: "Accept"
                }
                background: Rectangle
                {
                    color: bae.babeColor()
                    radius: 2
                }
            }

        }

        FolderPickerList
        {
            id: dirList

            Connections
            {
                target: dirList
                onRowClicked:
                {
                    dirList.currentUrl = dirList.model.get(index).url
                    dirList.currentName = dirList.model.get(index).name
                    pathClicked(dirList.currentUrl)
                }
            }
        }
    }
    function load(folderUrl)
    {        
        dirList.clearTable()
        var dirs = bae.getDirs(folderUrl)
        for(var path in dirs)
            dirList.model.append(dirs[path])

    }

}
