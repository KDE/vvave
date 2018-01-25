import QtQuick 2.0
import QtQuick.Controls 2.2

Dialog
{
    id: newPlaylistDialogRoot
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    parent: ApplicationWindow.overlay

    modal: true
    title: "New Playlist"
    standardButtons: Dialog.Yes | Dialog.No

    Column
    {
        spacing: 20
        anchors.fill: parent
        TextField
        {
            id: newPlaylistField

            onAccepted:
            {
                addPlaylist()
                close()
            }
        }
    }

    onAccepted: addPlaylist()

    function addPlaylist()
    {
        var title = newPlaylistField.text.trim()
        if(bae.addPlaylist(title))
            model.append({playlist: title})
    }
}
