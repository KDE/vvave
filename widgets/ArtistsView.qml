import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import "../view_models"
import "../utils/Icons.js" as MdiFont
import "../utils"
import "../db/Queries.js" as Q

BabeGrid
{
    id:artistsViewGrid
    visible: true
    property int hintSize : Math.sqrt(root.width*root.height)*0.25
    albumSize:
    {
        if(hintSize>200)
            200
        else if (hintSize<150)
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
        y: (drawer.position * artistsViewGrid.height * 0.33)*-1
    }

    onBgClicked: if(drawer.visible) drawer.close()
        onFocusChanged:  drawer.close()

    Drawer
    {
        id: drawer
        height: parent.height * 0.4
        width: parent.width
        edge: Qt.BottomEdge
        interactive: false
        focus: true
        modal: bae.isMobile()
        dragMargin: 0
        clip: true



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
                        width: parent.height
                        height: parent.height

                        id: playAllBtn
                        BabeIcon {text: MdiFont.Icon.playBoxOutline}

                        onClicked:
                        {
                            drawer.close()
                            var data = artistsViewGrid.gridModel.get(artistsViewGrid.grid.currentIndex)

                            var query = Q.Query.artistTracks_.arg(data.artist)
                            var tracks = bae.get(query)
                            artistsViewGrid.playAlbum(tracks)

                        }
                    }
                    ToolButton
                    {
                        id: appendBtn

                        width: parent.height
                        height: parent.height

                        BabeIcon {text: MdiFont.Icon.playlistPlus}

                        onClicked:
                        {
                            var data = artistsViewGrid.gridModel.get(artistsViewGrid.grid.currentIndex)
                            var query = Q.Query.artistTracks_.arg(data.artist)
                            var tracks = bae.get(query)
                            artistsViewGrid.appendAlbum(tracks)
                            drawer.close()

                        }
                    }
                    Label
                    {
                        id: artistTitle
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

                        BabeIcon
                        {
                            text: MdiFont.Icon.close
                        }

                        onClicked:
                        {
                            drawer.close()
                            console.log("close drawer")
                        }
                    }
                }
            }

            BabeTable
            {
                id: drawerList
                width: parent.width
                height: parent.height - titleBar.height
                trackNumberVisible: true
                quickBtnsVisible: true

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
            }
        }
    }

    onAlbumCoverClicked:
    {
        artistTitle.text = artist
        drawer.open()
        drawerList.clearTable()
        var query = Q.Query.artistTracks_.arg(artist)
        var map = bae.get(query)

        for(var i in map)
            drawerList.model.append(map[i])

    }

    function populate()
    {
        var map = bae.get(Q.Query.allArtistsAsc)
        for(var i in map)
            gridModel.append(map[i])
    }

    Component.onCompleted: populate()

}
