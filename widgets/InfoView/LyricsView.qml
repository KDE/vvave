import QtQuick 2.9
import QtQuick.Controls 2.2

Item
{
    id: infoRoot

    anchors.centerIn: parent

    property string lyrics

    Rectangle
    {
        anchors.fill: parent
        z: -999
        color: backgroundColor
    }

    Text
    {
        text: lyrics || "Nothing here"
        color: foregroundColor
        font.pointSize: 14
        horizontalAlignment: Qt.AlignHCenter
        textFormat: Text.StyledText
    }

}
