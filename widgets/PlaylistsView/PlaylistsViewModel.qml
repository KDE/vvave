import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.10
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.2 as Maui

import org.maui.vvave 1.0

import "../../utils"

import "../../view_models"
import "../../widgets"
import "../../db/Queries.js" as Q
import "../../utils/Help.js" as H

Maui.GridView
{
    id: control
    itemSize: Math.min(260, Math.max(140, Math.floor(width* 0.3)))
    itemHeight: itemSize

    holder.emoji:  "qrc:/assets/dialog-information.svg"
    holder.title : i18n("No Playlists!")
    holder.body: i18n("Start creating new custom playlists")

    holder.emojiSize: Maui.Style.iconSizes.huge
    holder.visible: control.count === 0

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

    delegate : Maui.GalleryRollItem
    {
        id: _collageDelegate
        height: control.cellHeight
        width: control.cellWidth

        isCurrentItem: GridView.isCurrentItem
        images: model.preview.split(",")

        label1.text: model.playlist
        label2.text: model.description
        template.iconSource: model.icon

        onClicked :
        {
            control.currentIndex = index
            if(Maui.Handy.singleClick)
            {
                populate(model.playlist, true)
            }
        }

        onDoubleClicked :
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick)
            {
                populate(model.playlist, true)
            }
        }

        onRightClicked:
        {
            control.currentIndex = index
            currentPlaylist = model.playlist
        }

        onPressAndHold:
        {
            control.currentIndex = index
            currentPlaylist = model.playlist
        }
    }

}
