import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

import "../view_models"
import "../utils/Icons.js" as MdiFont
import "../utils"

BabeGrid
{
    id:albumsView
    visible: true
    albumSize: 150
    borderRadius: 20

    signal rowClicked(var track)
    signal playAlbum(var tracks)
    signal appendAlbum(var tracks)

    Drawer
    {
        id: drawer
        height: parent.height * 0.4
        width: parent.width
        edge: Qt.BottomEdge
        interactive: false

        Column
        {
            anchors.fill: parent

            Rectangle
            {
                id: titleBar
                width: parent.width
                height: 48
                z: 1

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
                            var data = albumsView.gridModel.get(albumsView.grid.currentIndex)
                            var query = "select * from tracks where album = \""+data.album+"\" and artist = \""+data.artist+"\""
                            var tracks = con.get(query)
                            playAlbum(tracks)
                            drawer.close()

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
                            var data = albumsView.gridModel.get(albumsView.grid.currentIndex)
                            var query = "select * from tracks where album = \""+data.album+"\" and artist = \""+data.artist+"\""
                            var tracks = con.get(query)
                            appendAlbum(tracks)
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

                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment:  Text.AlignVCenter
                    }


                    ToolButton
                    {
                        id: closeBtn
                        width: parent.height
                        height: parent.height

                        Icon { text: MdiFont.Icon.close }
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
                onRowClicked:
                {
                    albumsView.rowClicked(model.get(index))
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

        var query = "select * from tracks where album = \""+album+"\" and artist = \""+artist+"\" order by track"
        console.log(query)
        var map = con.get(query)

        for(var i in map)
            drawerList.model.append(map[i])

    }

    Component.onCompleted:
    {
        var map = con.get("select * from albums order by album asc")
        for(var i in map)
        {
            gridModel.append(map[i])
        }
    }

}
