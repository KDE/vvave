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
import QtQml 2.14
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

import org.maui.vvave 1.0

import "../../utils/Help.js" as H

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
    }

    Maui.SettingsSection
    {
        title: i18n("Interface")
        description: i18n("Configure the app UI.")

        Maui.SettingTemplate
        {
            id: _darkMode
            enabled: false

            label1.text: i18n("Dark Mode")

            Switch
            {
                checkable: true
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Sources")
        description: i18n("Add new sources to manage and browse your image collection")
        lastOne: true

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
                delegate: Maui.ListDelegate
                {
                    width: parent.width
                    implicitHeight: Maui.Style.rowHeight * 1.5
                    leftPadding: 0
                    rightPadding: 0
                    template.iconSource: modelData.icon
                    template.iconSizeHint: Maui.Style.iconSizes.small
                    template.label1.text: modelData.label
                    template.label2.text: modelData.path
                    onClicked: _sourcesList.currentIndex = index
                }
            }

            RowLayout
            {
                Layout.fillWidth: true
                Button
                {
                    Layout.fillWidth: true
                    text: i18n("Remove")
                    onClicked:
                    {
                        confirmationDialog.url = _sourcesList.model[_sourcesList.currentIndex].path
                        confirmationDialog.open()
                    }
                }

                Button
                {
                    Layout.fillWidth: true
                    text: i18n("Add")
                    onClicked:
                    {
                        fileDialog.open()
                    }
                }
            }
        }
    }

        Maui.FileDialog
        {
            id: fileDialog
            settings.onlyDirs: true
            onFinished:  Vvave.addSources(urls)
        }

}
