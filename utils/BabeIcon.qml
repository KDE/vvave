import QtQuick 2.9
import "../utils/Icons.js" as MdiFont

Text
{
    id: babeIcon
    property string iconColor: bae.foregroundColor()
    property int iconSize
    property string icon
    readonly property string defaultColor : iconColor
    text: MdiFont.Babe[babeIcon.icon]
    font.family: "Material Design Icons"
    font.pixelSize: babeIcon.iconSize
    anchors.centerIn: parent
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment:  Text.AlignVCenter
    color: babeIcon.iconColor

}
