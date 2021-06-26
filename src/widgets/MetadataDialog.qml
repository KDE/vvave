import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui

Maui.Dialog
{
    id: control

    property var data : control.model.get(control.index)
    property int index : -1 //index of the item in the model TracksModel

    property Maui.BaseModel model

    title: i18n("Edit")

    hint: 1
    closeButtonVisible: false
    page.margins: Maui.Style.space.big
    spacing: Maui.Style.space.big

    signal edited(var data, int index)

    onAccepted:
    {
        control.data.title = _titleField.text;
        control.data.artist = _artistField.text;
        control.data.album = _albumField.text;
        control.data.track = _trackField.text;
        control.data.genre = _genreField.text;
        control.data.releasedate = _yearField.text;
        control.data.comment = _commentField.text;

        control.edited(control.data, control.index)
        control.close()
    }

    onRejected: close()

    ColumnLayout
    {
        Layout.fillWidth: true

        Label
        {
            text: i18n("Track Title")
             Layout.fillWidth: true
        }

        Maui.TextField
        {
            id: _titleField
            text: control.data.title
            Layout.fillWidth: true
        }
    }

    ColumnLayout
    {
        Layout.fillWidth: true

        Label
        {
            text: i18n("Artist")
             Layout.fillWidth: true
        }

        Maui.TextField
        {
            id: _artistField
            text: control.data.artist
             Layout.fillWidth: true
        }
    }

    ColumnLayout
    {
        Layout.fillWidth: true

        Label
        {
            text: i18n("Album")
             Layout.fillWidth: true
        }

        Maui.TextField
        {
            id: _albumField
            text: control.data.album
             Layout.fillWidth: true
        }
    }

    ColumnLayout
    {
        Layout.fillWidth: true

        Label
        {
            text: i18n("Track")
             Layout.fillWidth: true
        }

        Maui.TextField
        {
            id: _trackField
            text: control.data.track
             Layout.fillWidth: true
        }
    }

    ColumnLayout
    {
        Layout.fillWidth: true

        Label
        {
            text: i18n("Genre")
             Layout.fillWidth: true
        }

        Maui.TextField
        {
            id: _genreField
            text: control.data.genre
             Layout.fillWidth: true
        }
    }

    ColumnLayout
    {
        Layout.fillWidth: true

        Label
        {
            text: i18n("Year")
             Layout.fillWidth: true
        }

        Maui.TextField
        {
            id: _yearField
            text: control.data.releasedate
             Layout.fillWidth: true
        }
    }

    ColumnLayout
    {
        Layout.fillWidth: true

        Label
        {
            text: i18n("Comment")
             Layout.fillWidth: true
        }

        Maui.TextField
        {
            id: _commentField
            text: control.data.comment
             Layout.fillWidth: true
        }
    }
}
