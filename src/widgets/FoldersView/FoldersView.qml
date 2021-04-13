import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.kde.kirigami 2.7 as Kirigami

import "../../view_models/BabeTable"
import "../../db/Queries.js" as Q
import "../../utils/Player.js" as Player

import org.maui.vvave 1.0

StackView
{
    id: control
    clip: true

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
            sort: "label"
            sortOrder: Qt.AscendingOrder
            recursiveFilteringEnabled: true
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive

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

        headBar.leftContent: ToolButton
        {
//           enabled: _foldersList.count > 0
           icon.name: browser.viewType === Maui.AltBrowser.ViewType.List ? "view-list-icons" : "view-list-details"

            onClicked:
            {
                browser.viewType =  browser.viewType === Maui.AltBrowser.ViewType.List ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List
            }
        }

        headBar.middleContent: Maui.TextField
        {
            Layout.fillWidth: true
            placeholderText: i18n("Filter...")
            onAccepted: browser.model.filter = text
            onCleared:  browser.model.filter = text
        }

        gridDelegate: Item
        {
            height: browser.gridView.cellHeight
            width: browser.gridView.cellWidth

            Maui.GridBrowserDelegate
            {
                anchors.fill: parent
                anchors.margins: Maui.Style.space.medium
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

    Component
    {
        id: _filterListComponent

        BabeTable
        {
            list.query : Q.GET.tracksWhere_.arg("source = \""+control.currentFolder+"\"")

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

            onRowClicked: Player.quickPlay(listModel.get(index))
            onQuickPlayTrack: Player.quickPlay(listModel.get(index))

            onAppendTrack: Player.addTrack(listModel.get(index))
            onPlayAll: Player.playAllModel(listModel.list)

            onAppendAll: Player.appendAllModel(listModel.list)
            onQueueTrack: Player.queueTracks([listModel.get(index)], index)

        }
    }


    function filter(folder)
    {
        currentFolder = folder
        control.push(_filterListComponent)
    }
}
