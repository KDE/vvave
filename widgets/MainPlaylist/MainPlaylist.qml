import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0
import org.kde.kirigami 2.8 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.maui.vvave 1.0 as Vvave

import "../../utils/Player.js" as Player
import "../../db/Queries.js" as Q
import "../../utils"
import "../../widgets"
import "../../view_models"
import "../../view_models/BabeTable"

Maui.Page
{
    id: control

    property alias list : table.list
    property alias listModel: table.listModel
    property alias listView : table.listView
    property alias table: table
    property alias menu : playlistMenu

    property alias contextMenu: table.contextMenu

    signal coverDoubleClicked(var tracks)
    signal coverPressed(var tracks)
    focus: true

    Kirigami.Theme.backgroundColor: "transparent"
    background: Rectangle
    {
        color: Kirigami.Theme.backgroundColor
        opacity: translucency ? 0.7 : 1
    }

    PlaylistMenu
    {
        id: playlistMenu
        onClearOut: Player.clearOutPlaylist()
        onClean: Player.cleanPlaylist()
        onSaveToClicked: table.saveList()
    }

    title: qsTr("Now playing")
    showTitle: true
    headBar.visible: true
    headBar.rightContent: ToolButton
        {
            icon.name: "edit-delete"
            onClicked:
            {
                player.stop()
                mainPlaylist.table.list.clear()
                root.sync = false
                root.syncPlaylist = ""
            }
        }    

    headBar.leftContent:  ToolButton
    {
        icon.name: "document-save"
        onClicked: mainPlaylist.table.saveList()
    }

    flickable: table.flickable
    BabeTable
    {
        id: table
        anchors.fill: parent
        focus: true
        headBar.visible: false
        footBar.visible: false
        coverArtVisible: true
        holder.emoji: "qrc:/assets/dialog-information.svg"
        holder.isMask: true
        holder.title : "Meh!"
        holder.body: qsTr("Start putting together your playlist!")
        holder.emojiSize: Maui.Style.iconSizes.huge
        Kirigami.Theme.colorSet: Kirigami.Theme.Window
        Kirigami.Theme.backgroundColor: "transparent"

        listView.header: Rectangle
        {
            visible: root.sync
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet:Kirigami.Theme.Complementary
            z: table.z + 999
            width: table.width
            height: visible ?  Maui.Style.rowHeightAlt : 0
            color: Kirigami.Theme.backgroundColor

            RowLayout
            {
                anchors.fill: parent
                anchors.leftMargin: Maui.Style.space.small
                Label
                {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    anchors.margins: Maui.Style.space.small
                    text: qsTr("Syncing to ") + root.syncPlaylist
                }

                ToolButton
                {
                    Layout.fillHeight: true
                    icon.name: "dialog-close"
                    onClicked:
                    {
                        root.sync = false
                        root.syncPlaylist = ""
                    }
                }
            }
        }

        delegate: TableDelegate
        {
            id: delegate
            width: listView.width
            number : false
            coverArt : true
            checkable: false
            checked: false
            onPressAndHold: if(Maui.Handy.isTouch && table.allowMenu) table.openItemMenu(index)
            onRightClicked:
            {
                if(table.allowMenu) table.openItemMenu(index)
            }

            sameAlbum:
            {
                if(coverArt)
                {
                    if(list.get(index-1))
                    {
                        if(list.get(index-1).album === album && list.get(index-1).artist === artist) true
                        else false
                    }else false
                }else false
            }

            ToolButton
            {
                Layout.fillHeight: true
                Layout.preferredWidth: implicitWidth
                visible: (Maui.Handy.isTouch ? true : delegate.hovered)
                icon.name: "edit-clear"
                onClicked:
                {
                    if(index === currentTrackIndex)
                        player.stop()

                    list.remove(index)
                }

                opacity: delegate.hovered ? 0.8 : 0.6
            }

            onClicked:
            {
                if(Maui.Handy.isTouch)
                    control.play(index)
            }

            onDoubleClicked:
            {
                if(!Maui.Handy.isTouch)
                    control.play(index)
            }

        }

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
                query = Q.GET.babedTracks()
                table.list.appendQuery(query);
            }
        }
    }

    DropArea
    {
        id: _dropArea
        anchors.fill: parent
        onDropped:
        {
            if(drop.urls)
            {
                var urls = drop.urls.join(",")
                Vvave.Vvave.openUrls(urls.split(","))
            }
        }
    }

    function play(index)
    {
        Player.playAt(index)
    }
}
