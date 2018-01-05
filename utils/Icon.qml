import QtQuick 2.3

Text
{
    id: text
    property string iconColor
    property int iconSize

    font.family: "Material Design Icons"
    font.pixelSize: iconSize || 24
    anchors.centerIn: parent
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment:  Text.AlignVCenter
}
