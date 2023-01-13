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

    property alias currentIndex: _gridView.currentIndex
    property alias listModel : _listModel
    property alias gridView : _gridView
    property alias list : _list

    clip: true
    visible: _gridView.count

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


    Maui.GridView
    {
        id: _gridView
        scrollView.orientation: Qt.Horizontal
        verticalScrollBarPolicy: ScrollBar.AlwaysOff
        adaptContent: false
        horizontalScrollBarPolicy:  ScrollBar.AsNeeded
        currentIndex: -1
        Layout.fillWidth: true
        Layout.preferredHeight: 220
        flickable.flow: GridView.FlowTopToBottom
        itemSize: 160
        itemHeight: 64
        model: Maui.BaseModel
        {
            id: _listModel
            list: Vvave.Tracks
            {
                id: _list
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

            Maui.ListBrowserDelegate
            {
                anchors.fill: parent
                anchors.margins: Maui.Style.space.small
                maskRadius: radius
                label1.text: model.title
                label2.text: model.artist
                imageSource: "image://artwork/album:"+ model.artist+":"+model.album
                iconVisible: true
                label1.font.bold: true
                label1.font.weight: Font.Bold
                iconSource: "media-album-cover"
                template.fillMode: Image.PreserveAspectFit
                isCurrentItem: parent.GridView.isCurrentItem || checked

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
