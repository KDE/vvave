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
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

MauiLab.SettingsDialog
{
    id: control

    property bool fetchArtwork : Maui.FM.loadSettings("Settings", "FetchArtwork", true)
    property bool scanCollectionOnStartUp : Maui.FM.loadSettings("Settings", "ScanCollectionOnStartUp", true)
    property bool darkMode:  Maui.FM.loadSettings("Settings", "DarkMode", false)

    MauiLab.SettingsSection
    {
        title: qsTr("Behaviour")
        description: qsTr("Configure the app plugins and behavior.")

        Switch
        {
            Layout.fillWidth: true
            checkable: true
            checked:  control.fetchArtwork
            Kirigami.FormData.label: qsTr("Fetch Artwork Online")
            onToggled:
            {
                control.fetchArtwork = !control.fetchArtwork
                Maui.FM.saveSettings("Settings", control.fetchArtWork, "FetchArtwork")
            }
        }

        Switch
        {
            Layout.fillWidth: true
            Kirigami.FormData.label: qsTr("Scan Collection on Start Up")
            checkable: true
            checked: control.scanCollectionOnStartUp
            onToggled:
            {
                control.scanCollectionOnStartUp = !control.scanCollectionOnStartUp
                Maui.FM.saveSettings("Settings", control.scanCollectionOnStartUp, "ScanCollectionOnStartUp")
            }
        }
    }

    MauiLab.SettingsSection
    {
        title: qsTr("Interface")
        description: qsTr("Configure the app UI.")

        Switch
        {
            Kirigami.FormData.label: qsTr("Translucent Sidebar")
            checkable: true
            checked:  root.translucency
            onToggled:  root.translucency = !root.translucency
        }

        Switch
        {
            Layout.fillWidth: true
            Kirigami.FormData.label: qsTr("Dark Mode")
            checkable: true
            checked: control.darkMode
            onToggled: control.darkMode = !control.darkMode
        }
    }
}
