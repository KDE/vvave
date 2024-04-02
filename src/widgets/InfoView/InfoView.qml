import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui

import org.maui.vvave as Vvave

Maui.Page
{
    id: control

    Vvave.TrackInfo
    {
        id: _trackInfo
        track : root.currentTrack
    }

    Maui.ScrollColumn
    {
        anchors.fill: parent
        spacing: Maui.Style.space.big
        clip: true

        Maui.ListItemTemplate
        {
            Layout.fillWidth: true
            maskRadius: Maui.Style.radiusV

            label1.text: currentTrack.artist
            label1.font.pointSize: Maui.Style.fontSizes.huge
            label1.font.bold: true
            label1.font.weight: Font.Black
            label2.text: i18n("Artist Info")

            imageSource: "image://artwork/artist:" + currentTrack.artist
            iconSizeHint: Maui.Style.iconSizes.huge
        }

        TextArea
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            readOnly: true
            text: _trackInfo.artistWiki
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            textFormat: Text.RichText

            background: null
        }


        Maui.ListItemTemplate
        {
            Layout.fillWidth: true
            maskRadius: Maui.Style.radiusV

            label1.text: currentTrack.album
            label1.font.pointSize: Maui.Style.fontSizes.huge
            label1.font.bold: true
            label1.font.weight: Font.Black
            label2.text: i18n("Album Info")
            imageSource: "image://artwork/album:" + currentTrack.artist+":"+currentTrack.album
            iconSizeHint: Maui.Style.iconSizes.huge
        }

        TextArea
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            readOnly: true
            text: _trackInfo.albumWiki
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            textFormat: Text.RichText

            background: null
        }
    }
}
