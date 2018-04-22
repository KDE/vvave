import QtQuick 2.9
import QtQuick.Controls 2.2
import "../utils"
import org.kde.kirigami 2.2 as Kirigami
import QtQuick.Controls.impl 2.3

ToolButton
{
    id: babeButton

    property string iconName
    property int iconSize : toolBarIconSize
    property color iconColor: textColor
    readonly property string defaultColor :  textColor
    property bool anim : false
    spacing: space.small
    display: pageStack.wideMode ? AbstractButton.TextBesideIcon : AbstractButton.IconOnly

    icon.name: isAndroid ? "" : babeButton.iconName
    icon.width: isAndroid ? 0 : babeButton.iconSize
    icon.height: isAndroid ? 0 : babeButton.iconSize
    icon.color: isAndroid  ?  "transparent" : (down ? babeColor : (iconColor || defaultColor))

    onClicked: if(anim) animIcon.running = true

    flat: true
    highlighted: false

    contentItem: IconLabel
    {
        spacing: babeButton.spacing
        mirrored: babeButton.mirrored
        display: babeButton.display

        icon: babeButton.icon
        text: babeButton.text
        font: babeButton.font
        color: iconColor
    }

    BabeIcon
    {
        id: babeIcon
        visible: isAndroid
        icon: babeButton.iconName
        iconColor: babeButton.iconColor || babeButton.defaultColor
        iconSize: babeButton.iconSize
    }

    SequentialAnimation
    {
        id: animIcon
        PropertyAnimation
        {
            target: babeIcon
            property: "color"
            easing.type: Easing.InOutQuad
            from: babeColor
            to: iconColor
            duration: 500
        }
    }
}
