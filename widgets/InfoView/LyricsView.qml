import QtQuick 2.10
import QtQuick.Controls 2.10
import org.kde.mauikit 1.0 as Maui

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
        font.pointSize: Maui.Style.fontSizes.big
        horizontalAlignment: Qt.AlignHCenter
        textFormat: Text.StyledText
    }

}
