import QtQuick 2.0
import QtQuick.Controls 2.2

Dialog
{
    id: dialog
    property string message
    property string messageBody
    width: parent.width
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    parent: ApplicationWindow.overlay


    modal: true
    standardButtons: Dialog.Yes | Dialog.No

    Column
    {
        spacing: 20
        anchors.fill: parent
        Label
        {
            text: message ? message : ""
            width: parent.width
            elide: Text.ElideRight
            color: bae.foregroundColor()
        }

        Label
        {
            text: messageBody ? messageBody : ""
            width: parent.width
            elide: Text.ElideRight
            color: bae.foregroundColor()
        }
    }

}
