import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import Qt.labs.platform 1.0
import org.kde.kirigami 2.2 as Kirigami

import "../../view_models"
import "../../view_models/FolderPicker"

Kirigami.GlobalDrawer
{
    id: settingsView
    handleVisible: false
    signal iconSizeChanged(int size)

    readonly property bool activeBrainz : bae.brainzState()

    y: header.height
    height: parent.height - header.height - footer.height
    //    width: root.pageStack.wideMode ? views.width -1: root.width
    edge: Qt.RightEdge
    //    //    interactive: true
    //    focus: true
    //    modal:true
    //    dragMargin :0

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    Kirigami.Theme.inherit: false
    //    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary


    function scanDir(folderUrl)
    {
        bae.scanDir(folderUrl)
    }

    background: Rectangle
    {
        anchors.fill: parent
        color: backgroundColor
        z: -999
    }

    //    contentItem: Text
    //    {
    //        color: foregroundColor
    //    }


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


    topContent: ColumnLayout
    {
        id: sourcesRoot
        width: settingsView.width
        height: settingsView.height * 0.5

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
                color: altColor
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
                        color: foregroundColor
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

            BabeButton
            {
                id: addSource

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

            BabeButton
            {
                id: removeSource
                iconName: "list-remove"
                onClicked:
                {

                }

            }
        }


    }

    actions: [
        Kirigami.Action
        {
            text: "Brainz"

            Kirigami.Action
            {
                id: brainzToggle
                text: checked ? "ON" : "OFF"
                iconName: "configure"
                checked: activeBrainz
                checkable: true
                onToggled:
                {
                    bae.saveSetting("BRAINZ", checked === true ? true : false, "BABE")
                    bae.brainz(checked === true ? true : false)
                }
            }
        },
        Kirigami.Action
        {
            text: "Appearance"

            Kirigami.Action
            {
                text: "Icon size"
                Kirigami.Action
                {
                    text: "16"
                    onTriggered :
                    {
                        bae.saveSetting("ICON_SIZE", text, "BABE")
                        iconSizeChanged(text)
                    }
                }
                Kirigami.Action
                {
                    text: isMobile ? "24" : "22"
                    onTriggered :
                    {
                        bae.saveSetting("ICON_SIZE", text, "BABE")
                        iconSizeChanged(text)
                    }
                }
                Kirigami.Action
                {
                    text: "32"
                    onTriggered :
                    {
                        bae.saveSetting("ICON_SIZE", text, "BABE")
                        iconSizeChanged(text)
                    }
                }
            }

            Kirigami.Action
            {
                text: "Theme"
                visible: isMobile
                Kirigami.Action
                {
                    text: "Light"
                    onTriggered : switchColorScheme("Light")
                }
                Kirigami.Action
                {
                    text: "Dark"
                    onTriggered : switchColorScheme("Dark")
                }
            }
        }
    ]

    function switchColorScheme(variant)
    {
        bae.saveSetting("THEME", variant, "BABE")

        if(variant === "Light")
        {
            backgroundColor = lightBackgroundColor
            foregroundColor = lightForegroundColor
            textColor = lightTextColor
            babeHighlightColor = lightBabeHighlightColor
            highlightTextColor = lightHighlightTextColor
            midColor = lightMidColor
            midLightColor = lightMidLightColor
            darkColor = lightDarkColor
            baseColor = lightBaseColor
            altColor = lightAltColor
            shadowColor = lightShadowColor

        }else if(variant === "Dark")
        {
            backgroundColor = bae.backgroundColor()
            foregroundColor = bae.foregroundColor()
            textColor = bae.textColor()
            babeHighlightColor = bae.highlightColor()
            highlightTextColor = bae.highlightTextColor()
            midColor = bae.midColor()
            midLightColor = bae.midLightColor()
            darkColor = bae.darkColor()
            baseColor = bae.baseColor()
            altColor = bae.altColor()
            shadowColor = bae.shadowColor()
        }
    }
}
