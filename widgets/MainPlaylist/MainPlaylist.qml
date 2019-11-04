import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
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

    property alias list : table.list
    property alias listModel: table.listModel
    property alias listView : table.listView
    property alias table: table
    property alias menu : playlistMenu

    property alias contextMenu: table.contextMenu

    signal coverDoubleClicked(var tracks)
    signal coverPressed(var tracks)
    focus: true
    headBar.visible: false

    PlaylistMenu
    {
        id: playlistMenu
        onClearOut: Player.clearOutPlaylist()
        onClean: Player.cleanPlaylist()
        onSaveToClicked: table.saveList()
    }

    footer: AlbumsRoll
    {
        id: _albumsRoll
        width: table.width
        position: ToolBar.Footer
    }

    BabeTable
    {
        id: table
        anchors.fill: parent
        focus: true
        headBar.visible: false
        footBar.visible: false
        coverArtVisible: true
        holder.emoji: "qrc:/assets/dialog-information.svg"
        holder.isMask: false
        holder.title : "Meh!"
        holder.body: "Start putting together your playlist!"
        holder.emojiSize: Maui.Style.iconSizes.huge
        onRowClicked: play(index)
        showQuickActions: false

        listView.footer: Maui.ToolBar
        {
            Kirigami.Theme.inherit: false
            z: table.z + 999
            width: table.width

            leftContent: Label
            {
                text: root.syncPlaylist
            }

            rightContent: [
            ToolButton
                {
                    icon.name: "edit-clear"
                    onClicked: mainPlaylist.table.list.clear()
                },

                ToolButton
                    {
                        icon.name: "document-save"
                        onClicked: mainPlaylist.table.saveList()
                    }


            ]
        }

        onArtworkDoubleClicked: contextMenu.babeIt(index)

        property int startContentY

        Component.onCompleted:
        {
            var lastplaylist = Maui.FM.loadSettings("LASTPLAYLIST", "PLAYLIST", [])
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
