import QtQuick 2.9
import "../utils/Icons.js" as MdiFont

Text
{
    property string iconColor: bae.foregroundColor()
    property int iconSize
    readonly property string defaultColor : iconColor
    property string icon

    text: MdiFont.Icon[icon]
    font.family: "Material Design Icons"
    font.pixelSize: iconSize || 24
    anchors.centerIn: parent
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment:  Text.AlignVCenter
    color: iconColor || defaultColor

}
