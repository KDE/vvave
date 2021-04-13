import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.mauikit.controls 1.3 as Maui
import org.kde.kirigami 2.7 as Kirigami

import org.maui.vvave 1.0 as Vvave

import "../../view_models"

Item
{
    id: control

    Vvave.TrackInfo
    {
        id: _trackInfo
        track : root.currentTrack
    }

    Kirigami.ScrollablePage
    {
        anchors.fill: parent

        background: Rectangle
        {
            color: Kirigami.Theme.backgroundColor
            radius: Maui.Style.radiusV
            opacity: 0.3
        }

        ColumnLayout
        {
            width: parent.width

            Maui.ListItemTemplate
            {
                Layout.fillWidth: true
                label1.text: currentTrack.artist
                label1.font.pointSize: Maui.Style.fontSizes.huge
                label1.font.bold: true
                label1.font.weight: Font.Black
                imageSource: "image://artwork/artist:" + currentTrack.artist
                iconSizeHint: Maui.Style.iconSizes.huge
            }

            TextArea
            {
                Layout.fillWidth: true
                readOnly: true
                text: _trackInfo.artistWiki


                background: null
            }


            Maui.ListItemTemplate
            {
                Layout.fillWidth: true
                label1.text: currentTrack.album
                label1.font.pointSize: Maui.Style.fontSizes.huge
                label1.font.bold: true
                label1.font.weight: Font.Black
                imageSource: "image://artwork/album:" + currentTrack.artist+":"+currentTrack.album
                iconSizeHint: Maui.Style.iconSizes.huge
            }

            TextArea
            {
                Layout.fillWidth: true
                readOnly: true
                text: _trackInfo.albumWiki

                background: null
            }
        }
    }

}
