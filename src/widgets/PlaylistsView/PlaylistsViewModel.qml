import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls  as Maui
import org.maui.vvave as Vvave

Maui.AltBrowser
{
    id: control

    readonly property alias list: _playlistsList

    Maui.Theme.colorSet: Maui.Theme.View
    Maui.Theme.inherit: false
    Maui.Controls.level : Maui.Controls.Secondary

    viewType: root.isWide ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List

    gridView.itemSize: 140
    gridView.itemHeight: 180

    holder.emoji:  "qrc:/assets/dialog-information.svg"
    holder.title : i18n("No Playlists!")
    holder.body: i18n("Start creating new custom playlists")

    holder.visible: count === 0

    Component
    {
        id: _removeTagDialogComponent
        Maui.InfoDialog
        {
            title: i18n("Remove '%1'?", currentPlaylist)
            message: i18n("Are you sure you want to remove this tag? This operation can not be undone.")
            onAccepted:
            {
                _playlistsList.removePlaylist(control.model.mappedToSource(control.currentIndex))
                close()
            }

            onRejected: close()
        }
    }

    Maui.ContextualMenu
    {
        id: _tagMenu

        MenuItem
        {
            text: i18n("Edit")
            icon.name: "document-edit"
            onTriggered:
            {}
        }

        MenuItem
        {
            text: i18n("Remove")
            icon.name: "edit-delete"
            onTriggered:
            {
                _dialogLoader.sourceComponent = _removeTagDialogComponent
                dialog.open()
            }
        }
    }

    model: Maui.BaseModel
    {
        id: _playlistsModel
        list: Vvave.Playlists
        {
            id: _playlistsList
        }

        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    footBar.visible: false
    headBar.forceCenterMiddleContent: false
    headBar.middleContent: Maui.SearchField
    {
        id: _filterField
        Layout.maximumWidth: 500
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignCenter
        placeholderText: i18np("Filter", "Filter %1 tags", control.count)

        KeyNavigation.up: currentView
        KeyNavigation.down: currentView

        onAccepted: _playlistsModel.filter = text
        onCleared: _playlistsModel.filter = ""
    }

    headBar.rightContent: ToolButton
    {
        icon.name: "list-add"
        onClicked:
        {
            _dialogLoader.sourceComponent = newPlaylistDialogComponent
            dialog.open()
        }
    }

    listDelegate: Maui.ListBrowserDelegate
    {
        width: ListView.view.width
        isCurrentItem: ListView.isCurrentItem

        label1.text: model.playlist

        iconSource: model.icon
        iconVisible: true
        iconSizeHint: Maui.Style.iconSizes.big

        template.iconComponent: Maui.GalleryRollTemplate
        {
            implicitHeight: Maui.Style.iconSizes.big
            implicitWidth: Maui.Style.iconSizes.big
            orientation: Qt.Horizontal
            radius: Maui.Style.radiusV
            images: model.preview.split(",")
        }

        onClicked :
        {
            control.currentIndex = index
            if(Maui.Handy.singleClick)
            {
                populate(model.key, true)
            }
        }

        onDoubleClicked :
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick)
            {
                populate(model.key, true)
            }
        }

        onRightClicked: tryOpenContextMenu()

        onPressAndHold: tryOpenContextMenu()

        function tryOpenContextMenu()
        {
            control.currentIndex = index
            currentPlaylist = model.key
            _tagMenu.show()
        }
    }

    gridDelegate : Item
    {
        height: GridView.view.cellHeight
        width: GridView.view.cellWidth

        Maui.GalleryRollItem
        {
            id: _collageDelegate
            anchors.fill: parent
            anchors.margins: Maui.Handy.isMobile ? Maui.Style.space.small : Maui.Style.space.medium
            orientation: Qt.Vertical
            imageWidth: 120
            imageHeight: 120

            isCurrentItem: parent.GridView.isCurrentItem
            images: model.preview.split(",")

            label1.text: model.playlist
            iconSource: model.icon
            template.labelSizeHint: 24

            onClicked :
            {
                control.currentIndex = index
                if(Maui.Handy.singleClick)
                {
                    populate(model.key, true)
                }
            }

            onDoubleClicked :
            {
                control.currentIndex = index
                if(!Maui.Handy.singleClick)
                {
                    populate(model.key, true)
                }
            }

            onRightClicked: tryOpenContextMenu()

            onPressAndHold: tryOpenContextMenu()

        }

        function tryOpenContextMenu()
        {
            control.currentIndex = index
            currentPlaylist = model.key
            _tagMenu.show()
        }
    }

    function getFilterField() : Item
    {
        return _filterField
    }
}
