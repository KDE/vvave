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

import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.2 as Maui

import org.maui.vvave 1.0

Maui.SettingsDialog
{
    id: control

    Maui.Dialog
    {
        id: confirmationDialog
        property string url : ""

        title : "Remove source"
        message : "Are you sure you want to remove the source: \n "+url
        template.iconSource: "emblem-warning"
        page.margins: Maui.Style.space.big

        onAccepted:
        {
            if(url.length>0)
                Vvave.removeSource(url)
            confirmationDialog.close()
        }
        onRejected: confirmationDialog.close()
    }

    Maui.SettingsSection
    {
        title: i18n("Behaviour")
        description: i18n("Configure the app plugins and behavior.")

        Maui.SettingTemplate
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

        Maui.SettingTemplate
        {
            label1.text: i18n("Auto Scan")
            label2.text: i18n("Scan all the music sources on startup to keep your collection up to date")

            Switch
            {
                checkable: true
                checked: settings.autoScan
                onToggled: settings.autoScan = !settings.autoScan
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Focus View")
            label2.text: i18n("Make the focus view the default")

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

        Maui.SettingTemplate
        {
            label1.text: i18n("Dark Mode")
            label2.text: i18n("Switch between light and dark colorscheme")

            Switch
            {
                Layout.fillHeight: true
                checked: Maui.App.darkMode
                onToggled:
                {
                     settings.darkMode = !settings.darkMode
                    Maui.App.darkMode = settings.darkMode
                    setAndroidStatusBarColor()
                }
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Sources")
        description: i18n("Add or remove sources")
        lastOne: true

        //        template.template.content: ToolButton
        //        {
        //            icon.name: "list-add"
        //            onClicked:
        //            {
        //                _dialogLoader.sourceComponent = _fileDialogComponent
        //                dialog.settings.onlyDirs = true
        //                dialog.callback = function(urls)
        //                {
        //                    Vvave.addSources(urls)
        //                }
        //                dialog.open()
        //            }
        //        }

        ColumnLayout
        {
            Layout.fillWidth: true
            spacing: Maui.Style.space.big

            Maui.ListBrowser
            {

                id: _sourcesList
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.minimumHeight: Math.min(500, contentHeight)
                model: Vvave.sources
                currentIndex: -1
                padding: 0

                delegate: Maui.ListDelegate
                {
                    width: ListView.view.width
                    implicitHeight: Maui.Style.rowHeight * 1.5
                    leftPadding: 0
                    rightPadding: 0
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
                    _dialogLoader.sourceComponent = _fileDialogComponent
                    dialog.settings.onlyDirs = true
                    dialog.callback = function(urls)
                    {
                        Vvave.addSources(urls)
                    }
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
