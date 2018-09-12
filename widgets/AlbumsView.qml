import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import "../view_models/BabeGrid"
import "../view_models/BabeTable"

import "../db/Queries.js" as Q
import "../utils/Help.js" as H
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui


Kirigami.PageRow
{
    id: albumsPageRoot
    clip: true
    separatorVisible: wideMode
    initialPage: [albumsViewGrid, albumFilter]
    defaultColumnWidth: width
    interactive: currentIndex  === 1

    property string currentAlbum: ""
    property string currentArtist: ""

    property var tracks: []

    property alias grid : albumsViewGrid
    property alias table : albumsViewTable
    property alias tagBar : tagBar

    signal rowClicked(var track)
    signal playTrack(var track)
    signal queueTrack(var track)

    signal appendAll(string album, string artist)
    signal playAll(string album, string artist)
    signal albumCoverClicked(string album, string artist)
    signal albumCoverPressedAndHold(string album, string artist)

    BabeGrid
    {
        id: albumsViewGrid
        visible: true
        topPadding: space.large
        onAlbumCoverClicked: albumsPageRoot.albumCoverClicked(album, artist)
        onAlbumCoverPressed: albumCoverPressedAndHold(album, artist)

    }

    ColumnLayout
    {
        id: albumFilter
        anchors.fill: parent
        spacing: 0

        BabeTable
        {
            id: albumsViewTable
            Layout.fillHeight: true
            Layout.fillWidth: true
            trackNumberVisible: true
            headBarVisible: true
            headBarExit:  !albumsPageRoot.wideMode
            headBarExitIcon: "go-previous"
            coverArtVisible: true
            quickPlayVisible: true
            focus: true

            holder.emoji: "qrc:/assets/ElectricPlug.png"
            holder.isMask: false
            holder.title : "Oops!"
            holder.body: "This list is empty"
            holder.emojiSize: iconSizes.huge

            onRowClicked:
            {
                albumsPageRoot.rowClicked(model.get(index))
            }

            onQuickPlayTrack:
            {
                albumsPageRoot.playTrack(model.get(index))
            }

            onQueueTrack:
            {
                albumsPageRoot.queueTrack(model.get(index))
            }

            onPlayAll:
            {
                albumsPageRoot.currentIndex = 0
                albumsPageRoot.playAll(currentAlbum, currentArtist)
            }

            onAppendAll:
            {
                albumsPageRoot.currentIndex = 0
                albumsPageRoot.appendAll(currentAlbum, currentArtist)
            }

            onExit: albumsPageRoot.currentIndex = 0

        }

        Maui.TagsBar
        {
            id: tagBar
            Layout.fillWidth: true
            allowEditMode: false
            onTagClicked: H.searchFor("tag:"+tag)
        }
    }

    function populate(query)
    {
        var map = bae.get(query)

        if(map.length > 0)
            for(var i in map)
                grid.gridModel.append(map[i])
    }

    function populateTable(album, artist)
    {
        console.log("PAPULATE ALBUMS VIEW")

        table.clearTable()

        albumsPageRoot.currentIndex = 1
        var query = ""
        var tagq = ""

        currentAlbum = album === undefined ? "" : album
        currentArtist= artist

        if(album && artist)
        {
            query = Q.GET.albumTracks_.arg(album)
            query = query.arg(artist)
            albumsView.table.headBarTitle = album
            tagq = Q.GET.albumTags_.arg(album)

        }else if(artist && album === undefined)
        {
            query = Q.GET.artistTracks_.arg(artist)
            artistsView.table.headBarTitle = artist
            tagq = Q.GET.artistTags_.arg(artist)
        }

        tracks = bae.get(query)

        if(tracks.length > 0)
        {
            for(var i in tracks)
                albumsViewTable.model.append(tracks[i])

            tagq = tagq.arg(artist)
            var tags = bae.get(tagq)
            console.log(tagq, "TAGS", tags)
            tagBar.populate(tags)
        }
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

