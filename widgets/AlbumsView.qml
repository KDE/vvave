import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3

import "../view_models/BabeGrid"
import "../view_models/BabeTable"

import "../db/Queries.js" as Q
import "../utils/Help.js" as H
import "../utils/Player.js" as Player

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.maui.vvave 1.0

StackView
{
    id: control
    clip: true

    property alias list : albumsViewGrid.list

    property string currentQuery: ""
    property string currentAlbum: ""
    property string currentArtist: ""

    property alias holder: albumsViewGrid.holder
    property alias prefix: albumsViewGrid.prefix

    property Flickable flickable : currentItem.flickable

    initialItem: BabeGrid
    {
        id: albumsViewGrid
        onAlbumCoverClicked: control.populateTable(album, artist)
    }

    Component
    {
        id: _tracksTableComponent

        BabeTable
        {
            list.query: control.currentQuery
            trackNumberVisible: true
            coverArtVisible: true
            focus: true
            holder.emoji: "qrc:/assets/media-album-track.svg"
            holder.title : "Oops!"
            holder.body: i18n("This list is empty")
            holder.emojiSize: Maui.Style.iconSizes.huge
            headBar.visible: true
            headBar.farLeftContent: ToolButton
            {
                icon.name: "go-previous"
                onClicked: control.pop()
            }

            onQueueTrack: Player.queueTracks([listModel.get(index)], index)

            onRowClicked: Player.quickPlay(listModel.get(index))
            onAppendTrack: Player.addTrack(listModel.get(index))
            onQuickPlayTrack: Player.quickPlay(listModel.get(index))

            onPlayAll:
            {
                control.pop()
                Player.playAllModel(listModel.list)
            }

            onAppendAll:
            {
                control.pop()
                Player.appendAllModel(listModel.list)
            }
        }
    }

    function populateTable(album, artist)
    {
        control.push(_tracksTableComponent)

        currentAlbum = album === undefined ? "" : album
        currentArtist= artist

        var query
        if(currentAlbum && currentArtist)
        {
            query = Q.GET.albumTracks_.arg(currentAlbum)
            query = query.arg(currentArtist)

        }else if(currentArtist && !currentAlbum.length)
        {
            query = Q.GET.artistTracks_.arg(currentArtist)
        }

        control.currentQuery = query
    }
}

