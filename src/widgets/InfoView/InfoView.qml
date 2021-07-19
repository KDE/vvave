import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.kde.kirigami 2.7 as Kirigami

import org.maui.vvave 1.0 as Vvave

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
            opacity: 0.5
        }

        ColumnLayout
        {
            width: parent.width
            spacing: Maui.Style.space.big

            Maui.ListItemTemplate
            {
                Layout.fillWidth: true
                implicitHeight: Maui.Style.toolBarHeight
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
                implicitHeight: Maui.Style.toolBarHeight

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

}
