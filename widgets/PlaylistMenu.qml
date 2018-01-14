import QtQuick 2.9
import QtQuick.Controls 2.2

Menu
{
    id: root
    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2
    modal: true

    signal clearOut()
    signal clean()
    signal callibrate()
    signal hideCover()

    MenuItem
    {
        text: qsTr("Clear out...")
        onTriggered: clearOut()
    }

    MenuItem
    {
        text: qsTr("Clean...")
        onTriggered: clean()
    }
    MenuItem
    {
        text: cover.visible ? qsTr("Hide cover...") : qsTr("Show cover...")
        onTriggered: hideCover()
    }
    MenuItem
    {
        text: qsTr("Callibrate")
        onTriggered: callibrate()
    }    
    MenuItem
    {
        text: qsTr("Save as playlist...")
        onTriggered: {}
    }


}
