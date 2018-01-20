import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../utils/Icons.js" as MdiFont
import "../utils/Help.js" as H
import "../utils"

MenuItem
{
    id: tableMenuItemRoot
    property string txt

//    background: Rectangle
//    {
//        color: tableMenuItemRoot.hovered ? bae.hightlightColor() : bae.backgroundColor()
//    }

    hoverEnabled: true
    Label
    {
        width: parent.width
        height: parent.height
        text: txt
        padding: 10
        color: bae.foregroundColor()
        horizontalAlignment: Qt.AlignLeft
        verticalAlignment: Qt.AlignVCenter
        elide: Text.ElideRight
    }
}
