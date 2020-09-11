import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui
import org.maui.vvave 1.0

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
    //    listBrowser.enableLassoSelection: !Kirigami.Settings.hasTransientTouchInput
    listBrowser.enableLassoSelection: true

    Connections
    {
        target: control.listBrowser
        ignoreUnknownSignals: true

        function onItemsSelected(indexes)
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
            text: i18n("Play")
            onTriggered: playAll()
        }

        Action
        {
            icon.name : "media-playlist-append"
            text: i18n("Append")
            onTriggered: appendAll()
        }
    }

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        enabled: _tracksList.count > 0
        placeholderText: i18n("Search") + " " + list.count + " " + i18n("tracks")
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
                text: i18n("Title")
                checkable: true
                checked: _tracksModel.sort === "title"
                onTriggered: _tracksModel.sort = "title"
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Track")
                checkable: true
                checked: _tracksModel.sort === "track"
                onTriggered: _tracksModel.sort = "track"
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Artist")
                checkable: true
                checked: _tracksModel.sort === "artist"
                onTriggered: _tracksModel.sort ="artist"
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Album")
                checkable: true
                checked: _tracksModel.sort === "album"
                onTriggered: _tracksModel.sort = "album"
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Most played")
                checkable: true
                checked: _tracksModel.sort === "count"
                onTriggered: _tracksModel.sort = "count"
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Rate")
                checkable: true
                checked: _tracksModel.sort === "rate"
                onTriggered: _tracksModel.sort = "rate"
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Release date")
                checkable: true
                checked: _tracksModel.sort === "releasedate"
                onTriggered: _tracksModel.sort = "releasedate"
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Add date")
                checkable: true
                checked: _tracksModel.sort === "adddate"
                onTriggered: _tracksModel.sort = "adddate"
                autoExclusive: true
            }

            MenuSeparator{}

            MenuItem
            {
                text: i18n("Group")
                checkable: true
                checked: group
                onTriggered:
                {
                    group = !group
                }
            }
        }
    ]

    Maui.Dialog
    {
        id: _removeDialog
        property int index
        title: i18n("Remove track")
        message: i18n("You can delete the file from your computer or remove it from your collection")
        rejectButton.text: i18n("Delete")
        acceptButton.text: i18n("Remove")
        template.iconSource: "emblem-warning"
        page.margins: Maui.Style.space.big

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
            text: i18n("Go to Artist")
            icon.name: "view-media-artist"
            onTriggered: goToArtist()
        }

        MenuItem
        {
            text: i18n("Go to Album")
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
            playlistDialog.composerList.urls = [listModel.get(listView.currentIndex).url]
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

            if(Maui.Handy.isAndroid)
            {
                Maui.Android.shareDialog(url)
                return
            }

            _dialogLoader.sourceComponent = _shareDialogComponent
            root.dialog.urls = [url]
            root.dialog.open()
        }
    }

    listView.section.property: control.group ? _tracksModel.sort : ""
    listView.section.criteria: _tracksModel.sort === "title" || _tracksModel.sort === "artist" || _tracksModel.sort === "album"?  ViewSection.FirstCharacter : ViewSection.FullString
    section.delegate: Maui.LabelDelegate
    {
        id: _sectionDelegate
        label: _tracksModel.sort === "adddate" || _tracksModel.sort === "releasedate" ? Maui.FM.formatDate(Date(section), "MM/dd/yyyy") : String(section).toUpperCase()

        isSection: true
        width: parent.width
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
        sort: "title"
        sortOrder: Qt.AscendingOrder
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    Tracks
    {
        id: _tracksList
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
        ignoreUnknownSignals: true

        function onUriRemoved (uri)
        {
            if(uri === model.url)
                delegate.checked = false
        }

        function onUriAdded(uri)
        {
            if(uri === model.url)
                delegate.checked = true
        }

        function onCleared()
        {
            delegate.checked = false
        }
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

        playlistDialog.composerList.urls = trackList
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
