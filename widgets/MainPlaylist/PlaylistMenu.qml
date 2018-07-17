import QtQuick 2.9
import QtQuick.Controls 2.2
import "../../view_models/BabeMenu"


BabeMenu
{    
    signal clearOut()
    signal clean()
    signal callibrate()
    signal hideCover()
    signal saveToClicked()
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
        text: qsTr("Save list to...")
        onTriggered: saveToClicked()
    }

    MenuItem
    {
        enabled: syncPlaylist.length > 0
        text: syncPlaylist.length > 0 && sync ? qsTr("Pause syncing") : qsTr("Continue syncing")
        onTriggered: sync = !sync
    }

}
