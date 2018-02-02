
import QtQuick 2.0
import QtQuick.Controls 2.2

BabeDialog
{
    property string message
    property string messageBody
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
            color: foregroundColor
        }

        Label
        {
            text: messageBody ? messageBody : ""
            width: parent.width
            elide: Text.ElideRight
            color: foregroundColor
        }
    }
}
