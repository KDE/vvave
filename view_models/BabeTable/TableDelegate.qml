import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.10
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "../../view_models"
import "../../utils/Help.js" as H

Maui.ItemDelegate
{
    id: control

    isCurrentItem: ListView.isCurrentItem || isSelected

    property bool showQuickActions: true
    property bool number : false
    property bool coverArt : false
    property bool showEmblem: true
    property bool keepEmblemOverlay: selectionMode
    property bool isSelected : false
    property color trackMood : model.color

    readonly property color bgColor : Kirigami.Theme.backgroundColor
    readonly property int altHeight : Maui.Style.rowHeight * 1.4
    property bool sameAlbum : false

    width: parent.width
    height: sameAlbum ? Maui.Style.rowHeight : altHeight
    padding: 0

    rightPadding: leftPadding
    leftPadding: Maui.Style.space.small

    signal play()
    signal append()
    signal leftClicked()
    signal leftEmblemClicked(int index)

    signal artworkCoverClicked()
    signal artworkCoverDoubleClicked()

    Kirigami.Theme.backgroundColor: model.color.length > 0 ? Qt.rgba(trackMood.r, trackMood.g, trackMood.b, 0.2):  bgColor

    function rate(stars)
    {
        trackRating.text = stars
    }

    RowLayout
    {
        anchors.fill: parent

        Item
        {
            Layout.fillHeight: true
            Layout.preferredWidth: _leftEmblemIcon.height + Maui.Style.space.small
            visible: (control.keepEmblemOverlay || control.isSelected) && control.showEmblem

            Maui.Badge
            {
                id: _leftEmblemIcon
                anchors.centerIn: parent
                iconName: control.isSelected ? "list-remove" : "list-add"
                onClicked: control.leftEmblemClicked(index)
                size: Maui.Style.iconSizes.small
            }
        }

        Maui.ListItemTemplate
        {
            id: _template
            Layout.fillWidth: true
            Layout.fillHeight: true
            isCurrentItem: control.isCurrentItem
            iconSizeHint: height - Maui.Style.space.small
            label1.text: control.number ? model.track + ". " + model.title :  model.title
            label2.text: model.artist + " | " + model.album
            label2.visible: control.coverArt ? !control.sameAlbum : true

            label3.text: model.fav ? (model.fav == "1" ? "\uf2D1" : "") : ""
            label3.font.family: "Material Design Icons"
            label4.font.family: "Material Design Icons"
            label4.text: model.rate ? H.setStars(model.rate) : ""

            iconVisible: !control.sameAlbum && control.coverArt
            imageSource: model.artwork ? model.artwork : "qrc:/assets/cover.png"

            ToolButton
            {
                Layout.fillHeight: true
                Layout.preferredWidth: implicitWidth
                visible: showQuickActions && (Kirigami.Settings.isMobile ? true : control.hovered)
                icon.name: "media-playlist-append"
                onClicked: control.append()
                opacity: control.hovered ? 0.8 : 0.6
            }
        }


    }
}
