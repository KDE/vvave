import QtQuick 2.0
import QtQuick.Controls 2.2
import "../utils"

ToolButton
{
    id: babeButton
    property string iconName
    property int iconSize : isMobile ?  24 : 22
    property string iconColor: bae.foregroundColor()
    readonly property string defaultColor :  bae.foregroundColor()

    icon.name: isMobile ? "" : babeButton.iconName
    icon.width: isMobile ? 0 : babeButton.iconSize
//    icon.height: isMobile ? 0 : babeButton.iconSize
    icon.color: isMobile ? "transparent" : (iconColor || defaultColor)

    BabeIcon
    {
        id: babeIcon
        visible: isMobile
        icon: babeButton.iconName
        iconColor: babeButton.iconColor || babeButton.defaultColor
        iconSize: babeButton.iconSize
    }

}


