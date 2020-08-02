import QtQuick 2.14
import QtQuick.Controls 2.14

import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

import "../view_models/BabeTable"
import "../db/Queries.js" as Q

import org.maui.vvave 1.0

StackView
{
    id: control
    clip: true

    property alias list : _filterList
    property alias listModel : _filterList.model
    property var tracks : []
    property string currentFolder : ""
    property Flickable flickable: currentItem.flickable

    initialItem: Maui.GridBrowser
    {
        id: browser
        checkable: false
        model: Maui.BaseModel
        {
            list: Folders
            {
                folders: Vvave.folders
            }
        }

        cellHeight: itemSize * 1.2
        onItemClicked:
        {
            browser.currentIndex = index
            if(Maui.Handy.singleClick)
            {
                var item = browser.model.get(index)
                _filterList.listModel.filter = ""
                currentFolder = item.path
                filter()
                control.push(_filterList)
            }
        }

        onItemDoubleClicked:
        {
            browser.currentIndex = index
            if(!Maui.Handy.singleClick)
            {
                var item = browser.model.get(index)
                _filterList.listModel.filter = ""
                currentFolder = item.path
                filter()
                control.push(_filterList)
            }
        }

        Maui.Holder
        {
            anchors.fill: parent
            visible: !browser.count
            emoji: "qrc:/assets/dialog-information.svg"
            isMask: true
            title : i18n("No Folders!")
            body: i18n("Add new music to your sources to browse by folders")
            emojiSize: Maui.Style.iconSizes.huge
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
    }

    function filter()
    {
        var where = "source = \""+currentFolder+"\""
        _filterList.list.query = (Q.GET.tracksWhere_.arg(where))
    }
}
