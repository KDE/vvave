import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models/BabeDialog"

BabeDialog
{
    id: newPlaylistDialogRoot
    title: "New Playlist"
    standardButtons: Dialog.Save | Dialog.Cancel
    height: parent.height * 0.3
    ColumnLayout
    {
        spacing: 20
        anchors.fill: parent

        TextField
        {
            id: newPlaylistField

            Layout.fillWidth: true
            Layout.margins: contentMargins
            width: parent.width
            color: foregroundColor
            onAccepted:
            {
                addPlaylist()
                close()
            }
        }
    }

    onOpened: newPlaylistField.forceActiveFocus()
    onAccepted: addPlaylist()

    function addPlaylist()
    {
        var title = newPlaylistField.text.trim()
        if(bae.addPlaylist(title))
            model.insert(9, {playlist: title})
        list.positionViewAtEnd()
    }
}
