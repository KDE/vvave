import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

ItemDelegate
{
    id: listItem

    width: parent.width
    height: rowHeightAlt

    property alias label: labelTxt.text

    ColumnLayout
    {
        anchors.fill: parent
        Layout.margins: 10

        Label
        {
            id: labelTxt
            Layout.margins: 20
            Layout.fillWidth: true
            Layout.fillHeight: true

            width: parent.width
            height: parent.height

            horizontalAlignment: Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter

            text: labelTxt.text
            elide: Text.ElideRight
            color: foregroundColor
        }
    }
}
