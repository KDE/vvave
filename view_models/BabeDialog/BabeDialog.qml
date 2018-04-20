import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1

Dialog
{
    width: columnWidth * 0.9
    height: parent.height*0.5

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    parent: ApplicationWindow.overlay

    modal: true

    margins: 0
    padding: space.tiny


    Material.accent: babeColor
    Material.background: backgroundColor
    Material.primary: backgroundColor
    Material.foreground: textColor

}
