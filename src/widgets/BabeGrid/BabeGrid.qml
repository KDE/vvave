import QtQuick.Controls 2.14
import QtQuick 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.vvave 1.0

import ".."

Maui.AltBrowser
{
    id: control
    property alias list: _albumsList
    property alias listModel: _albumsModel

    readonly property string prefix : list.query === Albums.ALBUMS ? "album" : "artist"

    readonly property int count: currentView.count

    signal albumCoverClicked(string album, string artist)

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        placeholderText: i18n("Filter")
        onAccepted: _albumsModel.filter = text
        onCleared: _albumsModel.filter = ""
    }

    viewType: root.isWide ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List

    gridView.itemSize: 140
    gridView.itemHeight: 180
    gridView.cacheBuffer: height * 5
    listView.cacheBuffer: height * 5
    holder.visible: count === 0

    property string typingQuery

     Maui.Chip
     {
         z: control.z + 99999
         Kirigami.Theme.colorSet:Kirigami.Theme.Complementary
         visible: _typingTimer.running
         label.text: typingQuery
         anchors.left: parent.left
         anchors.bottom: parent.bottom
         showCloseButton: false
         anchors.margins: Maui.Style.space.medium
     }

     Timer
     {
         id: _typingTimer
         interval: 250
         onTriggered:
         {
             const index = _albumsList.indexOfName(typingQuery)
             if(index > -1)
             {
                 control.currentIndex = _albumsModel.mappedFromSource(index)
             }

             typingQuery = ""
         }
     }

     Connections
     {
         target: control.currentView
         ignoreUnknownSignals: true
         function onKeyPress(event)
         {
             const index = control.currentIndex
             const item = _albumsModel.get(index)

             var pat = /^([a-zA-Z0-9 _-]+)$/
             if(event.count === 1 && pat.test(event.text))
             {
                 typingQuery += event.text
                 _typingTimer.restart()
             }

             //shortcut for opening
             if(event.key === Qt.Key_Return)
             {
                 albumCoverClicked(item.album, item.artist)
             }
         }
     }

    model: Maui.BaseModel
    {
        id: _albumsModel
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
        list: Albums
        {
            id: _albumsList
        }
    }

    listDelegate: Maui.ListBrowserDelegate
    {
        width: ListView.view.width
        height: Maui.Style.rowHeight * 1.8

        label1.text: model.album ? model.album : model.artist
        label2.text: model.artist && model.album ? model.artist : ""
        iconSizeHint: Maui.Style.iconSizes.small
        iconSource: "folder-music"
        imageSource: "image://artwork/%1:".arg(control.prefix)+( control.prefix === "album" ? model.artist+":"+model.album : model.artist)

        onClicked:
        {
            control.currentIndex = index
            if(Maui.Handy.singleClick)
            {
                albumCoverClicked(model.album, model.artist)
            }
        }

        onDoubleClicked:
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick)
            {
                albumCoverClicked(model.album, model.artist)
            }
        }
    }

    gridDelegate: Item
    {
        height: GridView.view.cellHeight
        width: GridView.view.cellWidth

        Maui.GridBrowserDelegate
        {
            anchors.centerIn: parent
            width: control.gridView.itemSize - Maui.Style.space.medium
            height:control.gridView.itemHeight  - Maui.Style.space.medium

            isCurrentItem: parent.GridView.isCurrentItem
            maskRadius: radius
            label1.text: model.album ? model.album : model.artist
            label2.text: model.artist && model.album ? model.artist : ""
            imageSource: "image://artwork/%1:".arg(control.prefix)+( control.prefix === "album" ? model.artist+":"+model.album : model.artist)
            label1.font.bold: true
            label1.font.weight: Font.Bold
            iconSource: "media-album-cover"
            template.labelSizeHint: 40

            onClicked:
            {
                control.currentIndex = index
                if(Maui.Handy.singleClick)
                {
                    albumCoverClicked(model.album, model.artist)
                }
            }

            onDoubleClicked:
            {
                control.currentIndex = index
                if(!Maui.Handy.singleClick)
                {
                    albumCoverClicked(model.album, model.artist)
                }
            }
        }
    }
}

