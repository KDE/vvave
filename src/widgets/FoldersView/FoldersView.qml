import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui

import "../BabeTable"
import "../../db/Queries.js" as Q
import "../../utils/Player.js" as Player

import org.maui.vvave

StackView
{
    id: control

    property string currentFolder : ""
    readonly property Flickable flickable: currentItem.flickable

    initialItem: Maui.Page
    {
        Maui.Theme.colorSet: Maui.Theme.View
        Maui.Theme.inherit: false
        Maui.Controls.level : Maui.Controls.Secondary

        headerMargins: Maui.Style.contentMargins
        headBar.middleContent: Maui.SearchField
        {
            id: _filterField
            Layout.fillWidth: true
            Layout.maximumWidth: 500
            Layout.alignment: Qt.AlignCenter

            placeholderText: i18np("Filter %1 folder", "Filter %1 folders", _foldersList.count)

            KeyNavigation.up: browser
            KeyNavigation.down: browser

            onAccepted: browser.model.filter = text
            onCleared:  browser.model.filter = text
        }

        Maui.Holder
        {
            anchors.fill: parent
            visible: _foldersList.count === 0
            emoji: "qrc:/assets/dialog-information.svg"
            title : i18n("No Folders!")
            body: i18n("Add new music to your sources to browse by folders")
            Action
            {
                text: i18n("Add sources")
                onTriggered: openSettingsDialog()
            }
        }

        Maui.ListBrowser
        {
            id: browser

            anchors.fill: parent

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

            section.property: browser.model.sort
            section.criteria: ViewSection.FirstCharacter
            section.delegate: Maui.LabelDelegate
            {
                isSection: true
                width: ListView.view.width
                text: String(section)
            }

            delegate: Maui.ListBrowserDelegate
            {
                width: ListView.view.width
                template.headerSizeHint: Maui.Style.rowHeight
                isCurrentItem: ListView.isCurrentItem
                iconSizeHint: Maui.Style.iconSizes.medium
                label1.text: model.label
                label2.text: model.path.replace("file://", "")
                label2.wrapMode: Text.Wrap
                iconSource: model.icon
                template.isMask: true

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
        function getFilterField() : Item
        {
            return _filterField
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

            headBar.visible: true
            headBar.farLeftContent: ToolButton
            {
                icon.name: "go-previous"
                onClicked: control.pop()
            }

            onRowClicked: (index) => Player.quickPlay(listModel.get(index))
            onAppendTrack: (index) => Player.addTrack(listModel.get(index))
            onQueueTrack: (index) => Player.queueTracks([listModel.get(index)], index)

            onPlayAll: Player.playAllModel(listModel.list)
            onAppendAll: Player.appendAllModel(listModel.list)
            onShuffleAll: Player.shuffleAllModel(listModel.list)
        }
    }

    function filter(folder)
    {
        currentFolder = folder
        control.push(_filterListComponent)
    }

    function getFilterField() : Item
    {
        return control.currentItem.getFilterField()
    }

    function getGoBackFunc()
    {
        if (control.depth > 1)
            return () => { control.pop() }
        else
            return null
    }
}
