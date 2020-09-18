import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.7 as Kirigami

import "../view_models/BabeTable"
import "../db/Queries.js" as Q
import "../utils/Player.js" as Player

import org.maui.vvave 1.0

StackView
{
    id: control
    clip: true

    property alias list : _filterList
    property alias listModel : _filterList.listModel
    property var tracks : []
    property string currentFolder : ""
    property Flickable flickable: currentItem.flickable

    initialItem: Maui.AltBrowser
    {
        id: browser

        holder.visible: false
        holder.emoji: "qrc:/assets/dialog-information.svg"
        holder.title : i18n("No Folders!")
        holder.body: i18n("Add new music to your sources to browse by folders")
        holder.emojiSize: Maui.Style.iconSizes.huge

        model: Maui.BaseModel
        {
            list: Folders
            {
                id: _foldersList
                folders: Vvave.folders
            }
        }

        viewType: control.width > Kirigami.Units.gridUnit * 25 ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List

        gridView.itemSize: 120
        gridView.itemHeight: gridView.itemSize * 1.2

        listView.snapMode: ListView.SnapOneItem

        headBar.leftContent: Maui.ToolActions
        {
            autoExclusive: true
            expanded: isWide
            currentIndex : browser.viewType === Maui.AltBrowser.ViewType.List ? 0 : 1
            display: ToolButton.TextBesideIcon

            Action
            {
                text: i18n("List")
                icon.name: "view-list-details"
                onTriggered: browser.viewType = Maui.AltBrowser.ViewType.List
            }

            Action
            {
                text: i18n("Grid")
                icon.name: "view-list-icons"
                onTriggered: browser.viewType= Maui.AltBrowser.ViewType.Grid
            }
        }

        headBar.middleContent: Maui.TextField
        {
            Layout.fillWidth: true
            placeholderText: i18n("Filter...")
            onAccepted: browser.model.filter = text
            onCleared:  browser.model.filter = text
        }

        gridDelegate: Maui.GridBrowserDelegate
        {
            height: browser.gridView.cellHeight
            width: browser.gridView.cellWidth

            iconSizeHint: height * 0.6
            label1.text: model.label
            iconSource: model.icon
            padding: Maui.Style.space.medium
            isCurrentItem: GridView.isCurrentItem
            tooltipText: model.path

            onClicked:
            {
                browser.currentIndex = index
                if(Maui.Handy.singleClick)
                {
                    filter(model.path)
                }
            }

            onDoubleClicked:
            {
                browser.currentIndex = index
                if(!Maui.Handy.singleClick)
                {
                    filter(model.path)
                }
            }
        }

        listDelegate: Maui.ListBrowserDelegate
        {
            width: ListView.view.width
            height: Maui.Style.rowHeight * 1.5            
            isCurrentItem: ListView.isCurrentItem
            iconSizeHint: Maui.Style.iconSizes.big
            label1.text: model.label
            label2.text: model.path
            label3.text: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")
            iconSource: model.icon

            onClicked:
            {
                browser.currentIndex = index
                if(Maui.Handy.singleClick)
                {
                    filter(model.path)
                }
            }

            onDoubleClicked:
            {
                browser.currentIndex = index
                if(!Maui.Handy.singleClick)
                {
                    filter(model.path)
                }
            }
        }
    }

    BabeTable
    {
        id: _filterList
        coverArtVisible: true
        holder.emoji: "qrc:/assets/dialog-information.svg"
        holder.isMask: true
        holder.title : i18n("No Tracks!")
        holder.body: i18n("This source folder seems to be empty!")
        holder.emojiSize: Maui.Style.iconSizes.huge
        headBar.visible: true
        headBar.farLeftContent: ToolButton
        {
            icon.name: "go-previous"
            onClicked: control.pop()
        }

        onRowClicked: Player.quickPlay(foldersView.list.model.get(index))
        onQuickPlayTrack: Player.quickPlay(foldersView.list.model.get(index))

        onAppendTrack: Player.addTrack(foldersView.listModel.get(index))
        onPlayAll: Player.playAll(foldersView.listModel.getAll())

        onAppendAll: Player.appendAll(foldersView.listModel.getAll())
        onQueueTrack: Player.queueTracks([foldersView.list.model.get(index)], index)
    }

    function filter(folder)
    {
        _filterList.listModel.filter = ""
        currentFolder = folder
        const where = "source = \""+currentFolder+"\""
        _filterList.list.query = (Q.GET.tracksWhere_.arg(where))
        control.push(_filterList)
    }
}
