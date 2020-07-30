import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.10
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import PlaylistsList 1.0
import TracksList 1.0

import "../../utils"

import "../../view_models"
import "../../db/Queries.js" as Q
import "../../utils/Help.js" as H

Maui.GridView
{
    id: control

    itemSize: Math.min(200, control.width)
    itemHeight: 90
    margins: Kirigami.Settings.isMobile ? 0 : Maui.Style.space.big

    Maui.Holder
    {
        id: holder
        emoji:  "qrc:/assets/dialog-information.svg"
        title : i18n("No Playlists!")
        body: i18n("Start creating new custom playlists")

        emojiSize: Maui.Style.iconSizes.huge
        visible: control.count === 0

        onActionTriggered: newPlaylistDialog.open()
    }

    Menu
    {
        id: _playlistMenu

        MenuItem
        {
            text: i18n("Play")
            onTriggered: populate(Q.GET.playlistTracks_.arg(currentPlaylist), true)
        }

        MenuItem
        {
            text: i18n("Rename")
        }

        MenuSeparator{}

        MenuItem
        {
            text: i18n("Delete")
            Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
            onTriggered: removePlaylist()
        }
    }

    model: Maui.BaseModel
    {
        id: _playlistsModel
        list: playlistsList
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    function randomHexColor()
    {
        var color = '#', i = 5;
        do{ color += "0123456789abcdef".substr(Math.random() * 16,1); }while(i--);
        return color;
    }

    delegate : Maui.ItemDelegate
    {
        id: delegate
        readonly property color m_color: model.color

        Kirigami.Theme.inherit: false
        Kirigami.Theme.backgroundColor: Qt.rgba(m_color.r, m_color.g, m_color.b, 0.9)
        Kirigami.Theme.textColor: "white"

        height: control.cellHeight - Maui.Style.space.medium
        width: control.cellWidth - Maui.Style.space.medium
        isCurrentItem: GridView.isCurrentItem

        Rectangle
        {
            anchors.fill: parent
            radius: 8
            color: m_color
        }

        Maui.ListItemTemplate
        {
            anchors.fill: parent
            anchors.margins: Maui.Style.space.medium
            iconSizeHint: Maui.Style.iconSizes.big
            label1.text: model.playlist
            label1.font.pointSize: Maui.Style.fontSizes.big
            label1.font.weight: Font.Bold
            label1.font.bold: true
            label2.text: model.description
            iconSource: model.icon
            iconVisible: true
        }

        onClicked :
        {
            control.currentIndex = index
            if(Maui.Handy.singleClick)
            {
                filterList.group = false
                populate(playlistsList.get(index).playlist, true)
            }
        }

        onDoubleClicked :
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick)
            {
                filterList.group = false
                populate(playlistsList.get(index).playlist, true)
            }
        }

        onRightClicked:
        {
            control.currentIndex = index
            currentPlaylist = playlistsList.get(index).playlist
            _playlistMenu.popup()
        }

        onPressAndHold:
        {
            control.currentIndex = index
            currentPlaylist = playlistsList.get(index).playlist
            _playlistMenu.popup()
        }

    }

    //            Item
    //            {
    //                Layout.fillWidth: true
    //                Layout.margins: Maui.Style.space.medium
    //                Layout.preferredHeight:  Maui.Style.rowHeight
    //                ColorTagsBar
    //                {
    //                    anchors.fill: parent
    //                    onColorClicked: populate(Q.GET.colorTracks_.arg(color.toLowerCase()), true)
    //                }
    //            }
    //        }
    //    }
}
