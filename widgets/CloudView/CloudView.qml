import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

import org.maui.vvave 1.0

import "../../view_models/BabeTable"
import "../../view_models/BabeGrid"
import "../../utils/Player.js" as Player

Maui.Page
{
    id: control
    property alias list : _cloudList

    Maui.BaseModel
    {
        id: _cloudModel
        list: _cloudList
    }

    Cloud
    {
        id: _cloudList

        onFileReady: Player.addTrack(track)
    }

    headBar.visible: !_listView.holder.visible

    headBar.leftContent: [

        ToolButton
        {
            id : playAllBtn
            //            text: i18n("Play all")
            icon.name : "media-playlist-play"
            //            onClicked: playAll()
        },
        ToolButton
        {
            id: appendBtn
            //            text: i18n("Append")
            icon.name : "media-playlist-append"//"media-repeat-track-amarok"
            //            onClicked: appendAll()
        }]


    headBar.rightContent: [

        ToolButton
        {
            icon.name: "item-select"
            onClicked: selectionMode = !selectionMode
            checkable: false
            checked: selectionMode
        },

        Maui.ToolButtonMenu
        {
            id: sortBtn
            icon.name: "view-sort"

            MenuItem
            {
                text: i18n("Title")
                checkable: true
                checked: list.sortBy === Cloud.TITLE
                onTriggered: list.sortBy = Cloud.TITLE
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Track")
                checkable: true
                checked: list.sortBy === Cloud.TRACK
                onTriggered: list.sortBy = Cloud.TRACK
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Artist")
                checkable: true
                checked: list.sortBy === Cloud.ARTIST
                onTriggered: list.sortBy = Cloud.ARTIST
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Album")
                checkable: true
                checked: list.sortBy === Cloud.ALBUM
                onTriggered: list.sortBy = Cloud.ALBUM
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Most played")
                checkable: true
                checked: list.sortBy === Cloud.COUNT
                onTriggered: list.sortBy = Cloud.COUNT
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Rate")
                checkable: true
                checked: list.sortBy === Cloud.RATE
                onTriggered: list.sortBy = Cloud.RATE
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Favorite")
                checkable: true
                checked: list.sortBy === Cloud.FAV
                onTriggered: list.sortBy = Cloud.FAV
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Release date")
                checkable: true
                checked: list.sortBy === Cloud.RELEASEDATE
                onTriggered: list.sortBy = Cloud.RELEASEDATE
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Add date")
                checkable: true
                checked: list.sortBy === Cloud.ADDDATE
                onTriggered: list.sortBy = Cloud.ADDDATE
                autoExclusive: true
            }

            MenuSeparator{}

            MenuItem
            {
                text: i18n("Group")
                checkable: true
//                checked: group
                onTriggered: group = !group
            }
        }
    ]


    Maui.ListBrowser
    {
        id: _listView
        anchors.fill: parent
        clip: true
        holder.visible: count === 0
        holder.emoji: "qrc:/assets/dialog-information.svg"
        holder.title : i18n("Opps!")
        holder.body: i18n("You don't have an account set up.\nYou can set up your account now by clicking here or under the Accounts options in the main menu")

        Connections
        {
            target: _listView.holder
            function onActionTriggered()
            {
                if(root.accounts)
                    root.accounts.open()
            }
        }

        topMargin: Maui.Style.space.medium
        model: _cloudModel
        section.property: "artist"
        section.criteria: ViewSection.FullString
        section.delegate: Maui.LabelDelegate
        {
            id: _sectionDelegate
            label: section
            isSection: true
            width: parent.width
            Kirigami.Theme.backgroundColor: "#333"
            Kirigami.Theme.textColor: "#fafafa"

            background: Rectangle
            {
                color:  Kirigami.Theme.backgroundColor
            }
        }

        flickable.header: Rectangle
        {
            Kirigami.Theme.inherit: false
            width: parent.width
            height: 150
            z: _listView.listView.z+999
            color: Kirigami.Theme.backgroundColor
            visible: _headList.count > 0

            ListView
            {
                id: _headList
                anchors.fill: parent
                anchors.margins: Maui.Style.space.medium
                spacing: Maui.Style.space.medium
                orientation: ListView.Horizontal

                model: list.artists

                delegate: BabeAlbum
                {
                    height: 120
                    width: height
                    albumRadius: Maui.Style.radiusV
                    isCurrentItem: ListView.isCurrentItem
                    anchors.verticalCenter: parent.verticalCenter
                    showLabels: true
                    label1.text: modelData.album ? modelData.album : modelData.artist
                    label2.text: modelData.artist && modelData.album ? modelData.artist : ""
                    image.source:  modelData.artwork ?  modelData.artwork : "qrc:/assets/cover.png"
                }
            }
        }

        flickable.headerPositioning: ListView.PullBackHeader


        delegate: TableDelegate
        {
            id: delegate
            width: parent.width
            number :  false
            coverArt : false

            ToolButton
            {
                icon.name: "document-download"
                Layout.fillHeight: true
            }

            onClicked:
            {
                _listView.currentIndex = index
                //                if(selectionMode)
                //                {
                //                    H.addToSelection(control.list.get(_listView.currentIndex))
                //                    return
                //                }

                list.getFileUrl(index);

                //                if(isMobile)
                //                    rowClicked(index)

            }

            //            onDoubleClicked:
            //            {
            //                currentIndex = index
            //                if(!isMobile)
            //                    rowClicked(index)
            //            }

            //            onPlay:
            //            {
            //                currentIndex = index
            //                if(Maui.FM.fileExists("file://" + _cloudList.get(index).thumbnail))
            //                {
            //                    quickPlayTrack(index)
            //                }else
            //                {
            //                    _cloudList.requestFile(index)
            //                }
            //            }

            //            onArtworkCoverClicked:
            //            {
            //                currentIndex = index
            //                goToAlbum()
            //            }
        }

    }

}
