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

    property alias artwork : artwork
    property alias albumsRoll : albumsRoll
    property alias cover : cover
    property alias list : table.list
    property alias listModel: table.listModel
    property alias listView : table.listView
    property alias table: table
    property alias infoView : infoView
    property alias progressBar: progressBar
    property alias animFooter : animFooter

    property alias contextMenu: table.contextMenu
    property alias headerMenu: table.headerMenu
    property alias stack: stackView

    signal coverDoubleClicked(var tracks)
    signal coverPressed(var tracks)
    focus: true

 margins: 0
headBar.visible: false
footBar.visible: !mainlistEmpty
    footBar.middleContent: [

        Maui.ToolButton
        {
            id: babeBtnIcon
            iconName: "love"

            iconColor: currentBabe ? babeColor : cover.colorScheme.textColor
            onClicked: if (!mainlistEmpty)
            {
                var value = H.faveIt([mainPlaylist.list.model.get(currentTrackIndex).url])
                currentBabe = value
                mainPlaylist.list.model.get(currentTrackIndex).babe = value ? "1" : "0"
            }
        },

        Maui.ToolButton
        {
            iconName: "media-skip-backward"
            iconColor: cover.colorScheme.textColor
            onClicked: Player.previousTrack()
            onPressAndHold: Player.playAt(prevTrackIndex)
        },

        Maui.ToolButton
        {
            id: playIcon
            iconColor: cover.colorScheme.textColor
            iconName: isPlaying ? "media-playback-pause" : "media-playback-start"
            onClicked:
            {
                player.playing = !player.playing
            }
        },

        Maui.ToolButton
        {
            id: nextBtn
            iconColor: cover.colorScheme.textColor
            iconName: "media-skip-forward"
            onClicked: Player.nextTrack()
            onPressAndHold: Player.playAt(Player.shuffle())
        },

        Maui.ToolButton
        {
            id: shuffleBtn
            iconColor: cover.colorScheme.textColor
            iconName: isShuffle ? "media-playlist-shuffle" : "media-playlist-repeat"
            onClicked:
            {
                isShuffle = !isShuffle
                bae.saveSetting("SHUFFLE",isShuffle, "PLAYBACK")
            }
        }
    ]

     footBar.leftContent: Maui.ToolButton
    {
        id: infoBtn
        iconName: stackView.currentItem === table ? "documentinfo" : "go-previous"
        onClicked:
        {
            if( stackView.currentItem !== table)
            {
                cover.visible  = true
                stackView.pop(table)
                albumsRoll.positionAlbum(currentTrackIndex)
            }else
            {
                cover.visible  = false
                stackView.push(infoView)
            }
        }
    }

    footBar.rightContent : Maui.ToolButton
    {
        id: menuBtn
        iconName: "overflow-menu"
        onClicked: isMobile ? playlistMenu.open() : playlistMenu.popup()
    }



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
        onHideCover: cover.visible = !cover.visible
        onClean: Player.cleanPlaylist()
        onSaveToClicked: table.saveList()
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

        Maui.Page
        {
            id: cover
            visible: false
            Layout.alignment: Qt.AlignBottom | Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredHeight: !mainlistEmpty ? coverSize : 0
            Layout.maximumHeight: coverSize
            margins: 0
            headBarExit: false
            //            headBar.visible: true
            //            headBar.implicitHeight: 0
            //            floatingBar: true
            //            footBarOverlap: true
            altToolBars: true

            //            footBar.visible: !mainlistEmpty

            headBar.background: Rectangle
            {
                color: "transparent"
            }

            footBar.background: Rectangle
            {
                color: "transparent"
            }

            headBar.leftContent: Label
            {
                visible: !mainlistEmpty && infoLabels
                text: progressTimeLabel
                color: cover.colorScheme.textColor
                clip: true
            }

            headBar.rightContent: Label
            {
                visible: !mainlistEmpty && infoLabels
                text: durationTimeLabel
                color: cover.colorScheme.textColor
                clip: true
            }
            headBarTitle: currentTrack.title ? currentTrack.title + " - " + currentTrack.artist : ""



            background: Rectangle
            {
                visible: !mainlistEmpty

                color: viewBackgroundColor
                z: -1

                Image
                {
                    id: artwork
                    visible: !mainlistEmpty
                    anchors.fill: parent
                    sourceSize.height: coverSize * 0.2
                    sourceSize.width: coverSize * 0.2
                    source: currentArtwork ? "file://"+encodeURIComponent(currentArtwork)  : "qrc:/assets/cover.png"
                    fillMode: Image.PreserveAspectCrop
                }

                FastBlur
                {
                    visible: artwork.visible
                    anchors.fill: parent
                    source: artwork
                    radius: 100
                    transparentBorder: false
                    cached: true


                    Rectangle
                    {
                        anchors.fill: parent
                        opacity: 0.8
                        color: cover.colorScheme.viewBackgroundColor
                    }
                }

                SequentialAnimation
                {
                    id: animFooter
                    //                        PropertyAnimation
                    //                        {
                    //                            target: footerBg
                    //                            property: "color"
                    //                            easing.type: Easing.InOutQuad
                    //                            from: "black"
                    //                            to: darkViewBackgroundColor
                    //                            duration: 500
                    //                        }
                }
            }

            content: AlbumsRoll
            {
                id: albumsRoll
                height: visible ?  parent.height : 0
                width: parent.width
                anchors.verticalCenter: parent.vertical
            }
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

    }

    function goFocusMode()
    {

        if(focusMode)
        {
            if(isMobile)
            {
                root.width = screenWidth
                root.height= screenHeight
            }else
            {
                cover.y = 0
                root.maximumWidth = screenWidth
                root.minimumWidth = columnWidth
                root.maximumHeight = screenHeight
                root.minimumHeight = columnWidth

                root.width = columnWidth
                root.height = 700
            }

        }else
        {
            if(isMobile)
            {

            }else
            {
                root.maximumWidth = columnWidth
                root.minimumWidth = columnWidth
                root.maximumHeight = columnWidth
                root.minimumHeight = columnWidth
                //                root.footer.visible = false
                //                mainlistContext.visible = false


            }
        }

        focusMode = !focusMode
    }

    function play(index)
    {
        prevTrackIndex = currentTrackIndex
        Player.playAt(index)

    }
}
