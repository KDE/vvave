import QtQuick 2.3

Text
{
    id: text
    property string iconColor: bae.foregroundColor()
    property int iconSize
    readonly property string defaultColor : iconColor

    font.family: "Material Design Icons"
    font.pixelSize: iconSize || 24
    anchors.centerIn: parent
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment:  Text.AlignVCenter
    color: iconColor || defaultColor

}
