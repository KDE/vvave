import QtQuick
import QtQuick.Controls
import org.mauikit.controls as Maui

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
