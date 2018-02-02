import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

MenuItem
{
    property string txt
    property int menuItemHeight : root.isMobile ? 48 : 32;
    property int assetsize : menuItemHeight/2

//    background: Rectangle
//    {
//        color: tableMenuItemRoot.hovered ? palette.highlight : palette.background
//    }
    height: menuItemHeight

    hoverEnabled: true
//    font.pointSize: isMobile ? 12 : 10
    padding: 10

//    elide: Text.ElideRight

//    Label
//    {
//        width: parent.width
//        height: parent.height
//        text: txt
////        padding: 10
//        color: "red"
//        horizontalAlignment: Qt.AlignLeft
//        verticalAlignment: Qt.AlignVCenter
//    }
}
