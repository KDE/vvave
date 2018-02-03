import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

ItemDelegate
{
    id: listItem

    width: parent.width
    height: rowHeightAlt

    property alias label: labelTxt.text
    property string textColor: ListView.isCurrentItem ? highlightTextColor : foregroundColor

    ColumnLayout
    {
        anchors.fill: parent

        Label
        {
            id: labelTxt
            Layout.margins: contentMargins
            anchors.verticalCenter: parent.verticalCenter

            width: parent.width
            height: parent.height

            horizontalAlignment: Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter

            text: labelTxt.text
            elide: Text.ElideRight
            color: textColor
        }
    }
}
