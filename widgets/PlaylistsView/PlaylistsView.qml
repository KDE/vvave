import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami

import "../../view_models/BabeTable"
import "../../view_models"



//    transform: Translate
//    {
//        x: (playlistViewDrawer.position * playlistViewRoot.width * 0.33)*-1
//    }

Kirigami.PageRow
{
    id: playlistViewRoot

    signal rowClicked(var track)
    signal quickPlayTrack(var track)

    separatorVisible: wideMode
    initialPage:[playlistList, playlistViewDrawer]
    defaultColumnWidth: Kirigami.Units.gridUnit * 15

        Page
    {
        id: playlistList
        ColumnLayout
        {
            anchors.fill: parent
            spacing: 0
            Layout.margins: 0

            PlaylistsViewModel
            {
                id: playlistViewModel

                Layout.fillHeight: true
                Layout.fillWidth: true

            }

            ColorTagsBar
            {
                Layout.fillWidth: true
                height: 32
                recSize: 22
                Rectangle
                {
                    anchors.fill: parent
                    z: -999
                    color:bae.midColor()
                }
                //        onColorClicked: moodIt(color)
            }


        }
    }


    Page
    {
        id: playlistViewDrawer
        anchors.fill: parent
        //        y: root.header.height
        //        height: parent.height - root.header.height - root.footer.height
        //        width: root.isMobile ? parent.width : parent.width* 0.7
        //        edge: Qt.RightEdge
        //        interactive: true
        //        focus: true
        //        modal: isMobile

        //        modal: !root.wideScreen
        //        onModalChanged: drawerOpen = !modal

        background: Rectangle
        {
            color: bae.altColor()
        }

        BabeTable
        {
            id: filterList
            width: parent.width
            height: parent.height
            quickPlayVisible: true
            coverArtVisible: true
            trackRating: true
            trackDuration: true
            headerBar: true
            headerClose: !playlistViewRoot.wideMode
            headerTitle: playlistViewModel.model.get(playlistViewModel.currentIndex).playlist

            onHeaderClosed: if(!playlistViewRoot.wideMode)
                                playlistViewRoot.currentIndex = 0


            Connections
            {
                target: filterList
                onRowClicked: playlistViewRoot.rowClicked(filterList.model.get(index))
                onQuickPlayTrack:
                {
                    //                        playlistViewDrawer.close()
                    playlistViewRoot.quickPlayTrack(filterList.model.get(index))
                }
                //                        onPlayAll: Player.playAll(bae.get(Q.Query.allTracks))
                //                        onAppendAll: Player.appendAll(bae.get(Q.Query.allTracks))
            }
        }

    }



    function populate(query)
    {
        filterList.clearTable()

        var tracks = bae.get(query)

        if(tracks.length>0)
            for(var i in tracks)
                filterList.model.append(tracks[i])

    }

    Component.onCompleted:
    {
        var playlists = bae.get("select * from playlists order by addDate desc")
        if(playlists.length > 0)
            for(var i in playlists)
                playlistViewModel.model.append(playlists[i])
    }
}
