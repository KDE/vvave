import QtQuick 2.15
import QtQuick.Controls 2.15

import org.mauikit.controls 1.3 as Maui

import "BabeGrid"
import "BabeTable"

import "../db/Queries.js" as Q
import "../utils/Player.js" as Player

StackView
{
    id: control

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
        holder.emoji: "qrc:/assets/dialog-information.svg"
        holder.actions:[

            Action
            {
                text: i18n("Add sources")
                onTriggered: openSettingsDialog()
            }
        ]

        onAlbumCoverClicked: control.populateTable(album, artist)
        onPlayAll:
        {
            var query
            if(album && artist)
            {
            query = Q.GET.albumTracks_.arg(album)
            query = query.arg(artist)
            }else if(artist && !album)
            {
              query = Q.GET.artistTracks_.arg(artist)
            }

            Player.playQuery(query)
        }
    }

    Component
    {
        id: _tracksTableComponent

        BabeTable
        {
            list.query: control.currentQuery
            trackNumberVisible: true
            coverArtVisible: settings.showArtwork
            focus: true

            holder.emoji: "qrc:/assets/media-album-track.svg"
            holder.title : "Oops!"
            holder.body: i18n("This list is empty")

            headBar.visible: true
            headBar.farLeftContent: ToolButton
            {
                icon.name: "go-previous"
                text: control.prefix === "album"  ? i18n("Albums") : i18n("Artists")
                onClicked: control.pop()
            }

            onQueueTrack: Player.queueTracks([listModel.get(index)], index)
            onRowClicked: Player.quickPlay(listModel.get(index))
            onAppendTrack: Player.addTrack(listModel.get(index))

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
        currentArtist = artist

        var query
        if(currentAlbum && currentArtist)
        {
            query = Q.GET.albumTracks_.arg(currentAlbum)
            query = query.arg(currentArtist)

        }else if(currentArtist && !currentAlbum.length)
        {
            query = Q.GET.artistTracks_.arg(currentArtist)
        }

        console.log("GET ARTIST OR ALBUM BY", album, artist)
        control.currentQuery = query
    }

    function getFilterField() : Item
    {
        return control.currentItem.getFilterField()
    }

    function getGoBackFunc() : Function
    {
        if (control.depth > 1)
            return () => { control.pop() }
        else
            return null
    }
}

