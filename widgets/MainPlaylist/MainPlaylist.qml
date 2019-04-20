import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui


import "../../utils/Player.js" as Player
import "../../db/Queries.js" as Q
import "../../utils"
import "../../widgets"
import "../../view_models"
import "../../view_models/BabeTable"

Maui.Page
{
    id: mainPlaylistRoot

    property alias albumsRoll : albumsRoll
    property alias list : table.list
    property alias listModel: table.listModel
    property alias listView : table.listView
    property alias table: table
    property alias menu : playlistMenu

    property alias contextMenu: table.contextMenu

    signal coverDoubleClicked(var tracks)
    signal coverPressed(var tracks)
    focus: true

    margins: 0
    headBar.visible: false

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

    footBarItem: AlbumsRoll
    {
        anchors.fill : parent
        anchors.leftMargin: space.small
        anchors.rightMargin: space.small
        id: albumsRoll
    }

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

        //            anchors.bottom: mainPlaylistRoot.searchBox
        BabeTable
        {
            id: table
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignBottom | Qt.AlignTop
            focus: true
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
                var lastplaylist = bae.lastPlaylist()
                var n = lastplaylist.length

                if(n>0)
                {
                    for(var i = 0; i < n; i++)
                    {
                        var where = "url = \""+lastplaylist[i]+"\""
                        var query = Q.GET.tracksWhere_.arg(where)
                        table.list.appendQuery(query);
                    }
                }else
                {
                    where = "fav = 1"
                    query = Q.GET.tracksWhere_.arg(where)
                    table.list.appendQuery(query);
                }

//                if(autoplay)
//                    Player.playAt(0)
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
