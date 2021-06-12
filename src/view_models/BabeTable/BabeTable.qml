import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.9 as Kirigami
import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.vvave 1.0

import "../../utils/Player.js" as Player
import "../../utils/Help.js" as H

import "../../widgets"

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

    headBar.visible: true

    headBar.leftContent: Maui.ToolButtonMenu
    {
        enabled: listModel.list.count > 0
        icon.name: "media-playback-start"

        MenuItem
        {
            icon.name : "media-playlist-play"
            text: i18n("Play All")
            onTriggered: playAll()
        }

        MenuItem
        {
            icon.name : "media-playlist-append"
            text: i18n("Append All")
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

    Component
    {
        id: _metadataDialogComponent

        MetadataDialog
        {
            model: listModel
            index: control.currentIndex

            onEdited:
            {
                control.list.updateMetadata(data, index)
            }
        }
    }

    Maui.FileListingDialog
    {
        id: _removeDialog

        title: i18n("Remove track")
        message: i18n("Are you sure you want to delete the file from your computer? This action can not be undone.")

        acceptButton.text: i18n("Remove")

        onAccepted:
        {
            if(FB.FM.removeFiles(_removeDialog.urls))
            {
                 listModel.list.remove(control.currentIndex)
            }
            close()
        }

        onRejected:
        {
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
            listModel.list.fav(control.currentIndex, !FB.Tagging.isFav(listModel.get(control.currentIndex).url))
        }

        onQueueClicked: Player.queueTracks([listModel.get(control.currentIndex)])

        onSaveToClicked:
        {
            playlistDialog.composerList.urls = filterSelection(listModel.get(control.currentIndex).url)
            playlistDialog.open()
        }

        onOpenWithClicked: FB.FM.openLocation(filterSelection(listModel.get(control.currentIndex).url))

        onDeleteClicked:
        {
            _removeDialog.urls = filterSelection(listModel.get(control.currentIndex).url)
            _removeDialog.open()
        }

        onInfoClicked:
        {
//            infoView.show(listModel.get(control.currentIndex))
        }

        onEditClicked:
        {
            _dialogLoader.sourceComponent = _metadataDialogComponent
            dialog.open()
        }

        onCopyToClicked:
        {
            cloudView.list.upload(control.currentIndex)
        }

        onShareClicked:
        {
            const url = listModel.get(control.currentIndex).url
            Maui.Platform.shareFiles([url])
        }
    }

    Maui.ListBrowser
    {
        id: _listBrowser
        anchors.fill: parent
        clip: true
        focus: true
        holder.visible: control.listModel.list.count === 0
        enableLassoSelection: true
        selectionMode: root.selectionMode

        onItemsSelected:
        {
            for(var i in indexes)
            {
                H.addToSelection(listModel.get(indexes[i]))
            }
        }

        section.property: control.group ? control.listModel.sort : ""
        section.criteria: control.listModel.sort === "title" ?  ViewSection.FirstCharacter : ViewSection.FullString
        section.delegate: Item
        {
            width: ListView.view.width
            implicitHeight: Maui.Style.rowHeight*2.5

            Rectangle
            {
                color: Qt.tint(control.Kirigami.Theme.textColor, Qt.rgba(control.Kirigami.Theme.backgroundColor.r, control.Kirigami.Theme.backgroundColor.g, control.Kirigami.Theme.backgroundColor.b, 0.9))
                anchors.centerIn: parent
                width: parent.width
                height: Maui.Style.rowHeight * 1.5

                radius: Maui.Style.radiusV

                Maui.ListItemTemplate
                {

                    label1.text: control.listModel.sort === "adddate" || control.listModel.sort === "releasedate" ? Maui.Handy.formatDate(Date(section), "MM/dd/yyyy") : String(section)

                    label1.font.pointSize: Maui.Style.fontSizes.big
                    label1.font.bold: true
                    anchors.fill: parent
                    leftMargin: 0
                    iconSource: "view-media-artist"
                    imageSource: control.listModel.sort === "artist" ? "image://artwork/artist:"+ section : ""
                }
            }
        }

        model: Maui.BaseModel
        {
            id: _listModel
            list: Tracks
            {
                id: _tracksList
                onMissingFiles:
                {
                    var message = i18n("%1 Missing files", urls.length)
                    var messageBody = "Missing files have been removed from the collection."
                    notify("dialog-question", message, messageBody)
                }
            }
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
            onClicked:
            {
                currentIndex = index
                appendTrack(index)
            }

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
    contextMenu.fav = FB.Tagging.isFav(listModel.get(currentIndex).url)
    contextMenu.open()

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

function filterSelection(url)
{
    if(selectionBar.contains(url))
    {
        return selectionBar.uris
    }else
    {
        return [url]
    }
}

}
