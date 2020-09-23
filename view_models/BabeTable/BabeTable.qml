import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui
import org.maui.vvave 1.0

import "../../utils/Player.js" as Player
import "../../utils/Help.js" as H

Maui.Page
{
    id: control

    property alias listBrowser : _listBrowser
    property alias listView : _listBrowser.flickable

    property alias listModel : _listModel
    property alias list : _tracksList

    property alias delegate : _listBrowser.delegate

    property alias count : _listBrowser.count
    property alias currentIndex : _listBrowser.currentIndex
    property alias currentItem : _listBrowser.currentItem

    property alias holder : _listBrowser.holder
    property alias section : _listBrowser.section

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

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false
    flickable: _listBrowser.flickable

    headBar.leftContent: Maui.ToolActions
    {
        expanded: isWide
        enabled: listModel.list.count > 0
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
        Layout.minimumWidth: 100
        Layout.maximumWidth: 500
        Layout.alignment: Qt.AlignCenter
        enabled: control.listModel.list.count > 0
        placeholderText: i18n("Search") + " " + listModel.list.count + " " + i18n("tracks")
        onAccepted: listModel.filter = text
        onCleared: listModel.filter = ""
    }

    headBar.rightContent: [
        Maui.ToolButtonMenu
        {
            id: sortBtn
            icon.name: "view-sort"
            enabled: listModel.list.count > 2
            MenuItem
            {
                text: i18n("Title")
                checkable: true
                checked: control.sort === "title"
                onTriggered: control.listModel.sort = "title"
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Track")
                checkable: true
                checked: control.listModel.sort === "track"
                onTriggered: control.listModel.sort = "track"
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Artist")
                checkable: true
                checked: control.listModel.sort === "artist"
                onTriggered: control.listModel.sort ="artist"
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Album")
                checkable: true
                checked: control.listModel.sort === "album"
                onTriggered: control.listModel.sort = "album"
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Most played")
                checkable: true
                checked: control.listModel.sort === "count"
                onTriggered: control.listModel.sort = "count"
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Rate")
                checkable: true
                checked: control.listModel.sort === "rate"
                onTriggered: control.listModel.sort = "rate"
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Release date")
                checkable: true
                checked: control.listModel.sort === "releasedate"
                onTriggered: control.listModel.sort = "releasedate"
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Add date")
                checkable: true
                checked: control.listModel.sort === "adddate"
                onTriggered: control.listModel.sort = "adddate"
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
            listModel.list.remove(control.currentIndex)
            close()
        }

        onRejected:
        {
            if(Maui.FM.removeFile(listModel.get(index).url))
                listModel.list.remove(control.currentIndex)
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
            listModel.list.fav(control.currentIndex, !Maui.FM.isFav(listModel.get(control.currentIndex).url))
        }

        onQueueClicked: Player.queueTracks([listModel.get(control.currentIndex)])
        onPlayClicked: quickPlayTrack(control.currentIndex)
        onAppendClicked: appendTrack(control.currentIndex)

        onSaveToClicked:
        {
            playlistDialog.composerList.urls = [listModel.get(control.currentIndex).url]
            playlistDialog.open()
        }

        onOpenWithClicked: Maui.FM.openLocation([listModel.get(control.currentIndex).url])

        onDeleteClicked:
        {
            _removeDialog.index= control.currentIndex
            _removeDialog.open()
        }

        onRateClicked:
        {
            listModel.list.rate(control.currentIndex, rate);
        }

        onInfoClicked:
        {
            infoView.show(listModel.get(control.currentIndex))
        }

        onCopyToClicked:
        {
            cloudView.list.upload(control.currentIndex)
        }

        onShareClicked:
        {
            const url = listModel.get(control.currentIndex).url

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


    Maui.ListBrowser
    {
        id: _listBrowser
        anchors.fill: parent

        focus: true
        holder.visible: control.listModel.list.count === 0
        enableLassoSelection: true

        onItemsSelected:
        {
            for(var i in indexes)
            {
                H.addToSelection(listModel.get(indexes[i]))
            }
        }

        section.property: control.group ? control.listModel.sort : ""
        section.criteria: control.listModel.sort === "title" ?  ViewSection.FirstCharacter : ViewSection.FullString
        section.delegate: Maui.ListItemTemplate
        {
            implicitHeight: Maui.Style.rowHeight*2
            width: parent.width

            label1.text: control.listModel.sort === "adddate" || control.listModel.sort === "releasedate" ? Maui.FM.formatDate(Date(section), "MM/dd/yyyy") : String(section)
            label1.font.pointSize: Maui.Style.fontSizes.big

        }

        model:Maui.BaseModel
        {
            id: _listModel
            list: Tracks {id: _tracksList}
            sort: "title"
            sortOrder: Qt.AscendingOrder
            recursiveFilteringEnabled: true
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        //    property alias animBabe: delegate.animBabe
        delegate: TableDelegate
        {
            id: delegate
            width: ListView.view.width
            number: trackNumberVisible
            coverArt: coverArtVisible ? (control.width > 200) : coverArtVisible
            onPressAndHold: if(Maui.Handy.isTouch && allowMenu) openItemMenu(index)
            onRightClicked: if(allowMenu) openItemMenu(index)

            onToggled: H.addToSelection(model)
            checked: selectionBar.contains(model.url)
            checkable: selectionMode

            signal play()
            signal append()

            Drag.keys: ["text/uri-list"]
            Drag.mimeData: Drag.active ?
                               {
                                   "text/uri-list": control.filterSelectedItems(model.url)
                               } : {}

        sameAlbum:
        {
            const item = listModel.get(index-1)
            return coverArt && item && item.album === album && item.artist === artist
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
                H.addToSelection(model)
                return
            }

            if ((mouse.button == Qt.LeftButton) && (mouse.modifiers & Qt.ControlModifier))
                _listBrowser.itemsSelected([index])

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
}

function openItemMenu(index)
{
    currentIndex = index
    contextMenu.rate = listModel.get(currentIndex).rate
    contextMenu.fav = Maui.FM.isFav(listModel.get(currentIndex).url)
    contextMenu.popup()

    rowPressed(index)
}

function goToAlbum()
{
    swipeView.currentIndex = viewsIndex.albums
    const item = listModel.get(control.currentIndex)
    albumsView.populateTable(item.album, item.artist)
    contextMenu.close()
}

function goToArtist()
{
    swipeView.currentIndex = viewsIndex.artists
    const item = listModel.get(control.currentIndex)
    artistsView.populateTable(undefined, item.artist)
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
