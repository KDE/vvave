import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models"
import QtQuick.Controls.Material 2.1
import org.kde.maui 1.0 as Maui

BabePopup
{
    signal pathClicked(var path)
    signal accepted(var path)
    signal goBack(var path)

    property string currentUrl
    property string currentName



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

        headBarExit: true
        headBarVisible: true
        headBarTitle: "Select8"

        headBar.leftContent: [

            Maui.ToolButton
            {
                id: homeBtn
                iconName: "gohome"
                onClicked: load(bae.homeDir())
            },

            Maui.ToolButton
            {
                id: sdBtn
                iconName: "sd"
                onClicked: load(bae.sdDir())
            }
        ]

        headBar.rightContent:  Button
        {
            Layout.alignment: Qt.AlignRight
            onClicked: {accepted(currentUrl); close()}
            text: "Accept"

            Material.accent: babeColor
            Material.background: backgroundColor
            Material.primary: backgroundColor
            Material.foreground: textColor

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
                    dirList.currentIndex = index
                    currentUrl = dirList.model.get(index).url
                    currentName = dirList.model.get(index).name
                    pathClicked(currentUrl)
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
