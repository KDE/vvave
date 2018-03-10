import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models/BabeDialog"
import "../../utils/Help.js" as H
BabeDialog
{
    title: "Add "+ tracks.length +" tracks to..."
    standardButtons: Dialog.Save | Dialog.Cancel

    margins: contentMargins


    onAccepted:
    {

        if(ipField.text === link.deviceIp())
            H.notify("Error", "Please provide a different IP address")
        else
        {
            if(nameField.text.length<1)
                nameField.text = "Device1"

            bae.saveSetting("LINKINGIP", ipField.text, "BABE")
            link.connectTo(ipField.text, link.getPort())
        }
    }

    ColumnLayout
    {
        anchors.centerIn: parent
        width: parent.width*0.8
        height: parent.height*0.9
        spacing: c

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

        Label
        {
            text: qsTr("Device Name")
            verticalAlignment:  Qt.AlignVCenter
            elide: Text.ElideRight
            font.pointSize: fontSizes.medium

            Layout.fillWidth: true
        }

        TextField
        {
            id: nameField
            Layout.fillWidth: true
            text: bae.loadSetting("LINKINGIP", "BABE",  "").name

        }

        Label
        {
            text:qsTr("Device IP address: \n") +link.deviceIp()
            verticalAlignment:  Qt.AlignVCenter
            elide: Text.ElideRight
            font.pointSize: fontSizes.medium

            Layout.fillWidth: true
        }

        Item
        {

            Layout.fillWidth: true
            Layout.fillHeight: true
        }

    }
}
