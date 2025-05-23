/*
 *   Copyright 2020 Camilo Higuita <milo.h@aol.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB

import org.maui.vvave

Maui.SettingsDialog
{
    id: control

    Maui.InfoDialog
    {
        id: confirmationDialog
        property string url : ""

        title : i18n("Remove source")
        message : i18n("Are you sure you want to remove the source: \n%1", url)
        template.iconSource: "emblem-warning"

        standardButtons: Dialog.Ok | Dialog.Cancel

        onAccepted:
        {
            if(url.length>0)
                Vvave.removeSource(url)
            confirmationDialog.close()
        }
        onRejected: confirmationDialog.close()
    }

    Maui.SectionGroup
    {
        title: i18n("Playback")
//        description: i18n("Configure the playback behavior.")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Save & Restore Session")
            label2.text: i18n("Resume the last session playlist.")

            Switch
            {
                checkable: true
                checked: playlist.autoResume
                onToggled: playlist.autoResume = !playlist.autoResume
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Volume")
            label2.text: i18n("Show volume controls.")

            Switch
            {
                checkable: true
                checked: settings.volumeControl
                onToggled: settings.volumeControl = !settings.volumeControl
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Exiting")
            label2.text: i18n("Ask before closing if music is playing")

            Switch
            {
                checkable: true
                checked: settings.askBeforeClose
                onToggled: settings.askBeforeClose = !settings.askBeforeClose
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Collection")
//        description: i18n("Configure the app plugins and collection behavior.")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Fetch Artwork")
            label2.text: i18n("Gathers album and artists artworks from online services: LastFM, Spotify, MusicBrainz, iTunes, Genius, and others.")

            Switch
            {
                checkable: true
                checked: settings.fetchArtwork
                onToggled:  settings.fetchArtwork = !settings.fetchArtwork
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Auto Scan")
            label2.text: i18n("Scan all the music sources on startup to keep your collection up to date.")

            Switch
            {
                checkable: true
                checked: settings.autoScan
                onToggled: settings.autoScan = !settings.autoScan
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("General")
//        description: i18n("Configure the app plugins and collection behavior.")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Focus View")
            label2.text: i18n("Make the focus view the default.")

            Switch
            {
                Layout.fillHeight: true
                checked: settings.focusViewDefault
                onToggled:
                {
                     settings.focusViewDefault = !settings.focusViewDefault
                }
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Artwork")
            label2.text: i18n("Show the cover artwork for the tracks.")

            Switch
            {
                Layout.fillHeight: true
                checked: settings.showArtwork
                onToggled:
                {
                    settings.showArtwork = !settings.showArtwork
                }
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Titles")
            label2.text: i18n("Show the title of albums and artists in the grid view.")

            Switch
            {
                Layout.fillHeight: true
                checked: settings.showTitles
                onToggled:
                {
                    settings.showTitles = !settings.showTitles
                }
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Sources")
//        description: i18n("Add or remove sources")

        ColumnLayout
        {
            Layout.fillWidth: true
            spacing: Maui.Style.space.medium

            Repeater
            {
                model: Vvave.sources

                delegate: Maui.ListDelegate
                {
                    Layout.fillWidth: true

                    template.iconSource: modelData.icon
                    template.iconSizeHint: Maui.Style.iconSizes.small
                    template.label1.text: modelData.label
                    template.label2.text: modelData.path

                    template.content: ToolButton
                    {
                        icon.name: "edit-clear"
                        flat: true
                        onClicked:
                        {
                            confirmationDialog.url = modelData.path
                            confirmationDialog.open()
                        }
                    }
                }
            }

            Button
            {
                Layout.fillWidth: true
                text: i18n("Add")
                //                flat: true
                onClicked:
                {
                    let props =({'mode' : FB.FileDialog.Modes.Open,
                                    'browser.settings.onlyDirs' : true,
                                    'callback' : function(urls)
                                    {
                                        Vvave.addSources(urls)
                                    }})
                    var dialog = _fileDialogComponent.createObject(root, props)
                    dialog.open()
                }
            }

            Button
            {
                Layout.fillWidth: true
                text: i18n("Scan now")
                onClicked: Vvave.rescan()
            }
        }
    }

}
