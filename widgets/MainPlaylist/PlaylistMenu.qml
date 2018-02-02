import QtQuick 2.9
import QtQuick.Controls 2.2
import "../../view_models/BabeMenu"


BabeMenu
{    
    signal clearOut()
    signal clean()
    signal callibrate()
    signal hideCover()

    BabeMenuItem
    {
        text: qsTr("Clear out...")
        onTriggered: clearOut()
    }

    BabeMenuItem
    {
        text: qsTr("Clean...")
        onTriggered: clean()
    }

    BabeMenuItem
    {
        text: cover.visible ? qsTr("Hide cover...") : qsTr("Show cover...")
        onTriggered: hideCover()
    }

    BabeMenuItem
    {
        text: qsTr("Callibrate")
        onTriggered: callibrate()
    }

    BabeMenuItem
    {
        text: qsTr("Save as playlist...")
        onTriggered: {}
    }

}
