import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "../InfoView"

import "../../utils/Player.js" as Player
import "../../db/Queries.js" as Q
import "../../utils"
import "../../widgets"
import "../../view_models"
import "../../view_models/BabeTable"

Maui.Page
{
    id: mainPlaylistRoot

    //    property alias artwork : artwork
    property alias albumsRoll : albumsRoll
    //    property alias cover : cover
    property alias list : table.list
    property alias listModel: table.listModel
    property alias listView : table.listView
    property alias table: table
    property alias infoView : infoView
    property alias progressBar: progressBar
    property alias animFooter : animFooter
    property alias menu : playlistMenu

    property alias contextMenu: table.contextMenu
    property alias headerMenu: table.headerMenu
    property alias stack: stackView

    signal coverDoubleClicked(var tracks)
    signal coverPressed(var tracks)
    focus: true

    margins: 0
    headBar.visible: false



    //    headBar.middleContent: Maui.PieButton
    //    {
    //        iconName: "list-add"

    //        model: ListModel
    //        {
    //            ListElement{iconName: "videoclip-amarok" ; btn: "video"}
    //            ListElement{iconName: "documentinfo" ; btn: "info"}
    //            ListElement{iconName: "headphones" ; btn: "similar"}
    //        }

    //        onItemClicked:
    //        {
    //            if(item.btn === "video")
    //            {
    //                youtubeView.openVideo = 1
    //                youtube.getQuery(currentTrack.title+" "+currentTrack.artist)
    //                pageStack.currentIndex = 1
    //                currentView = viewsIndex.youtube
    //            }

    //            if(item.btn === "info")
    //            {
    //                if( stackView.currentItem !== table)
    //                {
    //                    cover.visible  = true
    //                    stackView.pop(table) }
    //                else {
    //                    cover.visible  = false
    //                    stackView.push(infoView)
    //                }
    //            }
    //        }
    //    }



    PlaylistMenu
    {
        id: playlistMenu
        onClearOut: Player.clearOutPlaylist()
        //        onHideCover: cover.visible = !cover.visible
        onClean: Player.cleanPlaylist()
        onSaveToClicked: table.saveList()
    }

    footBar.visible: !mainlistEmpty
    footBar.implicitHeight: toolBarHeight * 1.3

    footBarItem: RowLayout
    {
        anchors.fill : parent
        anchors.rightMargin: space.small
        anchors.leftMargin: space.small

        AlbumsRoll
        {
            id: albumsRoll
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        Maui.ToolButton
        {
            id: infoBtn
            iconName:  "documentinfo"
            Layout.fillHeight: true

            onClicked:
            {
                if( stackView.currentItem !== table)
                {
                    stackView.pop(table)
                    albumsRoll.positionAlbum(currentTrackIndex)
                }else
                {
                    stackView.push(infoView)
                }
            }
        }

        Maui.ToolButton
        {
            id: menuBtn
            iconName: "overflow-menu"
            onClicked: playlistMenu.popup()
            Layout.fillHeight: true
        }

    }

    //    footBar.rightContent: Maui.ToolButton
    //    {
    //        id: infoBtn
    //        iconName:  "documentinfo"
    //        onClicked:
    //        {
    //            if( stackView.currentItem !== table)
    //            {
    //                stackView.pop(table)
    //                albumsRoll.positionAlbum(currentTrackIndex)
    //            }else
    //            {
    //                stackView.push(infoView)
    //            }
    //        }
    //    }



    footBar.background: Rectangle
    {
        id: footerBg
        clip : true
        height: footBar.implicitHeight
        color: "transparent"

        Image
        {
            id: artworkBg
            height: parent.height
            width: parent.width

            sourceSize.width: parent.width
            sourceSize.height: parent.height

            fillMode: Image.PreserveAspectCrop
            cache: true
            antialiasing: true
            smooth: true
            asynchronous: true

            source: "file://"+encodeURIComponent(currentArtwork)
        }


        SequentialAnimation
        {
            id: animFooter
            PropertyAnimation
            {
                target: footerBg
                property: "color"
                easing.type: Easing.InOutQuad
                from: "black"
                to: darkViewBackgroundColor
                duration: 500
            }
        }

        FastBlur
        {
            id: fastBlur
            anchors.fill: parent
            y:1
            source: artworkBg
            radius: 100
            transparentBorder: false
            cached: true
            z:1
            clip: true

            Rectangle
            {
                anchors.fill: parent
                color: viewBackgroundColor
                opacity: 0.85

            }
        }


    }


    ColumnLayout
    {
        id: playlistLayout
        anchors.fill: parent
        width: parent.width
        spacing: 0

        Item
        {
            id: mainPlaylistItem
            visible : !focusMode

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignBottom | Qt.AlignTop
            focus: true
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
                    headBar.visible: false
                    quickPlayVisible: false
                    coverArtVisible: true
                    trackRating: true
                    showIndicator : true
                    menuItemVisible: false
                    holder.emoji: "qrc:/assets/Radio.png"
                    holder.isMask: false
                    holder.title : "Meh!"
                    holder.body: "Start putting together your playlist!"
                    holder.emojiSize: iconSizes.huge
                    onRowClicked: play(index)

                    onArtworkDoubleClicked: contextMenu.babeIt(index)

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

                        if(autoplay)
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

        Kirigami.Separator
        {
            Layout.fillWidth: true
            color: borderColor
        }




        Slider
        {
            id: progressBar
            height: unit * (isMobile ?  6 : 8)
            width: parent.width
            Layout.fillWidth: true

            padding: 0
            from: 0
            to: 1000
            value: player.pos
            spacing: 0
            focus: true
            onMoved:
            {
                player.pos = value
            }


            background: Rectangle
            {
                implicitWidth: progressBar.width
                implicitHeight: progressBar.height
                width: progressBar.availableWidth
                height: implicitHeight
                color: "transparent"

                Rectangle
                {
                    width: progressBar.visualPosition * parent.width
                    height: progressBar.height
                    color: babeColor
                }
            }

            handle: Rectangle
            {
                x: progressBar.leftPadding + progressBar.visualPosition
                   * (progressBar.availableWidth - width)
                y: -(progressBar.height * 0.8)
                implicitWidth: progressBar.pressed ? iconSizes.medium : 0
                implicitHeight: progressBar.pressed ? iconSizes.medium : 0
                radius: progressBar.pressed ? iconSizes.medium : 0
                color: babeColor
            }
        }

        Kirigami.Separator
        {
            Layout.fillWidth: true
            color: borderColor
        }
    }

    //    function goFocusMode()
    //    {

    //        if(focusMode)
    //        {
    //            if(isMobile)
    //            {
    //                root.width = screenWidth
    //                root.height= screenHeight
    //            }else
    //            {
    //                cover.y = 0
    //                root.maximumWidth = screenWidth
    //                root.minimumWidth = columnWidth
    //                root.maximumHeight = screenHeight
    //                root.minimumHeight = columnWidth

    //                root.width = columnWidth
    //                root.height = 700
    //            }

    //        }else
    //        {
    //            if(isMobile)
    //            {

    //            }else
    //            {
    //                root.maximumWidth = columnWidth
    //                root.minimumWidth = columnWidth
    //                root.maximumHeight = columnWidth
    //                root.minimumHeight = columnWidth
    //                //                root.footer.visible = false
    //                //                mainlistContext.visible = false


    //            }
    //        }

    //        focusMode = !focusMode
    //    }

    function play(index)
    {
        prevTrackIndex = currentTrackIndex
        Player.playAt(index)

    }
}
