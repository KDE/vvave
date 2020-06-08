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
        text: i18n("Clear out...")
        onTriggered: clearOut()
    }

    MenuItem
    {
        text: i18n("Clean...")
        onTriggered: clean()
    }  

    MenuItem
    {
        text: i18n("Save list to...")
        onTriggered: saveToClicked()
    }

    MenuItem
    {
        enabled: syncPlaylist.length > 0
        text: syncPlaylist.length > 0 && sync ? i18n("Pause syncing") : i18n("Continue syncing")
        onTriggered: sync = !sync
    }

//    Maui.MenuItem
//    {
//        text: i18n("Playlist list...")
//        checkable: true
//        checked: mainPlaylistItem.visible
//        onTriggered: mainPlaylistItem.visible = !mainPlaylistItem.visible
//    }

}
