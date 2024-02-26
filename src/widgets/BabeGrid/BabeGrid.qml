import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.15

import org.mauikit.controls 1.3 as Maui

import org.maui.vvave 1.0

Maui.AltBrowser
{
    id: control
    property alias list: _albumsList
    property alias listModel: _albumsModel

    readonly property string prefix : list.query === Albums.ALBUMS ? "album" : "artist"

    readonly property int count: currentView.count

    signal albumCoverClicked(string album, string artist)
    signal playAll(string album, string artist)

    Maui.Theme.colorSet: Maui.Theme.View
    Maui.Theme.inherit: false
    headBar.visible: listModel.list.count > 1

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
            placeholderText: i18np("Filter", "Filter %1 albums", _albumsList.count)

            KeyNavigation.up: currentView
            KeyNavigation.down: currentView

            onAccepted:
            {
                //                if(text.includes(","))
                //                {
                _albumsModel.filters = text.split(",")
                //                }else
                {
                    //                    _albumsModel.filter = text
                }
            }

            onCleared: _albumsModel.clearFilters()
        }
    }

    viewType: root.isWide ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List

    gridView.itemSize: 180
    gridView.itemHeight: 180
    holder.visible: count === 0

    property string typingQuery

    Maui.Chip
    {
        z: control.z + 99999
        Maui.Theme.colorSet:Maui.Theme.Complementary
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

        label1.text: model.album ? model.album : model.artist
        label2.text: model.artist && model.album ? model.artist : ""
        iconSource: "folder-music"
        imageSource: "image://artwork/%1:".arg(control.prefix)+( control.prefix === "album" ? model.artist+":"+model.album : model.artist)
        maskRadius: Maui.Style.radiusV

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
            id: _template
            anchors.centerIn: parent

            width: control.gridView.itemSize - Maui.Style.space.medium
            height: control.gridView.itemHeight  - Maui.Style.space.medium

            isCurrentItem: parent.GridView.isCurrentItem
            maskRadius: Maui.Style.radiusV

            tooltipText: label1.text
            label1.text: model.album ? model.album : model.artist
            label2.text: model.artist && model.album ? model.artist : ""

            imageSource: "image://artwork/%1:".arg(control.prefix)+( control.prefix === "album" ? model.artist+":"+model.album : model.artist)

            iconSource: "media-album-cover"

            template.labelsVisible: settings.showTitles
            template.alignment: Qt.AlignLeft
            template.fillMode: Image.PreserveAspectFit

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

            Loader
            {
                active: !Maui.Handy.isMobile
                asynchronous: true
                parent: _template.iconContainer
                anchors.centerIn: parent
                sourceComponent: ToolButton
                {
                    icon.name: "media-playback-start"
                    icon.color: "white"
                    icon.height: 32
                    icon.width: 32
                    padding: Maui.Style.space.big
                    visible: _template.hovered

                    onClicked: control.playAll(model.album, model.artist)

                    background: Rectangle
                    {
                        color: "black"
                        radius: height
                        opacity: hovered ? 0.8 : 0.5
                    }
                }
            }
        }
    }

    function getFilterField() : Item
    {
        return _filterLoader.item
    }
    }

