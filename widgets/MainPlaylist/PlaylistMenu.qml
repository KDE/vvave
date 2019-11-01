import QtQuick 2.10
import QtQuick.Controls 2.10
import org.kde.mauikit 1.0 as Maui

Menu
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
        text: qsTr("Save list to...")
        onTriggered: saveToClicked()
    }

    MenuItem
    {
        enabled: syncPlaylist.length > 0
        text: syncPlaylist.length > 0 && sync ? qsTr("Pause syncing") : qsTr("Continue syncing")
        onTriggered: sync = !sync
    }

//    Maui.MenuItem
//    {
//        text: qsTr("Playlist list...")
//        checkable: true
//        checked: mainPlaylistItem.visible
//        onTriggered: mainPlaylistItem.visible = !mainPlaylistItem.visible
//    }

}
