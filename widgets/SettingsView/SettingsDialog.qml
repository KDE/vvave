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

import QtQuick 2.9
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

import org.maui.vvave 1.0

import "../../utils/Help.js" as H

Maui.SettingsDialog
{
    id: control

    property bool fetchArtwork : Maui.FM.loadSettings("Settings", "FetchArtwork", true)
    property bool scanCollectionOnStartUp : Maui.FM.loadSettings("Settings", "ScanCollectionOnStartUp", true)
    property bool darkMode:  Maui.FM.loadSettings("Settings", "DarkMode", false)

    Maui.Dialog
    {
        id: confirmationDialog
        property string url : ""

        page.margins: Maui.Style.space.medium
        title : "Remove source"
        message : "Are you sure you want to remove the source: \n "+url

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

        Switch
        {
            Layout.fillWidth: true
            checkable: true
            checked:  control.fetchArtwork
            Kirigami.FormData.label: i18n("Fetch Artwork Online")
            onToggled:
            {
                control.fetchArtwork = !control.fetchArtwork
                Maui.FM.saveSettings("Settings", control.fetchArtWork, "FetchArtwork")
            }
        }

        Switch
        {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Scan Collection on Start Up")
            checkable: true
            checked: control.scanCollectionOnStartUp
            onToggled:
            {
                control.scanCollectionOnStartUp = !control.scanCollectionOnStartUp
                Maui.FM.saveSettings("Settings", control.scanCollectionOnStartUp, "ScanCollectionOnStartUp")
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Interface")
        description: i18n("Configure the app UI.")

        Switch
        {
            Kirigami.FormData.label: i18n("Translucent Sidebar")
            checkable: true
            checked:  root.translucency
            onToggled:  root.translucency = !root.translucency
        }

        Switch
        {
            Layout.fillWidth: true
            Kirigami.FormData.label: i18n("Dark Mode")
            checkable: true
            checked: control.darkMode
            onToggled: control.darkMode = !control.darkMode
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Sources")
        description: i18n("Add new sources to manage and browse your image collection")

        ColumnLayout
        {
            anchors.fill: parent
            spacing: Maui.Style.space.big
            Layout.margins: Maui.Style.space.big

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
                    implicitHeight: Maui.Style.rowHeight * 1.2
                    leftPadding: 0
                    rightPadding: 0
                    template.iconSource: modelData.icon
                    template.iconSizeHint: Maui.Style.iconSizes.small
                    template.label1.text: modelData.label
                    template.label2.text: modelData.path
                    onClicked: _sourcesList.currentIndex = index
                }

//                Maui.Holder
//                {
//                    anchors.fill: parent
//                    visible: !_sourcesList.count
//                    emoji: "qrc:/assets/dialog-information.svg"
//                    isMask: true
//                    title : i18n("No Sources!")
//                    body: i18n("Add new sources to organize and play your music collection")
//                    emojiSize: Maui.Style.iconSizes.huge
//                }
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
                        _dialogLoader.sourceComponent = _fmDialogComponent
                        root.dialog.settings.onlyDirs = true
                        root.dialog.show(function(paths)
                        {
                            console.log("SCAN DIR <<", paths)
                            Vvave.addSources([paths])
                        })
                    }
                }
            }
        }
    }
}
