import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.2 as Kirigami
import org.kde.maui 1.0 as Maui

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
    property alias table: table
    property alias infoView : infoView
    property alias progressBar: progressBar
    property alias animFooter : animFooter

    property alias contextMenu: table.contextMenu
    property alias mainlistContext: mainlistContext
    property alias headerMenu: table.headerMenu
    property alias stack: stackView

    signal coverDoubleClicked(var tracks)
    signal coverPressed(var tracks)
    focus: true

    headBarVisible: false
    margins: 0

    footBar.background: Rectangle
    {
        id: footerBg
        clip : true
        implicitHeight: mainPlaylist.floatingBar ? toolBarHeight * 0.7 : toolBarHeight
        height: implicitHeight
        color: darkViewBackgroundColor
        radius: mainPlaylist.floatingBar ? unit * 6 : 0
        border.color: mainPlaylist.floatingBar ? Qt.lighter(borderColor, 1.2) : "transparent"
        layer.enabled: mainPlaylist.floatingBar
        layer.effect: DropShadow
        {
            anchors.fill: footerBg
            horizontalOffset: 0
            verticalOffset: 4
            radius: 8.0
            samples: 17
            color: "#80000000"
            source: footerBg
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

        Rectangle
        {
            anchors.fill: parent
            color: "transparent"
            radius: footerBg.radius
            opacity: 0.3
            clip: true

            FastBlur
            {
                id: fastBlur
                width: parent.width
                height: parent.height-1
                y:1
                source: mainPlaylist.cover
                radius: 100
                transparentBorder: false
                cached: true
                z:1
                clip: true

                layer.enabled: mainPlaylist.floatingBar
                layer.effect: OpacityMask
                {
                    maskSource: Item
                    {
                        width: footBar.width
                        height: footBar.height
                        Rectangle
                        {
                            anchors.centerIn: parent
                            width: footBar.width
                            height: footBar.height
                            radius: footerBg.radius
                        }
                    }
                }
            }
        }
    }

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
            id: cover
            Layout.alignment: Qt.AlignBottom | Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredHeight: !mainlistEmpty ? coverSize : 0
            Layout.maximumHeight: coverSize
            visible: !mainlistEmpty

            Rectangle
            {
                visible: !mainlistEmpty
                anchors.fill: parent
                color: viewBackgroundColor
                z: -999

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
                }
            }

            Item
            {
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter

                AlbumsRoll
                {
                    id: albumsRoll
                    height: parent.height
                    width: parent.width
                    anchors.verticalCenter: parent.vertical
                }

            }
        }

        Maui.ToolBar
        {
            id: mainlistContext
            clip: false
            width: parent.width
            implicitHeight: toolBarHeightAlt
            visible : !focusMode &&  !mainlistEmpty
            Layout.alignment: Qt.AlignBottom | Qt.AlignTop

            Layout.fillWidth: true

            MouseArea
            {
                anchors.fill: parent
                drag.target: mainlistContext
                drag.axis: Drag.YAxis
                drag.minimumY: 0
                drag.maximumY:stackView.currentItem === table ?  coverSize : 0
                z: -1
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

            leftContent: Maui.ToolButton
            {
                id: infoBtn
                iconName: stackView.currentItem === table ? "documentinfo" : "go-previous"
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

            middleContent: Maui.PieButton
            {
                iconName: "list-add"

                model: ListModel
                {
                    ListElement{iconName: "videoclip-amarok" ; btn: "video"}
                    ListElement{iconName: "documentinfo" ; btn: "info"}
                    ListElement{iconName: "headphones" ; btn: "similar"}
                }

                onItemClicked:
                {
                    if(item.btn === "video")
                    {
                        youtubeView.openVideo = 1
                        youtube.getQuery(currentTrack.title+" "+currentTrack.artist)
                        pageStack.currentIndex = 1
                        currentView = viewsIndex.youtube
                    }

                    if(item.btn === "info")
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

            rightContent : Maui.ToolButton
            {
                id: menuBtn
                iconName: "overflow-menu"
                onClicked: isMobile ? playlistMenu.open() : playlistMenu.popup()
            }
        }


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
                    headBarVisible: false
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

        Slider
        {
            id: progressBar
            height: unit * (isMobile ?  6 : 8)
            width: parent.width
            Layout.fillWidth: true

            padding: 0
            from: 0
            to: 1000
            value: 0
            spacing: 0
            focus: true
            onMoved: player.seek(player.duration() / 1000 * value)

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
                y: -(progressBar.height * 0.7)
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
