import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.vvave 1.0

import "../../utils/Player.js" as Player

import "../../widgets"

Maui.Page
{
    id: control

    readonly property alias listBrowser : _listBrowser
    readonly property alias listView : _listBrowser.flickable

    readonly property alias listModel : _listModel
    readonly property alias list : _tracksList

    property alias delegate : _listBrowser.delegate

    readonly property alias count : _listBrowser.count
    property alias currentIndex : _listBrowser.currentIndex
    readonly property alias currentItem : _listBrowser.currentItem

    readonly property alias holder : _listBrowser.holder
    readonly property alias section : _listBrowser.section

    property bool trackNumberVisible : false
    property bool coverArtVisible : false
    property bool allowMenu: true
    property bool showQuickActions : true
    property bool group : false

    readonly property alias contextMenu : contextMenu
    property alias contextMenuItems : contextMenu.contentData

    signal rowClicked(int index)
    signal rowDoubleClicked(int index)
    signal rowPressed(int index)
    signal queueTrack(int index)
    signal appendTrack(int index)

    signal playAll()
    signal appendAll()
    signal shuffleAll()

    Maui.Theme.colorSet: Maui.Theme.View
    Maui.Theme.inherit: false

    flickable: _listBrowser.flickable

    headBar.visible: control.list.count > 0
    headBar.forceCenterMiddleContent: isWide
    headBar.rightContent: Loader
    {
        asynchronous: true
        active: headBar.visible
        visible: active

        sourceComponent: Maui.ToolButtonMenu
        {
            icon.name: "media-playback-start"

            MenuItem
            {
                icon.name : "media-playlist-shuffle"
                text: i18n("Shuffle Play")
                onTriggered: shuffleAll()
            }

            MenuItem
            {
                icon.name : "media-playback-start"
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
    }

    headBar.middleContent: Loader
    {
        id: _filterLoader
        asynchronous: true
        active: listModel.list.count > 1
        visible: active

        Layout.fillWidth: true
        Layout.minimumWidth: 100
        Layout.maximumWidth: 500
        Layout.alignment: Qt.AlignCenter

        sourceComponent: Maui.SearchField
        {
            placeholderText: i18np("Filter", "Filter %1 songs", listModel.list.count)

            KeyNavigation.up: _listBrowser
            KeyNavigation.down: _listBrowser

            onAccepted:
            {
                if(text.includes(","))
                {
                    listModel.filters = text.split(",")
                }else
                {
                    listModel.filter = text
                }
            }

            onCleared: listModel.clearFilters()
        }
    }

    Component
    {
        id: _metadataDialogComponent

        MetadataDialog
        {
            model: listModel

            onEdited: (data, index) =>
            {
                control.list.updateMetadata(data, model.mappedToSource(index))
            }
        }
    }

    Component
    {
        id: _removeDialogComponent

        Maui.FileListingDialog
        {
            title: i18n("Remove track")
            message: i18n("Are you sure you want to delete the file from your computer? This action can not be undone.")

            actions: [
            Action
            {
                text: i18n("Remove")
                onTriggered:
                {
                    if(FB.FM.removeFiles(urls))
                    {
                        listModel.list.erase(listModel.mappedToSource(control.currentIndex))
                    }
                    close()
                }
            },

            Action
            {
                text: i18n("Cancel")
                onTriggered: close()
            }]
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
            onTriggered: goToArtist(listModel.get(control.currentIndex).artist)
        }

        MenuItem
        {
            text: i18n("Go to Album")
            icon.name: "view-media-album-cover"
            onTriggered:
            {
                let item = listModel.get(control.currentIndex)
                goToAlbum(item.artist, item.album)
            }
        }

        onFavClicked:
        {
            listModel.list.fav(listModel.mappedToSource(contextMenu.index), !FB.Tagging.isFav(listModel.get(contextMenu.index).url))
        }

        onQueueClicked: Player.queueTracks([listModel.get(contextMenu.index)])

        onSaveToClicked:
        {
            _dialogLoader.sourceComponent = _playlistDialogComponent
            dialog.composerList.urls = filterSelection(listModel.get(contextMenu.index).url)
            dialog.open()
        }

        onOpenWithClicked: FB.FM.openLocation(filterSelection(listModel.get(contextMenu.index).url))

        onDeleteClicked:
        {
            _dialogLoader.sourceComponent = _removeDialogComponent
            dialog.urls = filterSelection(listModel.get(contextMenu.index).url)
            dialog.open()
        }

        onInfoClicked:
        {
            //            infoView.show(listModel.get(control.currentIndex))
        }

        onEditClicked:
        {
            _dialogLoader.sourceComponent = _metadataDialogComponent
            dialog.index = contextMenu.index
            dialog.open()
        }

        onCopyToClicked:
        {
            cloudView.list.upload(contextMenu.index)
        }

        onShareClicked:
        {
            const url = listModel.get(contextMenu.index).url
            Maui.Platform.shareFiles([url])
        }
    }

    Maui.ListBrowser
    {
        id: _listBrowser
        anchors.fill: parent
        holder.visible: control.listModel.list.count === 0
        enableLassoSelection: true
        selectionMode: root.selectionMode
        currentIndex: -1

        onItemsSelected: (indexes) =>
        {
            for(var i in indexes)
            {
                selectionBar.addToSelection(listModel.get(indexes[i]))
            }
        }

        onKeyPress: (event) =>
        {
            if(event.key === Qt.Key_Return)
            {
                control.rowClicked(_listBrowser.currentIndex)
            }
        }

        section.property: control.group ? control.listModel.sort : ""
        section.criteria: control.listModel.sort === "title" ?  ViewSection.FirstCharacter : ViewSection.FullString
        section.delegate: Maui.LabelDelegate
        {
            isSection: true
            width: ListView.view.width
            //            iconSource: "view-media-artist"
            label: control.listModel.sort === "adddate" || control.listModel.sort === "releasedate" ? Maui.Handy.formatDate(Date(section), "MM/dd/yyyy") : String(section)

        }

        model: Maui.BaseModel
        {
            id: _listModel
            list: Tracks
            {
                id: _tracksList
            }
            recursiveFilteringEnabled: true
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        delegate: TableDelegate
        {
            id: delegate
            width: ListView.view.width
            height: Math.max(implicitHeight, Maui.Style.rowHeight)
            number: trackNumberVisible
            coverArt: coverArtVisible ? (control.width > 200) : coverArtVisible
            appendButton: control.showQuickActions && (Maui.Handy.isTouch ? true : delegate.hovered)

            onPressAndHold:
            {
                if(Maui.Handy.isTouch)
                    tryOpenContextMenu()
            }

            onRightClicked: tryOpenContextMenu()

            function tryOpenContextMenu() : undefined
            {
                if (allowMenu) openItemMenu(index)
            }

                onToggled: (state) => selectionBar.addToSelection(control.listModel.get(index))

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


            onAppendClicked:{
                currentIndex = index
                appendTrack(index)
            }

            onClicked:
            {
                _listBrowser.forceActiveFocus()
                currentIndex = index

                if(selectionMode)
                {
                    selectionBar.addToSelection(model)
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

                function onUriRemoved(uri)
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

        Connections
        {
            target: root

            function onContextualPlayNext(event) {
                if (_listBrowser.activeFocus)
                    Player.queueTracks([listModel.get(_listBrowser.currentIndex)])
            }
        }
    }

    function openItemMenu(index)
    {
        currentIndex = index
        contextMenu.index = index
        contextMenu.fav = FB.Tagging.isFav(listModel.get(contextMenu.index).url)
        contextMenu.titleInfo = listModel.get(contextMenu.index)
        contextMenu.show()
        rowPressed(index)
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

    function forceActiveFocus()
    {
        _listBrowser.forceActiveFocus()
    }

    function getFilterField() : Item
    {
        return _filterLoader.item
    }
    }
