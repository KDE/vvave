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
    property alias list : _tracksList
    property alias listModel : _tracksModel
    property alias removeDialog : _removeDialog

    property bool trackNumberVisible : false
    property bool coverArtVisible : false
    property bool allowMenu: true
    property bool showQuickActions : true
    property bool group : false

    property alias contextMenu : contextMenu
    property alias contextMenuItems : contextMenu.contentData
    signal rowClicked(int index)
    signal rowDoubleClicked(int index)
    signal rowPressed(int index)
    signal quickPlayTrack(int index)
    signal queueTrack(int index)
    signal appendTrack(int index)

    signal playAll()
    signal appendAll()

    focus: true
    holder.visible: list.count === 0
    listView.spacing: Maui.Style.space.small * (Kirigami.Settings.isMobile ? 1.4 : 1.2)
    listBrowser.enableLassoSelection: !Kirigami.Settings.hasTransientTouchInput

    Connections
    {
        target: control.listBrowser
        onItemsSelected:
        {
            for(var i in indexes)
            {
                H.addToSelection(listModel.get(indexes[i]))
            }
        }
    }

    headBar.leftContent: Maui.ToolActions
    {
        expanded: isWide
        enabled: list.count > 0
        checkable: false
        autoExclusive: false
        display: ToolButton.TextBesideIcon
        defaultIconName: "media-playback-start"
        Action
        {
            icon.name : "media-playlist-play"
            text: qsTr("Play")
            onTriggered: playAll()
        }

        Action
        {
            icon.name : "media-playlist-append"
            text: qsTr("Append")
            onTriggered: appendAll()
        }
    }

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        placeholderText: qsTr("Search") + " " + list.count + " " + qsTr("tracks")
        onAccepted: listModel.filter = text
        onCleared: listModel.filter = ""
    }

    headBar.rightContent: [
        Maui.ToolButtonMenu
        {
            id: sortBtn
            icon.name: "view-sort"
            enabled: list.count > 2
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
        }
    ]

    Maui.Dialog
    {
        id: _removeDialog
        property int index
        title: qsTr("Remove track")
        message: qsTr("You can delete the file from your computer or remove it from your collection")
        rejectButton.text: qsTr("Delete")
        acceptButton.text: qsTr("Remove")
        page.margins: Maui.Style.space.huge

        onAccepted:
        {
            list.remove(listView.currentIndex)
            close()
        }

        onRejected:
        {
            if(Maui.FM.removeFile(listModel.get(index).url))
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
            icon.name: "view-media-artist"
            onTriggered: goToArtist()

        }

        MenuItem
        {
            text: qsTr("Go to Album")
            icon.name: "view-media-album-cover"
            onTriggered: goToAlbum()
        }

        onFavClicked:
        {
            list.fav(listView.currentIndex, !Maui.FM.isFav(listModel.get(listView.currentIndex).url))
        }

        onQueueClicked: Player.queueTracks([listModel.get(listView.currentIndex)])
        onPlayClicked: quickPlayTrack(listView.currentIndex)
        onAppendClicked: appendTrack(listView.currentIndex)

        onSaveToClicked:
        {
            playlistDialog.tracks = [listModel.get(listView.currentIndex).url]
            playlistDialog.open()
        }

        onOpenWithClicked: Maui.FM.openLocation([listModel.get(listView.currentIndex).url])

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
            infoView.show(listModel.get(listView.currentIndex))
        }

        onCopyToClicked:
        {
            cloudView.list.upload(listView.currentIndex)
        }

        onShareClicked:
        {
            const url = listModel.get(listView.currentIndex).url

            if(isAndroid)
            {
                Maui.Android.shareDialog(url)
                return
            }

            _dialogLoader.sourceComponent = _shareDialogComponent
            root.dialog.urls =[url]
            root.dialog.open()
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
        number : trackNumberVisible
        coverArt : coverArtVisible ? (control.width > 200) : coverArtVisible
        onPressAndHold: if(Maui.Handy.isTouch && allowMenu) openItemMenu(index)
        onRightClicked: if(allowMenu) openItemMenu(index)

        onToggled: H.addToSelection(listModel.get(index))
        checked: selectionBar.contains(model.url)
        checkable: selectionMode

        Drag.keys: ["text/uri-list"]
        Drag.mimeData: Drag.active ?
                           {
                               "text/uri-list": control.filterSelectedItems(model.url)
                           } : {}

        sameAlbum:
        {
            if(coverArt)
            {
                if(listModel.get(index-1))
                {
                    if(listModel.get(index-1).album === album && listModel.get(index-1).artist === artist) true
                    else false
                }else false
            }else false
        }

        ToolButton
        {
            Layout.fillHeight: true
            Layout.preferredWidth: implicitWidth
            visible: control.showQuickActions && (Maui.Handy.isTouch ? true : delegate.hovered)
            icon.name: "media-playlist-append"
            onClicked: delegate.append()
            opacity: delegate.hovered ? 0.8 : 0.6
        }

        onClicked:
        {
            currentIndex = index
            if(selectionMode)
            {
                H.addToSelection(listModel.get(listView.currentIndex))
                return
            }

            if ((mouse.button == Qt.LeftButton) && (mouse.modifiers & Qt.ControlModifier))
                control.listBrowser.itemsSelected([index])

            if(Maui.Handy.isTouch)
                rowClicked(index)
        }

        onDoubleClicked:
        {
            currentIndex = index

            if(!Maui.Handy.isTouch)
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
                    delegate.checked = false
            }

            onUriAdded:
            {
                if(uri === model.url)
                    delegate.checked = true
            }

            onCleared: delegate.checked = false
        }
    }

    function openItemMenu(index)
    {
        currentIndex = index
        contextMenu.rate = listModel.get(currentIndex).rate
        contextMenu.fav = Maui.FM.isFav(listModel.get(currentIndex).url)
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
                trackList.push(listModel.get(i))

            Player.queueTracks(trackList)
        }
    }

    function goToAlbum()
    {
        swipeView.currentIndex = viewsIndex.albums
        const item = listModel.get(listView.currentIndex)
        swipeView.currentItem.item.populateTable(item.album, item.artist)
        contextMenu.close()
    }

    function goToArtist()
    {
        swipeView.currentIndex = viewsIndex.artists
        const item = listModel.get(listView.currentIndex)
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

function filterSelectedItems(path)
{
    if(selectionBar && selectionBar.count > 0 && selectionBar.contains(path))
    {
        const uris = selectionBar.uris
        return uris.join("\n")
    }

    return path
}
}
