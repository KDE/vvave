import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3

import "../view_models/BabeGrid"
import "../view_models/BabeTable"

import "../db/Queries.js" as Q
import "../utils/Help.js" as H

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import TracksList 1.0
import AlbumsList 1.0

StackView
{
    id: control
    clip: true

    property string currentAlbum: ""
    property string currentArtist: ""
    
    property var tracks: []
    
    property alias table : _tracksTable
    property alias listModel : _tracksTable.listModel
    property alias holder: albumsViewGrid.holder
    property alias list : albumsViewGrid.list

    signal rowClicked(var track)
    signal playTrack(var track)
    signal queueTrack(var track)
    signal appendTrack(var track)

    signal appendAll(string album, string artist)
    signal playAll(string album, string artist)
    signal albumCoverClicked(string album, string artist)
    signal albumCoverPressedAndHold(string album, string artist)

    property Flickable flickable : currentItem.flickable

    initialItem: BabeGrid
    {
        id: albumsViewGrid
        onAlbumCoverPressed: control.albumCoverPressedAndHold(album, artist)
        onAlbumCoverClicked: control.albumCoverClicked(album, artist)
        headBar.visible: false
    }

    BabeTable
    {
        id: _tracksTable
        showTitle: false
        trackNumberVisible: true
        coverArtVisible: true
        focus: true
        list.sortBy: Tracks.TRACK
        holder.emoji: "qrc:/assets/dialog-information.svg"
        holder.isMask: false
        holder.title : "Oops!"
        holder.body: qsTr("This list is empty")
        holder.emojiSize: Maui.Style.iconSizes.huge
        headBar.visible: true
        headBar.farLeftContent: ToolButton
        {
            icon.name: "go-previous"
            onClicked: control.pop()
        }

        onRowClicked:
        {
            control.rowClicked(listModel.get(index))
        }

        onQuickPlayTrack:
        {
            control.playTrack(listModel.get(index))
        }

        onQueueTrack:
        {
            control.queueTrack(listModel.get(index))
        }

        onAppendTrack:
        {
            control.appendTrack(listModel.get(index))
        }

        onPlayAll:
        {
            control.pop()
            control.playAll(currentAlbum, currentArtist)
        }

        onAppendAll:
        {
            control.pop()
            control.appendAll(currentAlbum, currentArtist)
        }
    }

    function populateTable(album, artist)
    {
        console.log("PAPULATE ALBUMS VIEW")
        control.push(_tracksTable)
        _tracksTable.listModel.filter = ""

        var query = ""
        var tagq = ""

        currentAlbum = album === undefined ? "" : album
        currentArtist= artist

        if(album && artist)
        {
            query = Q.GET.albumTracks_.arg(album)
            query = query.arg(artist)
            _tracksTable.title = album
            tagq = Q.GET.albumTags_.arg(album)

        }else if(artist && album === undefined)
        {
            query = Q.GET.artistTracks_.arg(artist)
            _tracksTable.title = artist
            tagq = Q.GET.artistTags_.arg(artist)
        }

        _tracksTable.list.query = query

    }

    function filter(tracks)
    {
        var matches = []

        for(var i = 0; i<tracks.length; i++)
            matches.push(find(tracks[i].album))

        for(var j = 0 ; j < albumsViewGrid.gridModel.count; j++)
            albumsViewGrid.gridModel.remove(j,1)


        //        for(var match in matches)
        //        {
        //            albumsViewGrid.gridModel.get(match).hide = true
        //            console.log(match)
        //        }
    }

    function find(query)
    {
        var indexes = []
        for(var i = 0 ; i < albumsViewGrid.gridModel.count; i++)
            if(albumsViewGrid.gridModel.get(i).album.includes(query))
                indexes.push(i)

    }
}

