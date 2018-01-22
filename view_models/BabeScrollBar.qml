import QtQuick 2.9
import QtQuick.Controls 2.2

ScrollBar
{
    id: scrollBar
    size: 0.3
    position: 0.2
    active: true
    focus: true
    visible: !bae.isMobile()
    background : Rectangle
    {
        radius: 12
        color: bae.backgroundColor()
    }

    contentItem: Rectangle
    {
        implicitWidth: 6
        implicitHeight: 100
        radius: width / 2
        color: scrollBar.pressed ? bae.hightlightColor() : bae.darkColor()
    }
}
