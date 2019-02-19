import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.mauikit 1.0 as Maui

Maui.Menu
{    
    signal clearOut()
    signal clean()
    signal callibrate()
    signal hideCover()
    signal saveToClicked()
    Maui.MenuItem
    {
        text: qsTr("Clear out...")
        onTriggered: clearOut()
    }

    Maui.MenuItem
    {
        text: qsTr("Clean...")
        onTriggered: clean()
    }  

    Maui.MenuItem
    {
        text: qsTr("Save list to...")
        onTriggered: saveToClicked()
    }

    Maui.MenuItem
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
