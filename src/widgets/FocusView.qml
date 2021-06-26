import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import QtGraphicalEffects 1.0

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.vvave 1.0 as Vvave

import "../utils/Player.js" as Player

import "../widgets/InfoView"

Maui.Page
{
    id: control

    title: _stackView.depth === 2 ? i18n("Information") : i18n("Now Playing")

    StackView.onActivated:
    {
        forceActiveFocus()
    }

    StackView.onDeactivated:
    {
        _drawer.visible = true
    }

    headBar.visible: true
    headBar.background: null
    headBar.height: Maui.Style.toolBarHeight
    headBar.leftContent: [
        ToolButton
        {
            icon.name: "go-previous"
            onClicked:
            {
                if(_stackView.depth === 2)
                    _stackView.pop()
                else
                    toggleFocusView()
            }
        },

        ToolButton
        {
            icon.name: _drawer.visible ? "sidebar-collapse" : "sidebar-expand"
            checked: _drawer.visible
            onClicked: _drawer.toggle()
        }
    ]

    headBar.farRightContent: Maui.WindowControls
    {
        side: Qt.RightEdge
    }

    headBar.rightContent: ToolButton
    {
        icon.name: "documentinfo"
        onClicked:
        {
            _stackView.push(_infoComponent)
        }
    }

    Keys.onBackPressed:
    {
        toggleFocusView()
        event.accepted = true
    }

    Shortcut
    {
        sequence: StandardKey.Back
        onActivated: toggleFocusView()
    }

    background: Item
    {
        Image
        {
            id: artworkBg
            height: parent.height
            width: parent.width

            sourceSize.width: 500
            sourceSize.height: 600

            fillMode: Image.PreserveAspectCrop
            antialiasing: true
            smooth: true
            asynchronous: true
            cache: true

            source: "image://artwork/album:"+currentTrack.artist + ":"+ currentTrack.album
        }

        FastBlur
        {
            id: fastBlur
            anchors.fill: parent
            source: artworkBg
            radius: 100
            transparentBorder: false
            cached: true

            Rectangle
            {
                anchors.fill: parent
                color: Kirigami.Theme.backgroundColor
                opacity: 0.8
            }
        }
    }

    Component
    {
        id: _infoComponent

        InfoView
        {

        }
    }

    StackView
    {
        id: _stackView
        anchors.fill: parent
        anchors.margins: Maui.Style.space.big

        initialItem: Loader
        {
            asynchronous: true

            ColumnLayout
            {
                anchors.fill: parent
                RowLayout
                {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    Layout.maximumHeight: 300

                    clip: true

                    Item
                    {
                        Layout.fillHeight: true
                        Layout.preferredWidth: Maui.Style.iconSizes.big

                        Rectangle
                        {
                            visible: (_listView.currentIndex > 0) && (_listView.count > 1)

                            height: Maui.Style.iconSizes.small
                            width : height

                            radius: height

                            color: Kirigami.Theme.textColor
                            opacity: 0.4

                            anchors.centerIn: parent
                        }
                    }

                    ListView
                    {
                        id: _listView
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        orientation: ListView.Horizontal

                        clip: false
                        focus: true
                        interactive: true

                        currentIndex: root.currentTrackIndex
                        spacing: 0
                        cacheBuffer: control.width

                        highlightFollowsCurrentItem: true
                        highlightMoveDuration: 0
                        snapMode: ListView.SnapOneItem
                        model: mainPlaylist.listModel
                        highlightRangeMode:ListView.ApplyRange

                        keyNavigationEnabled: true
                        keyNavigationWraps : true

                        onMovementEnded:
                        {
                            var index = indexAt(contentX, contentY)
                            if(index !== root.currentTrackIndex && index >= 0)
                                Player.playAt(index)
                        }

                        delegate: Item
                        {
                            id: _delegate
                            height: ListView.view.height
                            width: ListView.view.width
                            property bool isCurrentItem : ListView.isCurrentItem

                            Item
                            {
                                height: Math.min(parent.height, 300)
                                width: Math.min(parent.width, 300)

                                anchors.centerIn: parent

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

                                    source: "image://artwork/album:"+model.artist + ":"+ model.album

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
                        }
                    }

                    Item
                    {
                        Layout.fillHeight: true
                        Layout.preferredWidth: Maui.Style.iconSizes.big

                        Rectangle
                        {
                            anchors.centerIn: parent
                            visible: (_listView.currentIndex < _listView.count - 1) && (_listView.count > 1)
                            height: Maui.Style.iconSizes.small
                            width : height

                            radius: height

                            color: Kirigami.Theme.textColor
                            opacity: 0.4
                        }
                    }
                }



                ColumnLayout
                {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Maui.Style.toolBarHeight

                    Layout.alignment: Qt.AlignCenter
                    spacing: 0

                    Label
                    {
                        id: _label1
                        visible: text.length
                        Layout.fillWidth: true
                        Layout.fillHeight: false
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignHCenter
                        text: root.currentTrack.title
                        elide: Text.ElideMiddle
                        wrapMode: Text.NoWrap
                        color: control.Kirigami.Theme.textColor
                        font.weight: Font.Normal
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
                        text: root.currentTrack.artist
                        elide: Text.ElideMiddle
                        wrapMode: Text.NoWrap
                        color: control.Kirigami.Theme.textColor
                        font.weight: Font.Normal
                        font.pointSize: Maui.Style.fontSizes.big
                        opacity: 0.7
                    }
                }




                RowLayout
                {
                    Layout.fillWidth: true

                    Label
                    {
                        visible: text.length
                        Layout.fillWidth: true
                        Layout.fillHeight: false
                        verticalAlignment: Qt.AlignVCenter
                        horizontalAlignment: Qt.AlignHCenter
                        text: progressTimeLabel
                        elide: Text.ElideMiddle
                        wrapMode: Text.NoWrap
                        color: control.Kirigami.Theme.textColor
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
                        text: durationTimeLabel
                        elide: Text.ElideMiddle
                        wrapMode: Text.NoWrap
                        color: control.Kirigami.Theme.textColor
                        font.weight: Font.Normal
                        font.pointSize: Maui.Style.fontSizes.medium
                        opacity: 0.7
                    }
                }

                Maui.ToolBar
                {
                    preferredHeight: Maui.Style.toolBarHeight * 2
                    Layout.fillWidth: true

                    position: ToolBar.Footer

                    background: null

                    middleContent: [
                        ToolButton
                        {
                            id: babeBtnIcon
                            icon.width: Maui.Style.iconSizes.big
                            icon.height: Maui.Style.iconSizes.big
                            icon.name: "love"
                            flat: true
                            enabled: root.currentTrack
                            checked: root.currentTrack.url ? FB.Tagging.isFav(root.currentTrack.url) : false
                            icon.color: checked ? babeColor :  Kirigami.Theme.textColor

                            onClicked:
                            {
                                mainPlaylist.listModel.list.fav(root.currentTrackIndex, !FB.Tagging.isFav(root.currentTrack.url))
                                root.currentTrackChanged()
                            }
                        },

                        ToolButton
                        {
                            icon.name: "media-skip-backward"
                            flat: true
                            icon.color: Kirigami.Theme.textColor
                            icon.width: Maui.Style.iconSizes.big
                            icon.height: Maui.Style.iconSizes.big
                            onClicked: Player.previousTrack()
                        },

                        ToolButton
                        {
                            id: playIcon
                            flat: true
                            icon.width: Maui.Style.iconSizes.huge
                            icon.height: Maui.Style.iconSizes.huge
                            enabled: root.currentTrackIndex >= 0
                            icon.color: Kirigami.Theme.textColor
                            icon.name: player.playing ? "media-playback-pause" : "media-playback-start"
                            onClicked: player.playing ? player.pause() : player.play()
                        },

                        ToolButton
                        {
                            id: nextBtn
                            flat: true
                            icon.color: Kirigami.Theme.textColor
                            icon.width: Maui.Style.iconSizes.big
                            icon.height: Maui.Style.iconSizes.big
                            icon.name: "media-skip-forward"
                            onClicked: Player.nextTrack()
                        },

                        ToolButton
                        {
                            id: shuffleBtn
                            flat: true
                            icon.width: Maui.Style.iconSizes.big
                            icon.height: Maui.Style.iconSizes.big

                            icon.name: switch(playlist.playMode)
                                       {
                                       case Vvave.Playlist.Normal: return "media-playlist-normal"
                                       case Vvave.Playlist.Shuffle: return "media-playlist-shuffle"
                                       case Vvave.Playlist.Repeat: return "media-playlist-repeat"
                                       }
                            onClicked:
                            {
                                switch(playlist.playMode)
                                {
                                case Vvave.Playlist.Normal:
                                    playlist.playMode = Vvave.Playlist.Shuffle
                                    break

                                case Vvave.Playlist.Shuffle:
                                    playlist.playMode = Vvave.Playlist.Repeat
                                    break


                                case Vvave.Playlist.Repeat:
                                    playlist.playMode = Vvave.Playlist.Normal
                                    break
                                }
                            }
                        }
                    ]
                }
            }
        }
    }
}
