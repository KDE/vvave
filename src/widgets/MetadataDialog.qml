import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.3 as Maui

import org.maui.vvave 1.0 as Vvave

Maui.Dialog
{
    id: control

    title: i18n("Edit")
    closeButton.visible: false
    property alias url  : _editor.url

    page.margins: Maui.Style.space.big
    spacing: Maui.Style.space.big

    onAccepted:
    {
        _editor.title = _titleField.text;
        _editor.artist = _artistField.text;
        _editor.album = _albumField.text;
        _editor.track = _trackField.text;
        _editor.genre = _genreField.text;
    }

    onRejected: close()

    Vvave.MetadataEditor
    {
        id: _editor
    }

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
            text: _editor.title
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
            text: _editor.artist
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
            text: _editor.album
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
            text: _editor.track
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
            text: _editor.genre
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
            text: _editor.year
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
            text: _editor.comment
             Layout.fillWidth: true
        }
    }
}
