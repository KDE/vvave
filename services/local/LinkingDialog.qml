import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import "../../utils/Help.js" as H
import org.kde.mauikit 1.0 as Maui

Maui.Dialog
{
    id: linkingDialogRoot

    maxHeight: Maui.Style.unit *400
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
        Layout.fillHeight: true
        Layout.fillWidth: true
        clip: true

        contentWidth: linkingDialogRoot.width
        contentHeight: contentLayout.implicitHeight

        ColumnLayout
        {
            id: contentLayout
            width: linkingDialogRoot.width

            Label
            {
                text:qsTr("Linking allows to connect two devices on the same network. Just provide the device IP address to which you want to connect")
                verticalAlignment:  Qt.AlignVCenter
                elide: Text.ElideRight
                font.pointSize: Maui.Style.fontSizes.default
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            Label
            {
                text: qsTr("IP Address")
                verticalAlignment:  Qt.AlignVCenter
                elide: Text.ElideRight
                font.pointSize: Maui.Style.fontSizes.default

                Layout.fillWidth: true
            }

            Maui.TextField
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
                font.pointSize: Maui.Style.fontSizes.small

                Layout.fillWidth: true
            }
        }
    }
}

