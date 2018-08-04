import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import "../view_models/BabeGrid"
import "../view_models/BabeTable"

import "../db/Queries.js" as Q
import "../utils/Help.js" as H
import org.kde.kirigami 2.2 as Kirigami
import org.kde.maui 1.0 as Maui


Kirigami.PageRow
{
    id: albumsPageRoot
    clip: true
    separatorVisible: wideMode
    initialPage: [albumsViewGrid, albumFilter]
    defaultColumnWidth: albumsViewGrid.albumCoverSize * 4
    interactive: currentIndex  === 1

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
                var data = albumsViewGrid.gridModel.get(albumsViewGrid.grid.currentIndex)
                albumsPageRoot.playAll(data.album, data.artist)
            }

            onAppendAll:
            {
                albumsPageRoot.currentIndex = 0
                var data = albumsViewGrid.gridModel.get(albumsViewGrid.grid.currentIndex)
                albumsPageRoot.appendAll(data.album, data.artist)
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

    function populateTable(query)
    {
        table.clearTable()

        albumsPageRoot.currentIndex = 1

        tracks = bae.get(query)

        if(tracks.length > 0)
            for(var i in tracks)
                albumsViewTable.model.append(tracks[i])
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

