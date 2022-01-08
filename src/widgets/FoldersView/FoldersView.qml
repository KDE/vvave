import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.kde.kirigami 2.14 as Kirigami

import "../BabeTable"
import "../../db/Queries.js" as Q
import "../../utils/Player.js" as Player

import org.maui.vvave 1.0

StackView
{
    id: control

    property string currentFolder : ""
    property Flickable flickable: currentItem.flickable

    initialItem: Maui.Page
    {
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        Kirigami.Theme.inherit: false

        headBar.middleContent: Maui.TextField
        {
            Layout.fillWidth: true
            Layout.maximumWidth: 500
            Layout.alignment: Qt.AlignCenter

            placeholderText: i18np("Filter", "Filter %1 folders", _foldersList.count)
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

            delegate: Maui.ListBrowserDelegate
            {
                width: ListView.view.width
                template.headerSizeHint: Maui.Style.rowHeight
                isCurrentItem: ListView.isCurrentItem
                iconSizeHint: Maui.Style.iconSizes.medium
                label1.text: model.label
                label2.text: model.path
                label2.wrapMode: Text.Wrap
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

            onRowClicked: Player.quickPlay(listModel.get(index))
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
