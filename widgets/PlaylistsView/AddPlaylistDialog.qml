import QtQuick 2.0
import QtQuick.Controls 2.2
import "../../view_models/BabeDialog"

BabeDialog
{
    id: newPlaylistDialogRoot
    title: "New Playlist"
    standardButtons: Dialog.Save | Dialog.Cancel
    width: isMobile ? parent.width*0.7 : parent.width*0.4

    Column
    {
        spacing: 20
        anchors.fill: parent
        anchors.centerIn: parent
        width: parent.width

        TextField
        {
            id: newPlaylistField
            width: parent.width
            color: foregroundColor
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
