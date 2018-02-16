import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.2 as Kirigami

import "../InfoView"

import "../../utils/Player.js" as Player
import "../../db/Queries.js" as Q
import "../../utils"
import "../../widgets"
import "../../view_models"
import "../../view_models/BabeTable"

Item
{

    id: mainPlaylistRoot

    property alias artwork : artwork
    property alias cover : cover
    property alias list : table.list
    property alias table: table
    property alias infoView : infoView

    property alias contextMenu : table.contextMenu
    property alias mainlistContext : mainlistContext
    property alias headerMenu : table.headerMenu
    property alias stack : stackView

    signal coverDoubleClicked(var tracks)
    signal coverPressed(var tracks)


    PlaylistMenu
    {
        id: playlistMenu
        onClearOut: Player.clearOutPlaylist()
        onHideCover: cover.visible = !cover.visible
        onClean: Player.cleanPlaylist()
        onSaveToClicked: table.saveList()
    }

    Rectangle
    {
        anchors.fill: parent
        color: midLightColor
        z: -999
    }

    GridLayout
    {
        id: playlistLayout
        anchors.fill: parent
        width: parent.width
        rowSpacing: 0
        rows: 4
        columns: 1

        Item
        {
            id: cover
            Layout.row: 1
            Layout.column: 1
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? coverSize : 0
            Layout.maximumHeight: 300
            visible:  !root.mainlistEmpty
            Rectangle
            {
                visible: cover.visible
                anchors.fill: parent
                color: darkDarkColor
                z: -999
            }

            FastBlur
            {
                visible: cover.visible
                width: mainPlaylistRoot.width
                height: mainPlaylistItem.y
                source: artwork
                radius: 100
                transparentBorder: false
                cached: true
            }

            Image
            {
                id: artwork
                visible: cover.visible
                width: parent.height < 300 ? parent.height : 300
                height: parent.height
                anchors.centerIn: parent
                source: currentArtwork ? "file://"+encodeURIComponent(currentArtwork)  : "qrc:/assets/cover.png"
                fillMode: Image.PreserveAspectFit

                MouseArea
                {
                    anchors.fill: parent
                    onDoubleClicked: gomini()

                    onPressAndHold:
                    {
                        var query = Q.GET.albumTracks_.arg(currentTrack.album)
                        query = query.arg(currentTrack.artist)
                        var tracks = bae.get(query)
                        coverPressed(tracks)
                    }
                }
            }
        }

        Item
        {
            id: mainlistContext
            width: parent.width

            anchors.horizontalCenter: parent.horizontalCenter
            Layout.row: 2
            Layout.column: 1
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? toolBarHeight : 0
            //                        anchors.top: cover.bottom

            Rectangle
            {
                anchors.fill: parent
                color: darkDarkColor
                opacity: opacityLevel
                z: -999

                Kirigami.Separator
                {
                    visible: !stackView.currentItem === table
                    Rectangle
                    {
                        anchors.fill: parent
                        color: Kirigami.Theme.viewFocusColor
                    }

                    anchors
                    {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                }
            }
            MouseArea
            {
                anchors.fill: parent
                drag.target: mainlistContext
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY:stackView.currentItem === table ?  coverSize : 0

                onMouseYChanged:
                {
                    if(stackView.currentItem === table )
                    {
                        cover.height = mainlistContext.y

                        if(mainlistContext.y < coverSize*0.8)
                        {
                            cover.visible = false
                            mainlistContext.y = 0
                        }else cover.visible = true
                    }
                }
            }

            RowLayout
            {
                anchors.fill: parent
                anchors.centerIn: parent
                //                spacing: 0
                //                Layout.margins: 0

                Item
                {
                    Layout.fillWidth: true

                    BabeButton
                    {
                        id: infoBtn
                        anchors.centerIn: parent
                        iconColor: darkForegroundColor
                        iconName: stackView.currentItem === table ? "documentinfo" : "arrow-left"
                        onClicked:
                        {
                            if( stackView.currentItem !== table)
                            {
                                cover.visible  = true
                                stackView.pop(table) }
                            else {
                                cover.visible  = false
                                stackView.push(infoView)
                            }
                        }
                    }
                }

                Item
                {
                    Layout.fillWidth: true
                    BabeButton
                    {
                        id: commentBtn
                        anchors.centerIn: parent
                        Layout.fillWidth: true
                        iconName: "edit-comment"
                        iconColor: darkForegroundColor
                    }
                }

                Item
                {
                    Layout.fillWidth: true
                    BabeButton
                    {
                        id: menuBtn
                        anchors.centerIn: parent
                        Layout.fillWidth: true
                        iconName: /*"application-menu"*/ "overflow-menu"
                        onClicked: root.isMobile ? playlistMenu.open() : playlistMenu.popup()
                        iconColor: darkForegroundColor

                    }
                }
            }
        }

        Item
        {
            id: mainPlaylistItem
            Layout.row: 4
            Layout.column: 1
            Layout.fillWidth: true
            Layout.fillHeight: true
            anchors.top: mainlistContext.bottom
            //            anchors.bottom: mainPlaylistRoot.searchBox
            StackView
            {
                id: stackView
                anchors.fill: parent
                focus: true

                pushEnter: Transition
                {
                    PropertyAnimation
                    {
                        property: "opacity"
                        from: 0
                        to:1
                        duration: 200
                    }
                }

                pushExit: Transition
                {
                    PropertyAnimation
                    {
                        property: "opacity"
                        from: 1
                        to:0
                        duration: 200
                    }
                }

                popEnter: Transition
                {
                    PropertyAnimation {
                        property: "opacity"
                        from: 0
                        to:1
                        duration: 200
                    }
                }

                popExit: Transition
                {
                    PropertyAnimation
                    {
                        property: "opacity"
                        from: 1
                        to:0
                        duration: 200
                    }
                }

                initialItem: BabeTable
                {
                    id: table
                    headerBarVisible: false
                    quickPlayVisible: false
                    coverArtVisible: true
                    trackRating: true
                    headerBarColor : darkMidColor
                    holder.message : "<h2>Meh!</h2><p>Start putting together your playlist!</p>"
                    holder.emoji: "qrc:/assets/face-sleeping.png"

                    textColor: darkForegroundColor

                    Rectangle
                    {
                        anchors.fill: parent
                        color: darkDarkColor
                        z: -999
                    }

                    onRowClicked:
                    {
                        prevTrackIndex = currentTrackIndex
                        currentTrackIndex = currentIndex
                        Player.playAt(index)
                    }

                    onArtworkDoubleClicked:
                    {
                        contextMenu.babeIt(index)
                        //                        var query = Q.GET.albumTracks_.arg(model.get(index).album)
                        //                        query = query.arg(model.get(index).artist)

                        //                        Player.playAll(bae.get(query))
                        //                        Player.appendTracksAt(bae.get(query),index)

                    }

                    Component.onCompleted:
                    {
                        var list = bae.lastPlaylist()
                        var n = list.length

                        if(n>0)
                        {
                            for(var i = 0; i < n; i++)
                            {
                                var where = "url = \""+list[i]+"\""
                                var query = Q.GET.tracksWhere_.arg(where)
                                var track = bae.get(query)
                                Player.appendTrack(track[0])
                            }
                        }else
                        {
                            where = "babe = 1"
                            query = Q.GET.tracksWhere_.arg(where)
                            var tracks = bae.get(query)

                            for(var pos=0; pos< tracks.length; pos++)
                                Player.appendTrack(tracks[pos])

                        }
                        Player.playAt(0)

                        //                                    var pos = bae.lastPlaylistPos()
                        //                                    console.log("POSSS:", pos)
                        //                                    list.currentIndex = pos
                        //                                    play(list.model.get(pos))
                    }
                }

                InfoView
                {
                    id: infoView
                }

            }
        }
    }

    function gomini()
    {
        if(!isMobile)
        {
            if(root.header.visible)
            {
                root.maximumWidth = columnWidth
                root.minimumWidth = columnWidth
                root.maximumHeight = mainPlaylistItem.y + footer.height
                root.minimumHeight = mainPlaylistItem.y + footer.height
                root.header.visible = false
                infoBtn.visible = false
                //                root.footer.visible = false
                //                mainlistContext.visible = false

            }else
            {
                cover.y = 0
                root.maximumWidth = bae.screenGeometry("width")
                root.minimumWidth = columnWidth
                root.maximumHeight = bae.screenGeometry("height")
                root.minimumHeight = columnWidth

                root.width = columnWidth
                root.height = 700
                root.header.visible = true
                infoBtn.visible = true
                //                root.footer.visible = true
                //                mainlistContext.visible = true
            }
        }
    }
}
