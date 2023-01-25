import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.maui.vvave 1.0 as Vvave
import org.mauikit.filebrowsing 1.3 as FB

import "BabeTable"
import "BabeGrid"

import "../db/Queries.js" as Q
import "../utils/Player.js" as Player

Maui.SettingsSection
{
    id: control
    Maui.Theme.colorSet: Maui.Theme.Window
    Maui.Theme.inherit: false

    property alias currentIndex: _gridView.currentIndex
    property alias listModel : _listModel
    property alias browser : _gridView
    property alias list : _list

    property int orientation: Qt.Horizontal
    property bool coverArt: settings.showArtwork

    padding: Maui.Style.space.medium

    visible: _gridView.count

    background: Rectangle
    {
        color: Maui.Theme.backgroundColor
        radius: Maui.Style.radiusV
    }

    template.template.content: Maui.ToolButtonMenu
    {
        icon.name: "media-playback-start"

        MenuItem
        {
            icon.name : "media-playback-start"
            text: i18n("Play All")
            onTriggered: Player.playAllModel(control.listModel.list)

        }

        MenuItem
        {
            icon.name : "media-playlist-append"
            text: i18n("Append All")
            onTriggered: Player.appendAllModel(control.listModel.list)
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

        onClosed: control.currentIndex = -1
    }


    Maui.GridView
    {
        id: _gridView
        clip: true

        enableLassoSelection: true

        currentIndex: -1

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: 220

        flickable.flow: control.orientation ===  Qt.Horizontal ? GridView.FlowTopToBottom : GridView.FlowLeftToRight

        itemSize: control.orientation === Qt.Vertical ? Math.max(Math.floor(_gridView.width/ 3), 200) : 200
        itemHeight: 64
        scrollView.orientation: control.orientation
        adaptContent: control.orientation ===  Qt.Horizontal ? false : true

        verticalScrollBarPolicy: ScrollBar.AlwaysOff
        horizontalScrollBarPolicy:  ScrollBar.AsNeeded

        model: Maui.BaseModel
        {
            id: _listModel
            list: Vvave.Tracks
            {
                id: _list
            }
        }

        onItemsSelected:
        {
            for(var i in indexes)
            {
                selectionBar.addToSelection(control.listModel.get(indexes[i]))
            }
        }

        Connections
        {
            target: player
            function onFinished()
            {
                _listModel.list.refresh()
            }
        }

        delegate: Item
        {
            height: GridView.view.cellHeight
            width: GridView.view.cellWidth

            TableDelegate
            {
                id: delegate
                coverArt: control.coverArt
                anchors.fill: parent
                anchors.margins: Maui.Style.space.small
                appendButton: (Maui.Handy.isTouch ? true : delegate.hovered)
                onAppendClicked:
                {
                    control.currentIndex = index
                    Player.appendTrack(listModel.get(index))
                }
                label2.text: model.artist

                isCurrentItem: parent.GridView.isCurrentItem || checked

                onToggled: selectionBar.addToSelection(control.listModel.get(index))
                checked: selectionBar.contains(model.url)
                checkable: selectionMode

                Drag.keys: ["text/uri-list"]
                Drag.mimeData: Drag.active ?
                                   {
                                       "text/uri-list": model.url
                                   } : {}

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

            onClicked:
            {
                _gridView.currentIndex = index
                if(Maui.Handy.singleClick)
                {
                    Player.quickPlay(_listModel.get(_gridView.currentIndex))
                }
            }

            onPressAndHold: { if(Maui.Handy.isTouch) openItemMenu(index) }
            onRightClicked: openItemMenu(index)

            onDoubleClicked:
            {
                _gridView.currentIndex = index
                if(!Maui.Handy.singleClick)
                {
                    Player.quickPlay(_listModel.get(_gridView.currentIndex))
                }
            }
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
}
}
