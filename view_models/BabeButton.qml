import QtQuick 2.9
import QtQuick.Controls 2.2
import "../utils"
import org.kde.kirigami 2.2 as Kirigami
import QtQuick.Controls.impl 2.3

ToolButton
{
    id: babeButton

    property string iconName
    property int iconSize : 22
    property color iconColor: textColor
    readonly property string defaultColor :  textColor
    property bool anim : false

    spacing: space.small

    icon.name: babeButton.iconName
    icon.width: babeButton.iconSize
    icon.height: babeButton.iconSize
    icon.color:  down ? babeColor : (iconColor || defaultColor)

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

    SequentialAnimation
    {
        id: animIcon
        PropertyAnimation
        {
            target: babeButton
            property: "icon.color"
            easing.type: Easing.InOutQuad
            from: babeColor
            to: iconColor
            duration: 500
        }
    }
}
