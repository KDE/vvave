import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "../utils/Player.js" as Player
import QtGraphicalEffects 1.0

Maui.Page
{
    id: control
    visible: focusView

    z: parent.z + 99999
    title: qsTr("Now Playing")
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    focus: true
    Component.onCompleted:
    {
        _drawer.visible = false
        forceActiveFocus()
    }

    Component.onDestruction:
    {
        _drawer.visible = true
    }

    headBar.background: null
    headBar.height: Maui.Style.toolBarHeight
    headBar.leftContent: ToolButton
    {
        icon.name: "go-previous"
        onClicked: focusView = false
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

            source: currentArtwork
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

    ColumnLayout
    {
        anchors.fill: parent
        anchors.margins: Maui.Style.space.big

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
                onCurrentItemChanged:
                {
                    var index = indexAt(contentX, contentY)
                    if(index !== currentTrackIndex)
                        Player.playAt(index)
                }

                delegate: Item
                {
                    id: _delegate
                    height: _listView.height
                    width: _listView.width
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
                            radius: height
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

                        RotationAnimator on rotation
                        {
                            from: 0
                            to: 360
                            duration: 5000
                            loops: Animation.Infinite
                            running: root.isPlaying && isCurrentItem
                        }

                        Image
                        {
                            id: _image
                            width: Math.min(parent.width, parent.height) * 0.9
                            height: width
                            anchors.centerIn: parent

                            sourceSize.width: 200
                            sourceSize.height: 200

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

                            Rectangle
                            {
                                color: _bg.color
                                height: parent.height * 0.25
                                width: height
                                anchors.centerIn: parent
                                radius: height
                            }

                            Rectangle
                            {
                                id: _roundRec
                                color:  control.Kirigami.Theme.backgroundColor
                                height: parent.height * 0.20
                                width: height
                                anchors.centerIn: parent
                                radius: height
                            }

                            InnerShadow
                            {
                                anchors.fill: _roundRec
                                radius: 8.0
                                samples: 16
                                horizontalOffset: 0
                                verticalOffset: 0
                                color: "#b0000000"
                                source: _roundRec
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
                                        radius: height
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

        RowLayout
        {
            Layout.fillWidth: true
            Layout.preferredHeight: Maui.Style.toolBarHeight

            ToolButton
            {
                icon.name: "view-list-details"
                checked: _drawer.visible
                onClicked:  _drawer.visible = !_drawer.visible
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
                    text: currentTrack.artist
                    elide: Text.ElideMiddle
                    wrapMode: Text.NoWrap
                    color: control.Kirigami.Theme.textColor
                    font.weight: Font.Normal
                    font.pointSize: Maui.Style.fontSizes.big
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
                    enabled: currentTrackIndex >= 0
                    checked: Maui.FM.isFav(mainPlaylist.listView.model.get(currentTrackIndex).url)
                    icon.color: checked ? babeColor :  Kirigami.Theme.textColor
                    onClicked: if (!mainlistEmpty)
                               {
                                   mainPlaylist.list.fav(currentTrackIndex, !Maui.FM.isFav(mainPlaylist.listModel.get(currentTrackIndex).url))
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
