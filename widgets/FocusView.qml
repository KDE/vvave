import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "../utils/Player.js" as Player
import QtGraphicalEffects 1.0

Rectangle
{
    id: control
    visible: focusView
    parent: ApplicationWindow.overlay
    anchors.fill: parent
    z: parent.z + 99999
    color: Kirigami.Theme.backgroundColor

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    focus: true
    Component.onCompleted:
    {
        _drawer.visible = false
        forceActiveFocus()
    }

    Keys.onBackPressed:
    {
        focusView = false
        event.accepted = true
    }

    Shortcut
    {
        sequence: StandardKey.Back
        onActivated: focusView = false
    }

    ColumnLayout
    {
        anchors.fill: parent
        anchors.margins: Maui.Style.space.big

        ListView
        {
            id: _listView
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height* 0.4
            orientation: ListView.Horizontal
            clip: true
            focus: true
            interactive: true
            currentIndex: currentTrackIndex
            spacing: Maui.Style.space.medium
            cacheBuffer: control.width * 1
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Center)

            highlightFollowsCurrentItem: true
            highlightMoveDuration: 0
            snapMode: ListView.SnapToOneItem
            model: mainPlaylist.listModel
            highlightRangeMode: ListView.StrictlyEnforceRange
            keyNavigationEnabled: true
            keyNavigationWraps : true
            onMovementEnded:
            {
                var index = indexAt(contentX, contentY)
                if(index !== currentTrackIndex)
                    Player.playAt(index)
            }

            Rectangle
            {
                visible: (_listView.currentIndex > 0) && (_listView.count > 1)

                height: Maui.Style.iconSizes.small
                width : height

                radius: height

                color: Kirigami.Theme.textColor
                opacity: 0.4

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            Rectangle
            {
                visible: (_listView.currentIndex < _listView.count - 1) && (_listView.count > 1)
                height: Maui.Style.iconSizes.small
                width : height

                radius: height

                color: Kirigami.Theme.textColor
                opacity: 0.4

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }

            delegate: Item
            {
                id: _delegate
                height: _listView.height
                width: _listView.width

                Rectangle
                {
                    id: _bg
                    width: parent.height * 0.7
                    height: width
                    anchors.centerIn: parent
                    radius: Maui.Style.radiusV
                    color: Kirigami.Theme.textColor

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
                    width: parent.height * 0.7
                    height: width
                    anchors.centerIn: parent

                    sourceSize.width: height
                    sourceSize.height: height

                    fillMode: Image.PreserveAspectFit
                    antialiasing: false
                    smooth: true
                    asynchronous: true

                    source: model.artwork ? model.artwork : "qrc:/assets/cover.png"

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
                                width: _image.adapt ? _image.width : Math.min(_image.width, _image.height)
                                height: _image.adapt ? _image.height : width
                                radius: Maui.Style.radiusV
                            }
                        }
                    }
                }
            }
        }

        RowLayout
        {
            Layout.fillWidth: true
            Layout.preferredHeight: Maui.Style.toolBarHeight

            ToolButton
            {
                icon.name: "view-list-details"
                onClicked: focusView = false
                Layout.alignment: Qt.AlignCenter
            }

            ColumnLayout
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
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
                    text: currentTrack.title
                    elide: Text.ElideMiddle
                    wrapMode: Text.NoWrap
                    color: control.Kirigami.Theme.textColor
                    font.weight: Font.Normal
                    font.pointSize: Maui.Style.fontSizes.big
                }

                Label
                {
                    id: _label2
                    visible: text.length
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                    text: currentTrack.artist
                    elide: Text.ElideMiddle
                    wrapMode: Text.NoWrap
                    color: control.Kirigami.Theme.textColor
                    font.weight: Font.Normal
                    font.pointSize: Maui.Style.fontSizes.medium
                    opacity: 0.7
                }
            }

            ToolButton
            {
                icon.name: "documentinfo"
                onClicked: focusView = false
                Layout.alignment: Qt.AlignCenter

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
                value: player.pos
                spacing: 0
                focus: true
                onMoved:
                {
                    player.pos = value
                }
            }

            Label
            {
                visible: text.length
                Layout.fillWidth: true
                Layout.fillHeight: false
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                text: player.transformTime(player.duration/1000)
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
            Layout.preferredHeight: Maui.Style.toolBarHeight * 2
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
                    enabled: currentTrackIndex >= 0
                    icon.color: currentBabe ? babeColor : Kirigami.Theme.textColor
                    onClicked: if (!mainlistEmpty)
                               {
                                   mainPlaylist.list.fav(currentTrackIndex, !(mainPlaylist.list.get(currentTrackIndex).fav == "1"))
                                   currentBabe = mainPlaylist.list.get(currentTrackIndex).fav == "1"
                               }
                },

                ToolButton
                {
                    icon.name: "media-skip-backward"
                    icon.color: Kirigami.Theme.textColor
                    icon.width: Maui.Style.iconSizes.big
                    icon.height: Maui.Style.iconSizes.big
                    onClicked: Player.previousTrack()
                    onPressAndHold: Player.playAt(prevTrackIndex)
                },

                ToolButton
                {
                    id: playIcon
                    icon.width: Maui.Style.iconSizes.huge
                    icon.height: Maui.Style.iconSizes.huge
                    enabled: currentTrackIndex >= 0
                    icon.color: Kirigami.Theme.textColor
                    icon.name: isPlaying ? "media-playback-pause" : "media-playback-start"
                    onClicked: player.playing = !player.playing
                },

                ToolButton
                {
                    id: nextBtn
                    icon.color: Kirigami.Theme.textColor
                    icon.width: Maui.Style.iconSizes.big
                    icon.height: Maui.Style.iconSizes.big
                    icon.name: "media-skip-forward"
                    onClicked: Player.nextTrack()
                    onPressAndHold: Player.playAt(Player.shuffle())
                },

                ToolButton
                {
                    id: shuffleBtn
                    icon.width: Maui.Style.iconSizes.big
                    icon.height: Maui.Style.iconSizes.big
                    icon.color: babeColor
                    icon.name: isShuffle ? "media-playlist-shuffle" : "media-playlist-normal"
                    onClicked:
                    {
                        isShuffle = !isShuffle
                        Maui.FM.saveSettings("SHUFFLE", isShuffle, "PLAYBACK")
                    }
                }
            ]
        }

    }

}
