import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models"

BabePopup
{
    property alias dirList : dirList
    signal pathClicked(var path)
    signal accepted(var path)
    signal goBack(var path)

    background: Rectangle
    {
        anchors.fill: parent
        color: altColor
        z: -999
        radius: 3
    }

    ColumnLayout
    {
        anchors.fill: parent

        RowLayout
        {
            Layout.fillWidth: true
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
                    color: foregroundColor
                    text: "Accept"
                }
                background: Rectangle
                {
                    color: babeColor
                    radius: 2
                }
            }

        }

        FolderPickerList
        {
            id: dirList
            Layout.fillWidth:true
            Layout.fillHeight: true
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
