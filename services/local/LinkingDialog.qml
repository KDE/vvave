import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models/BabeDialog"
import "../../utils/Help.js" as H

BabeDialog
{
    id: linkingDialogRoot
    title: "Add "+ tracks.length +" tracks to..."
    standardButtons: Dialog.Save | Dialog.Cancel

    margins: contentMargins


    onAccepted:
    {

        if(ipField.text === link.deviceIp())
            H.notify("Error", "Please provide a different IP address")
        else
        {
            bae.saveSetting("LINKINGIP", ipField.text, "BABE")
            link.connectTo(ipField.text, link.getPort())
        }
    }


    ScrollView
    {
        anchors.fill: parent
        anchors.centerIn: parent
        clip: true

        contentWidth: parent.width
        contentHeight: contentLayout.implicitHeight

        ColumnLayout
        {
            id: contentLayout
            anchors.centerIn: parent
            width: linkingDialogRoot.width*0.8
            height: linkingDialogRoot.height*0.9

            Item
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Label
            {
                text:qsTr("Linking allows to connect two devices on the same network. Just provide the device IP address to which you want to connect")
                verticalAlignment:  Qt.AlignVCenter
                elide: Text.ElideRight
                font.pointSize: fontSizes.medium
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }


            Item
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Label
            {
                text: qsTr("IP Address")
                verticalAlignment:  Qt.AlignVCenter
                elide: Text.ElideRight
                font.pointSize: fontSizes.medium

                Layout.fillWidth: true
            }

            TextField
            {
                id: ipField
                Layout.fillWidth: true
                text: bae.loadSetting("LINKINGIP", "BABE",  link.getIp())

            }

            CheckBox
            {
                id: autoLink
                checked: bae.loadSetting("AUTOLINKING", "BABE", false)
                text: qsTr("Autolink to IP address")

                onCheckedChanged:
                {
                    bae.saveSetting("AUTOLINKING", checked, "BABE")
                }
            }

            CheckBox
            {
                id: linkState
                checked: isLinked
                text: isLinked ? qsTr("Linked to ")+ link.getIp(): "You're not linked"
                enabled: false
            }

            CheckBox
            {
                id: servingState
                checked: isServing
                text: isServing ? qsTr("Serving to ")+ link.getDeviceName() : "You're not serving"
                enabled: false
            }

            Label
            {
                text:qsTr("This Device IP address: \n") +link.deviceIp()
                verticalAlignment:  Qt.AlignVCenter
                elide: Text.ElideRight
                font.pointSize: fontSizes.small

                Layout.fillWidth: true
            }

            Item
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }



        }
    }
    }

