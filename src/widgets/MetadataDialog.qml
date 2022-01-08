import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import QtQuick.Templates 2.15 as T

Maui.SettingsDialog
{
    id: control

    property var data : control.model.get(control.index)
    property int index : -1 //index of the item in the model TracksModel

    property Maui.BaseModel model
    defaultButtons: true
    title: i18n("Edit")

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

    Maui.SettingsSection
    {
        id: _template
        title: i18n("Metadata")
        description: i18n("Embeded metadata info.")

        Maui.SettingTemplate
        {
            Layout.fillWidth: true

            label1.text: i18n("Track Title")

            Maui.TextField
            {
                id: _titleField
                text: control.data.title
                Layout.fillWidth: true
            }
        }

        Maui.SettingTemplate
        {
            Layout.fillWidth: true

            label1.text: i18n("Artist")


            Maui.TextField
            {
                id: _artistField
                text: control.data.artist
                Layout.fillWidth: true
            }
        }

        Maui.SettingTemplate
        {
            Layout.fillWidth: true

            label1.text: i18n("Album")

            Maui.TextField
            {
                id: _albumField
                text: control.data.album
                Layout.fillWidth: true
            }
        }

        Maui.SettingTemplate
        {
            Layout.fillWidth: true

            label1.text: i18n("Track")

            Maui.TextField
            {
                id: _trackField
                text: control.data.track
                Layout.fillWidth: true
            }
        }

        Maui.SettingTemplate
        {
            Layout.fillWidth: true

            label1.text: i18n("Genre")

            Maui.TextField
            {
                id: _genreField
                text: control.data.genre
                Layout.fillWidth: true
            }
        }

        Maui.SettingTemplate
        {
            Layout.fillWidth: true

            label1.text: i18n("Year")

            Maui.TextField
            {
                id: _yearField
                text: control.data.releasedate
                Layout.fillWidth: true
            }
        }

        Maui.SettingTemplate
        {
            Layout.fillWidth: true

            label1.text: i18n("Comment")

            Maui.TextField
            {
                id: _commentField
                text: control.data.comment
                Layout.fillWidth: true
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("File Info")
        description: i18n("Locla file info.")
    }

}
