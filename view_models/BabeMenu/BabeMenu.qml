import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Menu
{
    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2
    modal: root.isMobile
    focus: true
    parent: ApplicationWindow.overlay


//    padding: 10

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0 }
    }

    background: Rectangle
    {
        implicitWidth: 200
        implicitHeight: 40
        color: altColor
        border.color: midLightColor
        border.width: 1
        radius: 3

    }
}
