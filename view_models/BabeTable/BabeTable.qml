import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import TracksList 1.0

import "../../utils/Player.js" as Player
import "../../utils/Help.js" as H
import "../../db/Queries.js" as Q

import ".."

BabeList
{
    id: control
    //    cacheBuffer : 300

    property alias list : _tracksList
    property alias listModel : _tracksModel
    property alias removeDialog : _removeDialog

    property bool trackNumberVisible
    property bool coverArtVisible : false
    property bool allowMenu: true
    property bool showQuickActions : true
    property bool group : false

    property alias contextMenu : contextMenu
    property alias contextMenuItems : contextMenu.contentData

//    property alias playAllBtn : playAllBtn
//    property alias appendBtn : appendBtn

    signal rowClicked(int index)
    signal rowDoubleClicked(int index)
    signal rowPressed(int index)
    signal quickPlayTrack(int index)
    signal queueTrack(int index)
    signal appendTrack(int index)

    signal artworkDoubleClicked(int index)

    signal playAll()
    signal appendAll()

    focus: true
    holder.visible: list.count === 0
    listView.spacing: Maui.Style.space.small * (Kirigami.Settings.isMobile ? 1.4 : 1.2)
    listView.header: Column
    {
        width: control.width
        z: listView.z + 9
        visible: list.count > 0
        Maui.ToolBar
        {
            Kirigami.Theme.inherit: false
            position: ToolBar.Header
            width: parent.width
            leftContent: [

                ToolButton
                {
                    id : playAllBtn
                    icon.name : "media-playlist-play"
                    onClicked: playAll()
                },

                ToolButton
                {
                    id: appendBtn
                    icon.name : "media-playlist-append"
                    onClicked: appendAll()
                }]

            middleContent:    Label
            {
                text: control.title
                elide : Text.ElideRight
                font.bold : false
                font.weight: Font.Bold
                color : Kirigami.Theme.textColor
                font.pointSize: Maui.Style.fontSizes.big
                horizontalAlignment : Text.AlignHCenter
                verticalAlignment :  Text.AlignVCenter
            }

            rightContent: [

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
                    visible: list.count > 2
                    MenuItem
                    {
                        text: qsTr("Title")
                        checkable: true
                        checked: list.sortBy === Tracks.TITLE
                        onTriggered: list.sortBy = Tracks.TITLE
                        autoExclusive: true
                    }

                    MenuItem
                    {
                        text: qsTr("Track")
                        checkable: true
                        checked: list.sortBy === Tracks.TRACK
                        onTriggered: list.sortBy = Tracks.TRACK
                        autoExclusive: true
                    }

                    MenuItem
                    {
                        text: qsTr("Artist")
                        checkable: true
                        checked: list.sortBy === Tracks.ARTIST
                        onTriggered: list.sortBy = Tracks.ARTIST
                        autoExclusive: true
                    }

                    MenuItem
                    {
                        text: qsTr("Album")
                        checkable: true
                        checked: list.sortBy === Tracks.ALBUM
                        onTriggered: list.sortBy = Tracks.ALBUM
                        autoExclusive: true
                    }

                    MenuItem
                    {
                        text: qsTr("Most played")
                        checkable: true
                        checked: list.sortBy === Tracks.COUNT
                        onTriggered: list.sortBy = Tracks.COUNT
                        autoExclusive: true
                    }

                    MenuItem
                    {
                        text: qsTr("Rate")
                        checkable: true
                        checked: list.sortBy === Tracks.RATE
                        onTriggered: list.sortBy = Tracks.RATE
                        autoExclusive: true
                    }

                    MenuItem
                    {
                        text: qsTr("Favorite")
                        checkable: true
                        checked: list.sortBy === Tracks.FAV
                        onTriggered: list.sortBy = Tracks.FAV
                        autoExclusive: true
                    }

                    MenuItem
                    {
                        text: qsTr("Release date")
                        checkable: true
                        checked: list.sortBy === Tracks.RELEASEDATE
                        onTriggered: list.sortBy = Tracks.RELEASEDATE
                        autoExclusive: true
                    }

                    MenuItem
                    {
                        text: qsTr("Add date")
                        checkable: true
                        checked: list.sortBy === Tracks.ADDDATE
                        onTriggered: list.sortBy = Tracks.ADDDATE
                        autoExclusive: true
                    }

                    MenuSeparator{}

                    MenuItem
                    {
                        text: qsTr("Group")
                        checkable: true
                        checked: group
                        onTriggered:
                        {
                            group = !group
                            groupBy()
                        }
                    }
                },

                ToolButton
                {
                    id: _filterButton
                    icon.name: "view-filter"
                    checkable: true
                    visible: list.count > 10
                }
            ]

        }

        Maui.ToolBar
        {
            Kirigami.Theme.inherit: false
            //        Kirigami.Theme.backgroundColor: control.Kirigami.Theme.backgroundColor
            visible: _filterButton.checked && _filterButton.visible
            width: parent.width
            position: ToolBar.Header
            middleContent: Maui.TextField
            {
                Layout.fillWidth: true
                onAccepted: listModel.setFilterString(text)
                onTextChanged: listModel.setFilterString(text)
            }
        }
    }

    Maui.Dialog
    {
        id: _removeDialog
        property int index
        title: qsTr("Remove track")
        message: qsTr("You can delete the file from your computer or remove it from your collection")
        rejectButton.text: qsTr("Delete")
        acceptButton.text: qsTr("Remove")
        page.padding: Maui.Style.space.huge

        onAccepted:
        {
            list.remove(listView.currentIndex)
            close()
        }

        onRejected:
        {
            if(Maui.FM.removeFile(list.get(index).url))
                list.remove(listView.currentIndex)
            close()
        }
    }

    TableMenu
    {
        id: contextMenu

        MenuSeparator {}

        MenuItem
        {
            text: qsTr("Go to Artist")
            onTriggered: goToArtist()

        }

        MenuItem
        {
            text: qsTr("Go to Album")
            onTriggered: goToAlbum()
        }

        onFavClicked:
        {
            list.fav(listView.currentIndex, !(list.get(listView.currentIndex).fav == "1"))
        }

        onQueueClicked: Player.queueTracks([list.get(listView.currentIndex)])
        onPlayClicked: quickPlayTrack(listView.currentIndex)
        onAppendClicked: appendTrack(listView.currentIndex)

        onSaveToClicked:
        {
            playlistDialog.tracks = [list.get(listView.currentIndex).url]
            playlistDialog.open()
        }

        onOpenWithClicked: Maui.FM.openLocation([list.get(listView.currentIndex).url])

        onDeleteClicked:
        {
            _removeDialog.index= listView.currentIndex
            _removeDialog.open()
        }

        onRateClicked:
        {
            list.rate(listView.currentIndex, rate);
        }

        onColorClicked:
        {
            list.color(listView.currentIndex, color);
        }

        onInfoClicked:
        {
            infoView.show(list.get(listView.currentIndex))
        }

        onCopyToClicked:
        {
            cloudView.list.upload(listView.currentIndex)
        }

        onShareClicked:
        {
            const url = list.get(listView.currentIndex).url

            if(isAndroid)
            {
                Maui.Android.shareDialog(url)
                return
            }

            _dialogLoader.sourceComponent = _shareDialogComponent
            root.dialog.show([url])
        }
    }

    section.criteria: ViewSection.FullString
    section.delegate: Maui.LabelDelegate
    {
        id: _sectionDelegate
        label: section
        isSection: true
        width: control.width
        Kirigami.Theme.backgroundColor: "#333"
        Kirigami.Theme.textColor: "#fafafa"

        background: Rectangle
        {
            color:  Kirigami.Theme.backgroundColor
        }
    }

    Maui.BaseModel
    {
        id: _tracksModel
        list: _tracksList
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    Tracks
    {
        id: _tracksList
        onSortByChanged: if(control.group) control.groupBy()
    }

    model: _tracksModel

    //    property alias animBabe: delegate.animBabe
    delegate: TableDelegate
    {
        id: delegate
        width: listView.width
        number : trackNumberVisible ? true : false
        coverArt : coverArtVisible ? (control.width > 200) : coverArtVisible
        onPressAndHold: if(Kirigami.Settings.isMobile && allowMenu) openItemMenu(index)
        onRightClicked: if(allowMenu) openItemMenu(index)

        onLeftEmblemClicked: H.addToSelection(list.get(index))
        isSelected: selectionBar.contains(model.url)

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
            visible: control.showQuickActions && (Kirigami.Settings.isMobile ? true : delegate.hovered)
            icon.name: "media-playlist-append"
            onClicked: delegate.append()
            opacity: delegate.hovered ? 0.8 : 0.6
        }

        onClicked:
        {
            currentIndex = index
            if(selectionMode)
            {
                H.addToSelection(list.get(listView.currentIndex))
                return
            }

            if(Kirigami.Settings.isMobile)
                rowClicked(index)
        }

        onDoubleClicked:
        {
            currentIndex = index

            if(!Kirigami.Settings.isMobile)
                rowClicked(index)
        }

        onPlay:
        {
            currentIndex = index
            quickPlayTrack(index)
        }

        onAppend:
        {
            currentIndex = index
            appendTrack(index)
        }

        onArtworkCoverClicked:
        {
            currentIndex = index
            goToAlbum()
        }

        Connections
        {
            target: selectionBar

            onUriRemoved:
            {
                if(uri === model.url)
                    delegate.isSelected = false
            }

            onUriAdded:
            {
                if(uri === model.url)
                    delegate.isSelected = true
            }

            onCleared: delegate.isSelected = false
        }
    }

    function openItemMenu(index)
    {
        currentIndex = index
        contextMenu.rate = list.get(currentIndex).rate
        contextMenu.fav = list.get(currentIndex).fav == "1"
        contextMenu.popup()

        rowPressed(index)
    }

    function saveList()
    {
        var trackList = []
        if(list.count > 0)
        {
            for(var i = 0; i < list.count; ++i)
                trackList.push(listModel.get(i).url)

            playlistDialog.tracks = trackList
            playlistDialog.open()
        }
    }

    function queueList()
    {
        var trackList = []

        if(list.count > 0)
        {
            for(var i = 0; i < list.count; ++i)
                trackList.push(list.get(i))

            Player.queueTracks(trackList)
        }
    }

    function goToAlbum()
    {
        swipeView.currentIndex = viewsIndex.albums
        const item = list.get(listView.currentIndex)
        swipeView.currentItem.item.populateTable(item.album, item.artist)
        contextMenu.close()
    }

    function goToArtist()
    {
        swipeView.currentIndex = viewsIndex.artists
        const item = list.get(listView.currentIndex)
        swipeView.currentItem.item.populateTable(undefined, item.artist)
        contextMenu.close()
    }

    function groupBy()
    {
        var prop = "undefined"

        if(group)
            switch(list.sortBy)
            {
            case Tracks.TITLE:
                prop = "title"
                break
            case Tracks.ARTIST:
                prop = "artist"
                break
            case Tracks.ALBUM:
                prop = "album"
                break
            case Tracks.RATE:
                prop = "rate"
                break
            case Tracks.FAV:
                prop = "fav"
                break
            case Tracks.ADDDATE:
                prop = "adddate"
                break
            case Tracks.RELEASEDATE:
                prop = "releasedate"
                break;
            case Tracks.COUNT:
                prop = "count"
                break
            }

        section.property =  prop
    }
}
