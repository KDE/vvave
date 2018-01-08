import QtQuick 2.0
import QtQuick.Controls 2.2

Dialog
{
    id: dialog
    property string message

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    parent: ApplicationWindow.overlay

    modal: true
    title: "Confirmation"
    standardButtons: Dialog.Yes | Dialog.No

    Column
    {
        spacing: 20
        anchors.fill: parent
        Label
        {
            text: message ? message : ""
        }
    }

    onAccepted: console.log("accepted join medos")

}
