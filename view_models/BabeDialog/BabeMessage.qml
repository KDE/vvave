import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

BabeDialog
{
    id: babeMessageRoot
    property string message
    property string messageBody
    standardButtons: Dialog.Yes | Dialog.No

    ColumnLayout
    {
        anchors.fill: parent
        width: parent.width
        height: parent.height
        Label
        {
            Layout.margins: contentMargins
            text: message ? message : ""
            width: babeMessageRoot.width
            elide: Text.ElideRight
            color: foregroundColor
        }

        TextArea
        {
            Layout.margins: contentMargins
            Layout.maximumWidth: parent.width

            text: messageBody ? messageBody : ""
            width: parent.width
            wrapMode: TextEdit.WrapAnywhere
            readOnly: true
            color: foregroundColor
        }
    }
}
