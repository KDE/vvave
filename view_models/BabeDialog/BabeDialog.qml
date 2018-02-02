import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1

Dialog
{
    width: parent.width / 2
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    parent: ApplicationWindow.overlay

    modal: true
    Material.accent: babeColor
    Material.background: backgroundColor
    Material.primary: backgroundColor
    Material.foreground: foregroundColor

    background: Rectangle
    {
        color: backgroundColor
        border.color: midLightColor
        border.width: 1
        radius: 3
    }

}
