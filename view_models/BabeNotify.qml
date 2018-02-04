import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1

Popup
{
    property string message : ""
    id: notify
    width: columnWidth
    height: toolBarHeight

    padding: 0


    x: parent.width / 2 - width / 2
    y: parent.height * 0.1
    parent: ApplicationWindow.overlay

    z: 999

    modal: false
    focus: false
    clip: true

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0 }
    }

    background: Rectangle
    {
        id: notifyBg
        color: altColor
        opacity: opacityLevel

    }

    Material.accent: babeColor
    Material.background: backgroundColor
    Material.primary: backgroundColor
    Material.foreground: foregroundColor

    Column
    {
        anchors.fill: parent

        Label
        {
            height: parent.height
            width: parent.width
            text: message
            font.pointSize: 9
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            color: foregroundColor
        }
    }

    function notify(txt)
    {
        message = txt
        open()
    }

}
