import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

BabeDialog
{
    property string message
    property string messageBody
    standardButtons: Dialog.Yes | Dialog.No
    ColumnLayout
    {
        anchors.fill: parent
        Label
        {
            Layout.margins: contentMargins
            text: message ? message : ""
            width: parent.width
            elide: Text.ElideRight
            color: foregroundColor
        }

        Label
        {
            Layout.margins: contentMargins
            text: messageBody ? messageBody : ""
            width: parent.width
            elide: Text.ElideRight
            color: foregroundColor
        }
    }
}
