import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.10
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

import "../../utils/Help.js" as H

Maui.ListBrowserDelegate
{
    id: control

    property bool showQuickActions: true
    property bool number : false
    property bool coverArt : false

    readonly property string artist : model.artist
    readonly property string album : model.album
    readonly property string title : model.title
    readonly property url url : model.url
    readonly property int rate : model.rate
    readonly property int track : model.track
    readonly property string artwork : model.artwork

    property bool sameAlbum : false

    isCurrentItem: ListView.isCurrentItem || checked

    draggable: true

    iconSizeHint: height - Maui.Style.space.small
    label1.text: control.number ? control.track + ". " + control.title :  control.title
    label2.text: control.artist + " | " + control.album
    label2.visible: control.coverArt ? !control.sameAlbum : true

    label3.font.family: "Material Design Icons"
    label3.text: control.rate ? H.setStars(control.rate) : ""

    iconVisible: !control.sameAlbum && control.coverArt
    imageSource: control.artwork ? control.artwork : "qrc:/assets/cover.png"

    template.leftMargin: iconVisible ? 0 : Maui.Style.space.medium
}
