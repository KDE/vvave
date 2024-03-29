import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

import QtGraphicalEffects 1.0

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.vvave 1.0 as Vvave

import "../utils/Player.js" as Player

import "../widgets/InfoView"
import "BabeTable"

import "../db/Queries.js" as Q

StackView
{
    id: control

    focus: true
    padding: 0

    property alias loader: _loader

    readonly property string progressTimeLabel: player.transformTime((player.duration/1000) * (player.pos/player.duration))
    readonly property string durationTimeLabel: player.transformTime((player.duration/1000))

    Maui.Style.adaptiveColorSchemeSource : Vvave.Vvave.artworkUrl(currentTrack.artist, currentTrack.album)

    background: Rectangle
    {
        color: Maui.Theme.backgroundColor

        Behavior on color
        {
            Maui.ColorTransition{}
        }

        onColorChanged:
        {
            setAndroidStatusBarColor()
        }

        Loader
        {
            anchors.fill: parent
            active: Maui.Style.enableEffects
            asynchronous: true

            sourceComponent: Item
            {
                Image
                {
                    id: artworkBg
                    height: parent.height *3
                    width: parent.width *3
                    anchors.centerIn: parent

                    sourceSize.width: 400
                    sourceSize.height: 200

                    fillMode: Image.PreserveAspectCrop

                    asynchronous: true
                    cache: true

                    source: "image://artwork/album:"+currentTrack.artist + ":"+ currentTrack.album
                }

                FastBlur
                {
                    id: fastBlur
                    height: artworkBg.height
                    width: artworkBg.width
                    anchors.centerIn: parent

                    source: artworkBg
                    radius: 64
                    transparentBorder: false
                    cached: true

                    Rectangle
                    {
                        anchors.fill: parent
                        color: Maui.Theme.backgroundColor
                        opacity: 0.9
                    }
                }
            }
        }
    }

    Component
    {
        id: _infoComponent

        InfoView
        {
            headBar.background: null
            headBar.leftContent: ToolButton
            {
                icon.name: control.depth === 2 ? "go-previous" : "go-down"
                onClicked:
                {
                    if(control.depth === 2)
                    {
                        control.pop()
                    }
                }
            }
        }
    }

    Item
    {
        anchors.fill: parent
        DragHandler
        {
            acceptedDevices: PointerDevice.GenericPointer
            grabPermissions: PointerHandler.CanTakeOverFromItems | PointerHandler.CanTakeOverFromHandlersOfDifferentType | PointerHandler.ApprovesTakeOverbyAnything
            onActiveChanged: { if (active) root.startSystemMove(); }
            // Harmonize(d) with ToolBar.qml, TabBar.qml from MauiKit.
        }
    }

    initialItem: Loader
    {
        id: _loader
        focus: true
        asynchronous: true

        sourceComponent: Maui.Page
        {
            property alias filterField: _filterField
            showCSDControls: settings.focusViewDefault
            background: null
            headBar.background: null
            footBar.background: null
            footBar.forceCenterMiddleContent: root.isWide
            footBar.middleContent: Maui.TextFieldPopup
            {
                id: _filterField
                placeholderText: i18n("Find")
                Layout.alignment: Qt.AlignCenter
                Layout.maximumWidth: 500
                Layout.fillWidth: true
                clip: false
                position: ToolBar.Footer
                KeyNavigation.up: _list
                KeyNavigation.down: _list
                //                popup.height: Math.min(500,Math.max(_list.listBrowser.implicitHeight, 300))

                Timer
                {
                    id: _typeTimer
                    interval: 1700
                    onTriggered:
                    {
                        if(_filterField.text.length == 0)
                        {
                            _list.list.clear()
                            return;
                        }

                        _list.list.query = Q.GET.tracksWhere_.arg("t.title LIKE \"%"+_filterField.text+"%\" OR t.artist LIKE \"%"+_filterField.text+"%\" OR t.album LIKE \"%"+_filterField.text+"%\" OR t.genre LIKE \"%"+_filterField.text+"%\"")
                    }
                }

                onTextChanged:
                {
                    _typeTimer.start()
                }

                onClosed: _filterField.clear()

                BabeTable
                {
                    id: _list
                    headBar.visible: false
                    anchors.fill: parent
                    coverArtVisible: settings.showArtwork
                    clip: true

                    holder.emoji: "qrc:/assets/dialog-information.svg"
                    holder.title : i18n("No Results!")
                    holder.body: i18n("Try with something else")

                    onRowClicked: (index) =>
                    {
                        Player.quickPlay(listModel.get(index))
                        _filterField.close()
                    }

                    onAppendTrack: (index) =>
                    {
                        Player.addTrack(listModel.get(index))
                    }

                    onPlayAll:
                    {
                        Player.playAllModel(listModel.list)
                        _filterField.close()

                    }

                    onAppendAll:
                    {
                        Player.appendAllModel(listModel.list)
                        _filterField.close()
                    }

                    onQueueTrack: (index) =>
                    {
                        Player.queueTracks([listModel.get(index)], index)
                    }
                }
            }

            Maui.Holder
            {
                anchors.fill: parent
                visible: mainPlaylist.table.count === 0
                emoji: "qrc:/assets/view-media-track.svg"
                title : "Nothing to play!"
                body: i18n("Start putting together your playlist.")
            }

            ColumnLayout
            {
                anchors.fill: parent
                spacing: Maui.Style.space.medium
                visible: mainPlaylist.table.count > 0

                Loader
                {
                    asynchronous: true
                    active: mainPlaylist

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumHeight: 400
                    Layout.minimumHeight: 100

                    onLoaded: item.positionViewAtIndex(currentTrackIndex, ListView.Center)
                    sourceComponent: ListView
                    {
                        id: _listView
                        implicitHeight: 300

                        orientation: ListView.Horizontal

                        focus: true
                        interactive: true

                        Binding on currentIndex
                        {
                            value: currentTrackIndex
                            restoreMode: Binding.RestoreBindingOrValue
                        }

                        spacing: 0
                        highlightFollowsCurrentItem: true
                        highlightMoveDuration: 0
                        snapMode: ListView.SnapOneItem
                        model: mainPlaylist.listModel
                        highlightRangeMode: ListView.ApplyRange

                        keyNavigationEnabled: true
                        keyNavigationWraps : true

                        Timer
                        {
                            id: _flickTimer
                            interval: 1700
                            onTriggered:
                            {
                                var index = _listView.indexAt(_listView.contentX, _listView.contentY)
                                if(index !== root.currentTrackIndex && index >= 0)
                                    Player.playAt(index)
                            }
                        }

                        onMovementEnded:
                        {
                          _flickTimer.start()
                        }

                        delegate: ColumnLayout
                        {
                            height: ListView.view.height
                            width: ListView.view.width
                            spacing: Maui.Style.space.big
                            property bool isCurrentItem : ListView.isCurrentItem

                            Item
                            {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignCenter

                                Rectangle
                                {
                                    id: _bg
                                    width: _image.width + Maui.Style.space.medium
                                    height: width
                                    anchors.centerIn: parent
                                    radius: root.focusView ? Maui.Style.radiusV :  Math.min(width, height)

                                    Behavior on radius
                                    {
                                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                    }

                                    color: "#fafafa"
                                }

                                DropShadow
                                {
                                    anchors.fill: _bg
                                    horizontalOffset: 0
                                    verticalOffset: 0
                                    radius: 8.0
                                    samples: 17
                                    color: "#80000000"
                                    source: _bg
                                }

                                Image
                                {
                                    id: _image
                                    width: Math.min(parent.width, parent.height) * 0.9
                                    height: width
                                    anchors.centerIn: parent

                                    sourceSize.width: 200

                                    fillMode: Image.PreserveAspectFit
                                    antialiasing: false
                                    smooth: true
                                    asynchronous: true

                                    source: "image://artwork/album:"+model.artist + ":"+ model.album || "image://artwork/artist:"+model.artist

                                    onStatusChanged:
                                    {
                                        if (status == Image.Error)
                                            source = "qrc:/assets/cover.png";
                                    }

                                    layer.enabled: true
                                    layer.effect: OpacityMask
                                    {
                                        maskSource: Item
                                        {
                                            width: _image.width
                                            height: _image.height

                                            Rectangle
                                            {
                                                anchors.centerIn: parent
                                                width: _image.width
                                                height: _image.height
                                                radius: _bg.radius
                                            }
                                        }
                                    }
                                }
                            }

                            ColumnLayout
                            {
                                Layout.fillWidth: true
                                implicitHeight: Maui.Style.toolBarHeight
                                spacing: 0

                                Label
                                {
                                    id: _label1
                                    visible: text.length
                                    Layout.fillWidth: true
                                    Layout.fillHeight: false
                                    verticalAlignment: Qt.AlignVCenter
                                    horizontalAlignment: Qt.AlignHCenter
                                    text: model.title
                                    elide: Text.ElideMiddle
                                    wrapMode: Text.NoWrap
                                    color: Maui.Theme.textColor
                                    font.weight: Font.Bold
                                    font.pointSize: Maui.Style.fontSizes.huge
                                }

                                Label
                                {
                                    id: _label2
                                    visible: text.length
                                    Layout.fillWidth: true
                                    Layout.fillHeight: false
                                    verticalAlignment: Qt.AlignVCenter
                                    horizontalAlignment: Qt.AlignHCenter
                                    text: model.artist
                                    elide: Text.ElideMiddle
                                    wrapMode: Text.NoWrap
                                    color: Maui.Theme.textColor
                                    font.weight: Font.Normal
                                    font.pointSize: Maui.Style.fontSizes.big
                                    opacity: 0.7
                                }
                            }
                        }
                    }
                }

                RowLayout
                {
                    visible: settings.volumeControl
                    Layout.fillWidth: true
                    Layout.maximumWidth: 300

                    Layout.alignment: Qt.AlignHCenter

                    spacing: Maui.Style.space.small

                    Maui.Icon
                    {
                        implicitHeight: Maui.Style.iconSizes.small
                        implicitWidth: implicitHeight
                        source: "audio-volume-low"
                    }

                    Slider
                    {
                        id: volumeBar
                        Layout.fillWidth: true
                        padding: 0
                        spacing: 0
                        from: 0
                        to: 100
                        value: player.volume
                        stepSize: 5
                        orientation: Qt.Horizontal

                        onMoved:
                        {
                            player.volume = value
                        }
                    }

                    Maui.Icon
                    {
                        implicitHeight: Maui.Style.iconSizes.small
                        implicitWidth: implicitHeight
                        source: "audio-volume-high"
                    }
                }

                Row
                {
                    Layout.alignment: Qt.AlignCenter
                    spacing: Maui.Style.space.medium

                    ToolButton
                    {
                        id: babeBtnIcon
                        icon.name: "love"
                        flat: true
                        enabled: root.currentTrack
                        checked: root.currentTrack.url ? FB.Tagging.isFav(root.currentTrack.url) : false
                        icon.color: checked ? babeColor :  Maui.Theme.textColor

                        onClicked:
                        {
                            mainPlaylist.listModel.list.fav(root.currentTrackIndex, !FB.Tagging.isFav(root.currentTrack.url))
                            root.currentTrackChanged()
                        }
                    }

                    ToolButton
                    {

                        flat: true

                        icon.name: "documentinfo"
                        checkable: true
                        checked: control.depth === 2
                        onClicked:
                        {
                            if(control.depth === 2)
                            {
                                control.pop()
                            }else
                            {
                                control.push(_infoComponent)
                            }
                        }
                    }

                    ToolButton
                    {
                        flat: true
                        icon.name: switch(playlist.repeatMode)
                                   {
                                   case Vvave.Playlist.NoRepeat: return "media-repeat-none"
                                   case Vvave.Playlist.RepeatOnce: return "media-playlist-repeat-song"
                                   case Vvave.Playlist.Repeat: return "media-playlist-repeat"
                                   }
                        onClicked:
                        {
                            switch(playlist.repeatMode)
                            {
                            case Vvave.Playlist.NoRepeat:
                                playlist.repeatMode = Vvave.Playlist.Repeat
                                break

                            case Vvave.Playlist.Repeat:
                                playlist.repeatMode = Vvave.Playlist.RepeatOnce
                                break

                            case Vvave.Playlist.RepeatOnce:
                                playlist.repeatMode = Vvave.Playlist.NoRepeat
                                break
                            }
                        }
                    }

                    ToolButton
                    {
                        id: shuffleBtn
                        flat: true

                        icon.name: switch(playlist.playMode)
                                   {
                                   case Vvave.Playlist.Normal: return "media-playlist-normal"
                                   case Vvave.Playlist.Shuffle: return "media-playlist-shuffle"
                                   }
                        onClicked:
                        {
                            switch(playlist.playMode)
                            {
                            case Vvave.Playlist.Normal:
                                playlist.playMode = Vvave.Playlist.Shuffle
                                break

                            case Vvave.Playlist.Shuffle:
                                playlist.playMode = Vvave.Playlist.Normal
                                break
                            }
                        }
                    }
                }

                ColumnLayout
                {
                    Layout.fillWidth: true
                    Layout.maximumWidth: 600
                    Layout.margins: Maui.Style.space.medium
                    Layout.alignment: Qt.AlignCenter

                    spacing: 0

                    RowLayout
                    {
                        Layout.fillWidth: true

                        Label
                        {
                            visible: text.length
                            Layout.fillWidth: true
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignLeft
                            text: control.progressTimeLabel
                            elide: Text.ElideMiddle
                            wrapMode: Text.NoWrap
                        }

                        Item
                        {
                            Layout.fillWidth: true
                        }

                        Label
                        {
                            visible: text.length
                            Layout.fillWidth: true
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignRight
                            text: control.durationTimeLabel
                            elide: Text.ElideMiddle
                            wrapMode: Text.NoWrap
                        }
                    }

                    Slider
                    {
                        id: progressBar
                        Layout.fillWidth: true

                        padding: 0
                        from: 0
                        to: 1000
                        value: player.pos/player.duration*1000
                        spacing: 0
                        focus: true
                        onMoved: player.pos = (player.duration / 1000) * value
                    }
                }

            }
        }
    }


    function forceActiveFocus()
    {
        control.item.forceActiveFocus()
    }

    Component.onCompleted:
    {
        forceActiveFocus()
    }

    function getFilterField() : Item
    {
        return control.loader.item.filterField
    }
    }
