import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models"
import QtQuick.Controls.Material 2.1

BabePopup
{
    property alias dirList : dirList
    signal pathClicked(var path)
    signal accepted(var path)
    signal goBack(var path)

    property string currentUrl
    property string currentName

    background: Rectangle
    {
        anchors.fill: parent
        color: altColor
        z: -999
        radius: 3
    }

    BabeList
    {
        id: dirList
        anchors.fill: parent
        property int currentRow : -1
        property string currentUrl
        property string currentName

        signal rowClicked(int index)
        signal rowPressed(int index)

        onExit: close()

        headerBarExit: true
        headerBarVisible: true
        headerBarTitle: ""

        headerBarLeft: [

            BabeButton
            {
                id: homeBtn
                iconName: "gohome"
                onClicked: load(bae.homeDir())
            },

            BabeButton
            {
                id: sdBtn
                iconName: "sd"
                onClicked: load(bae.sdDir())
            }
        ]

        headerBarRight:  Button
        {
            Layout.alignment: Qt.AlignRight
            onClicked: {accepted(dirList.currentUrl); close()}
            text: "Accept"

            Material.accent: babeColor
            Material.background: backgroundColor
            Material.primary: backgroundColor
            Material.foreground: foregroundColor

        }

        ListModel { id: listModel }

        model: listModel

        delegate: BabeDelegate
        {
            id: delegate
            label : name

            Connections
            {
                target: delegate
                onClicked:
                {
                    currentIndex = index
                    currentUrl = dirList.model.get(index).url
                    currentName = dirList.model.get(index).name
                    pathClicked(currentUrl)
                }
            }
        }
    }


    function load(folderUrl)
    {
        dirList.list.clearTable()
        var dirs = bae.getDirs(folderUrl)
        for(var path in dirs)
            dirList.model.append(dirs[path])
    }

}
