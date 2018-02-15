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

    property alias list : drawerList.list
    property alias table : drawerList

    signal rowClicked(var track)
    signal playAlbum(var tracks)
    signal playTrack(var track)
    signal queueTrack(var track)
    signal appendAlbum(var tracks)

    //    transform: Translate
    //    {
    //        y: (drawer.height)*-1
    //    }

    onBgClicked: if(drawer.visible) drawer.close()
    onFocusChanged:  drawer.close()

    Drawer
    {
        id: drawer

        y: parent.height-height-root.footer.height

        width: pageStack.wideMode ? albumsViewGrid.width-1 : albumsViewGrid.width

        height:
        {
            var customHeight = (drawerList.count*rowHeight)+toolBarHeight

            if(customHeight > parent.height)
                parent.height - root.header.height - root.footer.height
            else
            {
                if(customHeight < parent.height*0.4)
                    (parent.height*0.4) - root.footer.height
                else
                    customHeight - root.footer.height
            }
        }

        edge: Qt.RightEdge
        interactive: false
        focus: true
        modal: root.isMobile
        dragMargin: 0
        margins: 0
        spacing: 0

        onOpened: drawerList.forceActiveFocus()

        enter: Transition
        {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0 }
        }

        exit: Transition
        {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0 }
        }

        background: Rectangle
        {
            anchors.fill: parent
            z: -999
            color: altColor
        }

        BabeTable
        {
            id: drawerList
            anchors.fill: parent
            trackNumberVisible: true
            headerBarVisible: true
            headerBarExit: true
            coverArtVisible: true
            quickPlayVisible: true
            focus: true

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

            onExit: drawer.close()

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

    }

    onAlbumCoverClicked:
    {
        drawerList.headerBarTitle = album
        drawer.open()
        list.clearTable()

        var query = Q.GET.albumTracks_.arg(album)
        query = query.arg(artist)

        var map = bae.get(query)

        if(map.length > 0)
            for(var i in map)
                drawerList.model.append(map[i])
    }

    onAlbumCoverPressed:
    {
        var query = Q.GET.albumTracks_.arg(album)
        query = query.arg(artist)

        var map = bae.get(query)
        playAlbum(map)
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
