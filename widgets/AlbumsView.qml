import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import "../view_models"
import "../utils/Icons.js" as MdiFont
import "../utils"
import "../db/Queries.js" as Q

BabeGrid
{
    id: albumsViewGrid
    visible: true

    property int hintSize : Math.sqrt(root.width*root.height)*0.25
    albumSize:
    {
        if(hintSize>200)
            200
        else if (hintSize < 150)
            bae.isMobile() && hintSize < 120 ? 120 : 150
        else
            hintSize
    }

    signal rowClicked(var track)
    signal playAlbum(var tracks)
    signal playTrack(var track)
    signal queueTrack(var track)
    signal appendAlbum(var tracks)

    transform: Translate
    {
        y: (drawer.position * albumsViewGrid.height * 0.33)*-1
    }

    Drawer
    {
        id: drawer
        height: parent.height * 0.4
        width: parent.width
        edge: Qt.BottomEdge
        interactive: false
        focus: true
        modal:true
        background: Rectangle
        {
            anchors.fill: parent
            z: -999
            color: bae.altColor()
        }

        Column
        {
            anchors.fill: parent

            Rectangle
            {
                id: titleBar
                width: parent.width
                height: 48
                z: 1
                color: bae.midColor()
                Row
                {
                    anchors.fill: parent

                    ToolButton
                    {
                        id: playAllBtn

                        width: parent.height
                        height: parent.height

                        Icon {text: MdiFont.Icon.playBoxOutline}

                        onClicked:
                        {
                            drawer.close()

                            var data = albumsViewGrid.gridModel.get(albumsViewGrid.grid.currentIndex)
                            var query = Q.Query.albumTracks_.arg(data.album)
                            query = query.arg(data.artist)
                            var tracks = bae.get(query)

                            albumsViewGrid.playAlbum(tracks)
                        }
                    }

                    ToolButton
                    {
                        id: appendBtn

                        width: parent.height
                        height: parent.height

                        Icon {text: MdiFont.Icon.playlistPlus}

                        onClicked:
                        {
                            var data = albumsView.gridModel.get(albumsViewGrid.grid.currentIndex)
                            var query = Q.Query.albumTracks_.arg(data.album)
                            query = query.arg(data.artist)
                            var tracks = bae.get(query)
                            albumsViewGrid.appendAlbum(tracks)
                            drawer.close()

                        }
                    }

                    Label
                    {
                        id: albumTitle
                        width: parent.width - closeBtn.width - playAllBtn.width - appendBtn.width
                        height: parent.height
                        elide: Text.ElideRight
                        font.pointSize: 12
                        font.bold: true
                        lineHeight: 0.7
                        color: bae.foregroundColor()

                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment:  Text.AlignVCenter
                    }


                    ToolButton
                    {
                        id: closeBtn
                        width: parent.height
                        height: parent.height

                        Icon { text: MdiFont.Icon.close }
                        onClicked: drawer.close()

                    }
                }
            }

            BabeTable
            {
                id: drawerList
                width: parent.width
                height: parent.height - titleBar.height
                trackNumberVisible: true
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
            }

        }
    }

    onAlbumCoverClicked:
    {
        albumTitle.text = album
        drawer.open()
        drawerList.clearTable()

        var query = Q.Query.albumTracks_.arg(album)
        query = query.arg(artist)

        var map = bae.get(query)

        for(var i in map)
            drawerList.model.append(map[i])
    }


    function populate()
    {
        var map = bae.get(Q.Query.allAlbumsAsc)
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
