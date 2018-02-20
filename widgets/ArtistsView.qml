import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami

import "../view_models/BabeGrid"
import "../view_models/BabeTable"

import "../db/Queries.js" as Q

BabeGrid
{
    id: artistsViewGrid
    visible: true
    //    albumCardVisible: false
    //    albumCoverRadius: Math.min(albumCoverSize, albumCoverSize)
    property alias list : drawerList.list
    property alias table : drawerList
    property int customHeight : (drawerList.count*rowHeight)+toolBarHeight

    signal rowClicked(var track)
    signal playAlbum(var tracks)
    signal playTrack(var track)
    signal queueTrack(var track)
    signal appendAlbum(var tracks)

    //        transform: Translate
    //        {
    //            y: (drawer.position * artistsViewGrid.height)*-1
    //        }

    onBgClicked: if(drawer.visible) drawer.close()
    onFocusChanged:  drawer.close()

    Drawer
    {
        id: drawer

        y: parent.height-height-root.footer.height

        width: pageStack.wideMode ? artistsViewGrid.width-1 : artistsViewGrid.width

        height:
        {
            if(customHeight > parent.height)
                 (parent.height*0.9) - root.header.height - root.footer.height
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
            onRowClicked:
            {
                drawer.close()
                artistsViewGrid.rowClicked(model.get(index))
            }

            onQuickPlayTrack:
            {
                drawer.close()
                artistsViewGrid.playTrack(model.get(index))
            }

            onQueueTrack:
            {
                drawer.close()
                artistsViewGrid.queueTrack(model.get(index))
            }

            onPlayAll:
            {
                drawer.close()
                var data = artistsViewGrid.gridModel.get(artistsViewGrid.grid.currentIndex)

                var query = Q.GET.artistTracks_.arg(data.artist)
                var tracks = bae.get(query)
                artistsViewGrid.playAlbum(tracks)
            }

            onAppendAll:
            {
                var data = artistsViewGrid.gridModel.get(artistsViewGrid.grid.currentIndex)
                var query = Q.GET.artistTracks_.arg(data.artist)
                var tracks = bae.get(query)
                artistsViewGrid.appendAlbum(tracks)
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
        drawerList.headerBarTitle = artist
        drawer.open()
        table.clearTable()
        var query = Q.GET.artistTracks_.arg(artist)
        var map = bae.get(query)

        if(map.length > 0)
            for(var i in map)
                drawerList.model.append(map[i])

    }

    onAlbumCoverPressed:
    {
        var query = Q.GET.artistTracks_.arg(artist)
        var map = bae.get(query)
        playAlbum(map)
    }

    function populate()
    {
        var map = bae.get(Q.GET.allArtistsAsc)

        if(map.length > 0)
            for(var i in map)
                gridModel.append(map[i])
    }


    Component.onCompleted: populate()


}
