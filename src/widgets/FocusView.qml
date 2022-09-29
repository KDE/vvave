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

Pane
{
    id: control

    focus: true

    readonly property string progressTimeLabel: player.transformTime((player.duration/1000) * (player.pos/player.duration))
    readonly property string durationTimeLabel: player.transformTime((player.duration/1000))

    Maui.Style.adaptiveColorSchemeSource : Vvave.Vvave.artworkUrl(currentTrack.artist, currentTrack.album)

    Keys.enabled: true
    Keys.onPressed:
    {
        console.log("KEY PRESSED")
        if((event.key == Qt.Key_K) && (event.modifiers & Qt.ControlModifier))
        {
            _filterField.forceActiveFocus()
            event.accepted = true
        }
    }

    Keys.onBackPressed:
    {
        toggleFocusView()
        event.accepted = true
    }

    Keys.onLeftPressed:
    {
        Player.previousTrack()
    }

    Keys.onRightPressed:
    {
        Player.nextTrack()
    }

    Keys.onUpPressed:
    {
        if(player.playing)
            player.pause()
        else
            player.play()
    }

    Shortcut
    {
        sequence: StandardKey.Back
        onActivated: toggleFocusView()
    }

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
                icon.name: _focusStackView.depth === 2 ? "go-previous" : "go-down"
                onClicked:
                {
                    if(_focusStackView.depth === 2)
                    {
                        _focusStackView.pop()
                    }
                }
            }
        }
    }


    StackView
    {
        id: _focusStackView
        anchors.fill: parent
        Keys.forwardTo: control

        initialItem: Loader
        {
            focus: true
            asynchronous: true

            sourceComponent: Maui.Page
            {
                showCSDControls: settings.focusViewDefault
                background: null
                headBar.background: null
                footBar.background: null
                footBar.forceCenterMiddleContent: root.isWide
                footBar.middleContent: Maui.SearchField
                {
                    id: _filterField
                    placeholderText: i18n("Find")
                    Layout.alignment: Qt.AlignCenter
                    Layout.maximumWidth: 500
                    Layout.fillWidth: true
                    clip: false
                    onTextChanged:
                    {
                        if(text.length > 2)
                        {
                            _list.list.query = Q.GET.tracksWhere_.arg("t.title LIKE \"%"+text+"%\" OR t.artist LIKE \"%"+text+"%\" OR t.album LIKE \"%"+text+"%\" OR t.genre LIKE \"%"+text+"%\"")
                            _results.open()
                        }else
                        {
                            if(_results.visible)
                            {
                                _results.close()
                            }
                        }
                    }

                    Popup
                    {
                        id: _results
                        parent: control.footBar
                        y: 0 - (height)
                        x: 0
                        width: parent.width
                        height: Math.min(500,Math.max(_list.listBrowser.implicitHeight, 300))

                        onClosed: _filterField.clear()

                        BabeTable
                        {
                            id: _list
                            headBar.visible: false
                            anchors.fill: parent
                            coverArtVisible: true
                            clip: true

                            holder.emoji: "qrc:/assets/dialog-information.svg"
                            holder.title : i18n("No Results!")
                            holder.body: i18n("Try with something else")

                            onRowClicked:
                            {
                                Player.quickPlay(listModel.get(index))
                                _results.close()
                            }

                            onAppendTrack:
                            {
                                Player.addTrack(listModel.get(index))
                            }

                            onPlayAll:
                            {
                                Player.playAllModel(listModel.list)
                                _results.close()

                            }

                            onAppendAll:
                            {
                                Player.appendAllModel(listModel.list)
                                _results.close()

                            }

                            onQueueTrack:
                            {
                                Player.queueTracks([listModel.get(index)], index)
                            }
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

                            onMovementEnded:
                            {
                                var index = indexAt(contentX, contentY)
                                if(index !== root.currentTrackIndex && index >= 0)
                                    Player.playAt(index)
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
                                        radius: Maui.Style.radiusV
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
                        Layout.fillWidth: true
                        Layout.maximumWidth: 300
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Maui.Style.space.medium

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
                            checked: _focusStackView.depth === 2
                            onClicked:
                            {
                                if(_focusStackView.depth === 2)
                                {
                                    _focusStackView.pop()
                                }else
                                {
                                    _focusStackView.push(_infoComponent)
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



                    RowLayout
                    {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter

                        Label
                        {
                            visible: text.length
                            Layout.fillWidth: true
                            Layout.fillHeight: false
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            text: control.progressTimeLabel
                            elide: Text.ElideMiddle
                            wrapMode: Text.NoWrap
                            color: control.Maui.Theme.textColor
                            font.weight: Font.Normal
                            font.pointSize: Maui.Style.fontSizes.medium
                            opacity: 0.7
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

                        Label
                        {
                            visible: text.length
                            Layout.fillWidth: true
                            Layout.fillHeight: false
                            verticalAlignment: Qt.AlignVCenter
                            horizontalAlignment: Qt.AlignHCenter
                            text: control.durationTimeLabel
                            elide: Text.ElideMiddle
                            wrapMode: Text.NoWrap
                            color: control.Maui.Theme.textColor
                            font.weight: Font.Normal
                            font.pointSize: Maui.Style.fontSizes.medium
                            opacity: 0.7
                        }
                    }


                }
            }
        }
    }

    function forceActiveFocus()
    {
        _focusStackView.initialItem.forceActiveFocus()
    }

    Component.onCompleted:
    {
        forceActiveFocus()
    }
}
