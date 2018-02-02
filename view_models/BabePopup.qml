import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1

Popup
{
    width: parent.width *0.8
    height: parent.height *0.8

    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2

    parent: ApplicationWindow.overlay
    z: 999

    modal: true
    focus: true
    clip: true

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0 }
    }

    Material.accent: babeColor
    Material.background: backgroundColor
    Material.primary: backgroundColor
    Material.foreground: foregroundColor

}
