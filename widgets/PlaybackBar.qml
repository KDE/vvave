import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtMultimedia 5.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

import "../utils/Player.js" as Player

Control
{
    id: control
    implicitHeight: visible ? _footerLayout.implicitHeight : 0

    background: Item
    {
        Image
        {
            id: artworkBg
            height: parent.height
            width: parent.width

            sourceSize.width: 500
            sourceSize.height: height

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

        Maui.Separator
        {
            position: Qt.Horizontal
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
        }
    }

    ColumnLayout
    {
        id: _footerLayout
        anchors.fill: parent
        spacing: 0

        Maui.ToolBar
        {
            Layout.fillWidth: true
            preferredHeight: Maui.Style.toolBarHeightAlt * 0.8
            position: ToolBar.Footer
            visible: player.state !== MediaPlayer.StoppedState

            leftContent: Label
            {
                id: _label1
                visible: text.length
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                text: progressTimeLabel
                elide: Text.ElideMiddle
                wrapMode: Text.NoWrap
                color: Kirigami.Theme.textColor
                font.weight: Font.Normal
                font.pointSize: Maui.Style.fontSizes.default
            }

            middleContent:  Item
            {
                Layout.fillHeight: true
                Layout.fillWidth: true

                Label
                {
                    anchors.fill: parent
                    visible: text.length
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignHCenter
                    text: root.title
                    elide: Text.ElideMiddle
                    wrapMode: Text.NoWrap
                    color: Kirigami.Theme.textColor
                    font.weight: Font.Normal
                    font.pointSize: Maui.Style.fontSizes.default
                }
            }

            rightContent: Label
            {
                id: _label2
                visible: text.length
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignHCenter
                text: durationTimeLabel
                elide: Text.ElideMiddle
                wrapMode: Text.NoWrap
                color: Kirigami.Theme.textColor
                font.weight: Font.Normal
                font.pointSize: Maui.Style.fontSizes.default
                opacity: 0.7
            }

            background: Slider
            {
                id: progressBar
                z: parent.z+1
                padding: 0
                from: 0
                to: 1000
                value: player.pos
                spacing: 0
                focus: true
                onMoved: player.pos = value
                enabled: player.playing

                background: Rectangle
                {
                    implicitWidth: progressBar.width
                    implicitHeight: progressBar.height
                    width: progressBar.availableWidth
                    height: implicitHeight
                    color: "transparent"
                    opacity: 0.4

                    Rectangle
                    {
                        width: progressBar.visualPosition * parent.width
                        height: progressBar.height
                        color: Kirigami.Theme.highlightColor
                    }
                }

                handle: Rectangle
                {
                    x: progressBar.leftPadding + progressBar.visualPosition
                       * (progressBar.availableWidth - width)
                    y: 0
                    implicitWidth: Maui.Style.iconSizes.medium
                    implicitHeight: progressBar.height
                    color: progressBar.pressed ? Qt.lighter(Kirigami.Theme.highlightColor, 1.2) : "transparent"
                }
            }
        }

        Maui.ToolBar
        {
            Layout.fillWidth: true
            Layout.preferredHeight: Maui.Style.toolBarHeight
            position: ToolBar.Footer
            visible: player.state !== MediaPlayer.StoppedState

            background: Item {}
            rightContent: ToolButton
            {
                icon.name: _volumeSlider.value === 0 ? "player-volume-muted" : "player-volume"
                onPressAndHold :
                {
                    player.volume = player.volume === 0 ? 100 : 0
                }

                onClicked:
                {
                    _sliderPopup.visible ? _sliderPopup.close() : _sliderPopup.open()
                }

                Popup
                {
                    id: _sliderPopup
                    height: 150
                    width: parent.width
                    y: -150
                    x: 0
                    //                            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPress
                    Slider
                    {
                        id: _volumeSlider
                        visible: true
                        height: parent.height
                        width: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        from: 0
                        to: 100
                        value: player.volume
                        orientation: Qt.Vertical

                        onMoved:
                        {
                            player.volume = value
                        }
                    }
                }
            }

            middleContent: [
                ToolButton
                {
                    id: babeBtnIcon
                    icon.name: "love"
                    enabled: currentTrack
                    checked:currentTrack.url ? Maui.FM.isFav(currentTrack.url) : false
                    icon.color: checked ? babeColor :  Kirigami.Theme.textColor
                    onClicked:
                    {
                        mainPlaylist.listModel.list.fav(currentTrackIndex, !Maui.FM.isFav(currentTrack.url))
                        root.currentTrackChanged()
                    }
                },

                Maui.ToolActions
                {
                    implicitHeight: Maui.Style.iconSizes.big
                    expanded: true
                    autoExclusive: false
                    checkable: false

                    Action
                    {
                        icon.name: "media-skip-backward"
                        onTriggered: Player.previousTrack()
                    }
                    //ambulatorios1@clinicaantioquia.com.co, copago martha hilda restrepo, cc 22146440 eps salud total, consulta expecialista urologo, hora 3:40 pm
                    Action
                    {
                        id: playIcon
                        text: i18n("Play and pause")
                        icon.width: Maui.Style.iconSizes.big
                        icon.height: Maui.Style.iconSizes.big
                        enabled: currentTrackIndex >= 0
                        icon.name: isPlaying ? "media-playback-pause" : "media-playback-start"
                        onTriggered: player.playing ? player.pause() : player.play()
                    }

                    Action
                    {
                        text: i18n("Next")
                        icon.name: "media-skip-forward"
                        onTriggered: Player.nextTrack()
                        //                    onPressAndHold: Player.playAt(Player.shuffle())
                    }
                },

                ToolButton
                {
                    id: shuffleBtn
                    icon.color: babeColor
                    icon.name: playlist.shuffle ? "media-playlist-shuffle" : "media-playlist-normal"
                    onClicked:
                    {
                        playlist.shuffle = !playlist.shuffle
                    }
                }
            ]
        }
    }
}
