import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "../../view_models"
import "../../utils/Help.js" as H

Maui.SwipeBrowserDelegate
{
    id: control

    readonly property color bgColor : Kirigami.Theme.backgroundColor
    property string labelColor: control.isCurrentItem || hovered ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
    property bool number : false
    property bool quickPlay : true
    property bool coverArt : false
    property bool menuItem : false
    property bool trackDurationVisible : false
    property bool trackRatingVisible: false
    property bool playingIndicator: false
    property string trackMood : model.color

    property bool remoteArtwork: false
    readonly property int altHeight : Maui.Style.rowHeight * 1.4
    readonly property bool sameAlbum :
    {
        if(coverArt)
        {
            if(list.get(index-1))
            {
                if(list.get(index-1).album === album && list.get(index-1).artist === artist) true
                else false
            }else false
        }else false
    }

    width: parent.width
    height: sameAlbum ? Maui.Style.rowHeight : altHeight
    padding: 0

    showQuickActions: quickPlay

    rightPadding: leftPadding
    leftPadding: Maui.Style.space.small
    iconSizeHint: Maui.Style.rowHeight
    label1.text: number ? model.track + ". " + model.title :  model.title
    label2.text: model.artist + " | " + model.album
    label2.visible: coverArt ? !sameAlbum : true

    label3.text: model.fav ? (model.fav == "1" ? "\uf2D1" : "") : ""
     label3.font.family: "Material Design Icons"
     label4.font.family: "Material Design Icons"
     label4.text: model.rate ? H.setStars(model.rate) : ""

     iconVisible: !sameAlbum && coverArt
     imageSource: typeof model.artwork === 'undefined' ?
              "qrc:/assets/cover.png" :
              remoteArtwork ? model.artwork :
                              ((model.artwork && model.artwork.length > 0 && model.artwork !== "NONE")? "file://"+encodeURIComponent(model.artwork) : "qrc:/assets/cover.png")


     signal play()
     signal leftClicked()

     signal artworkCoverClicked()
     signal artworkCoverDoubleClicked()

     Kirigami.Theme.backgroundColor: trackMood.length > 0 ? Qt.tint(bgColor, Qt.rgba(Qt.lighter(trackMood, 1.3).r, Qt.lighter(trackMood, 1.3).g, Qt.lighter(trackMood, 1.3).b,  0.3)):  bgColor

    quickActions: [

                Action
                {
                    icon.name: "love"
                    icon.color: model.fav === "1" ? babeColor : Kirigami.Theme.textColor
                  onTriggered: list.fav(index, !(list.get(index).fav == "1"))
                },

                Action
                {
                    icon.name: "view-media-recent"
                    onTriggered: queueTrack(index)
                },

                Action
                {
                    icon.name: "media-playback-start"
                    onTriggered: play()
                }
    ]


    function rate(stars)
    {
        trackRating.text = stars
    }
}
