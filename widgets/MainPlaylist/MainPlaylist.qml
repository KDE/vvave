import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.8 as Kirigami
import org.kde.mauikit 1.3 as Maui

import "../../utils/Player.js" as Player
import "../../db/Queries.js" as Q
import "../../utils"
import "../../widgets"
import "../../view_models/BabeTable"

Maui.Page
{
    id: control

    Kirigami.Theme.colorSet: Kirigami.Theme.Window

    property alias listModel: table.listModel
    property alias listView : table.listView
    property alias table: table

    property alias contextMenu: table.contextMenu

    flickable: table.flickable

    title: i18n("Now playing")
    showTitle: true

    headBar.visible: !mainlistEmpty
    headerBackground.color: "transparent"

    headBar.rightContent: ToolButton
    {
        icon.name: "edit-delete"
        onClicked:
        {
            player.stop()
            listModel.list.clear()
            root.sync = false
            root.syncPlaylist = ""
        }
    }

    headBar.leftContent:  ToolButton
    {
        icon.name: "document-save"
        onClicked: saveList()
    }

    BabeTable
    {
        id: table

        Binding on currentIndex
        {
            value: currentTrackIndex
            restoreMode: Binding.RestoreBindingOrValue
        }

        anchors.fill: parent
        listModel.sort: ""
        listBrowser.enableLassoSelection: false
        headBar.visible: false
        footBar.visible: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Window

        holder.emoji: "qrc:/assets/view-media-track.svg"
        holder.title : "Nothing to play!"
        holder.body: i18n("Start putting together your playlist.")
        holder.emojiSize: Maui.Style.iconSizes.huge

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
                    text: i18n("Syncing to ") + root.syncPlaylist
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
            width: ListView.view.width
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
                const item = listModel.get(index-1)
                return coverArt && item && item.album === album && item.artist === artist
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

                    listModel.list.remove(index)
                }

                opacity: delegate.hovered ? 0.8 : 0.6
            }

            onClicked:
            {
                if(Maui.Handy.isTouch)
                    Player.playAt(index)
            }

            onDoubleClicked:
            {
                if(!Maui.Handy.isTouch)
                    Player.playAt(index)
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
                    listModel.list.appendQuery(query);
                }
            }
        }
    }

    function saveList()
    {
        var trackList = []
        if(listModel.list.count > 0)
        {
            for(var i = 0; i < listModel.list.count; ++i)
                trackList.push(listModel.get(i).url)

            playlistDialog.composerList.urls = trackList
            playlistDialog.open()
        }
    }
}
