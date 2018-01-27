import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import "../view_models/BabeGrid"
import "../view_models/BabeTable"

import "../db/Queries.js" as Q
import org.kde.kirigami 2.2 as Kirigami

BabeGrid
{
    id: albumsViewGrid
    visible: true

//    property int hintSize : Math.sqrt(root.width*root.height)*0.25
//    albumSize:
//    {
//        if(hintSize > 150)
//            150
//        else if (hintSize < 100)
//            root.isMobile && hintSize < 100 ? 100 : 130
//        else
//            hintSize
//    }

    signal rowClicked(var track)
    signal playAlbum(var tracks)
    signal playTrack(var track)
    signal queueTrack(var track)
    signal appendAlbum(var tracks)

//    transform: Translate
//    {
//        y: (drawer.position * albumsViewGrid.height * 0.33)*-1
//    }

    onBgClicked: if(drawer.visible) drawer.close()
    onFocusChanged:  drawer.close()

    Drawer
    {
        id: drawer

        height:  parent.height * 0.4
//        x: albumsViewGrid.width/2
        width: parent.width
        edge: Qt.BottomEdge
        interactive: false
        focus: true
        modal: root.isMobile
        dragMargin: 0
        Component.onCompleted: drawerList.forceActiveFocus()

        background: Rectangle
        {
            anchors.fill: parent
            z: -999
            color: bae.altColor()
            Kirigami.Separator
            {
                Rectangle
                {
                    anchors.fill: parent
                    color: Kirigami.Theme.viewFocusColor
                }

                anchors
                {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
            }
        }

        Column
        {
            anchors.fill: parent

            BabeTable
            {
                id: drawerList
                width: parent.width
                height: parent.height
                trackNumberVisible: true
                headerBar: true
                headerClose: true
                coverArtVisible: true
                quickPlayVisible: true

                onRowClicked:
                {
                    drawer.close()
                    albumsViewGrid.rowClicked(model.get(index))
                }

                onQuickPlayTrack:
                {
                    drawer.close()
                    albumsViewGrid.playTrack(model.get(index))
                }

                onQueueTrack:
                {
                    albumsViewGrid.queueTrack(model.get(index))
                    drawer.close()
                }

                onPlayAll:
                {
                    drawer.close()

                    var data = albumsViewGrid.gridModel.get(albumsViewGrid.grid.currentIndex)
                    var query = Q.GET.albumTracks_.arg(data.album)
                    query = query.arg(data.artist)
                    var tracks = bae.get(query)

                    albumsViewGrid.playAlbum(tracks)
                }

                onAppendAll:
                {
                    var data = albumsView.gridModel.get(albumsViewGrid.grid.currentIndex)
                    var query = Q.GET.albumTracks_.arg(data.album)
                    query = query.arg(data.artist)
                    var tracks = bae.get(query)
                    albumsViewGrid.appendAlbum(tracks)
                    drawer.close()
                }

                onHeaderClosed: drawer.close()
            }

        }
    }

    onAlbumCoverClicked:
    {
        drawerList.headerTitle = album
        drawer.open()
        drawerList.clearTable()

        var query = Q.GET.albumTracks_.arg(album)
        query = query.arg(artist)

        var map = bae.get(query)

        if(map.length > 0)
            for(var i in map)
                drawerList.model.append(map[i])
    }


    function populate()
    {
        var map = bae.get(Q.GET.allAlbumsAsc)

        if(map.length > 0)
            for(var i in map)
                gridModel.append(map[i])
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

    Component.onCompleted: populate()
}
