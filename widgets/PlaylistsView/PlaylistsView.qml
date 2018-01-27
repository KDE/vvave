import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami

import "../../view_models/BabeTable"
import "../../view_models"
import "../../db/Queries.js" as Q


//    transform: Translate
//    {
//        x: (playlistViewDrawer.position * playlistViewRoot.width * 0.33)*-1
//    }

Kirigami.PageRow
{
    id: playlistViewRoot
    property string playlistQuery

    signal rowClicked(var track)
    signal quickPlayTrack(var track)
    signal playAll(var tracks)
    signal appendAll(var tracks)

    clip: true
    separatorVisible: wideMode
    initialPage:[playlistList, playlistViewDrawer]
    defaultColumnWidth: Kirigami.Units.gridUnit * 15
    interactive: false
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
                onColorClicked:
                {
                    populate(Q.GET.colorTracks_.arg(color))
                    if(!playlistViewRoot.wideMode)
                        playlistViewRoot.currentIndex = 1
                }
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
            trackDuration: false
            headerBar: true
            headerClose: !playlistViewRoot.wideMode
            headerTitle: playlistViewRoot.wideMode ? "" : playlistViewModel.model.get(playlistViewModel.currentIndex).playlist
            onHeaderClosed: if(!playlistViewRoot.wideMode)
                                playlistViewRoot.currentIndex = 0

            holder.message:  "Select a playlist or create a new one"
            holder.emoji: "qrc:/assets/face-hug.png"

            Connections
            {
                target: filterList
                onRowClicked: playlistViewRoot.rowClicked(filterList.model.get(index))
                onQuickPlayTrack:
                {
                    playlistViewRoot.quickPlayTrack(filterList.model.get(index))
                }
                onPlayAll: playAll(bae.get(playlistQuery))
                onAppendAll: appendAll(bae.get(playlistQuery))
            }
        }

    }



    function populate(query)
    {
        playlistQuery = query
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
