import QtQuick 2.10

import org.mauikit.controls 1.0 as Maui

Maui.ListBrowserDelegate
{
    id: control

    property bool number : false
    property bool coverArt : false

    readonly property string artist : model.artist
    readonly property string album : model.album
    readonly property string title : model.title
    readonly property url url : model.url
    readonly property int track : model.track

    property bool sameAlbum : false

    isCurrentItem: ListView.isCurrentItem || checked
    draggable: true

    iconSizeHint: Maui.Style.space.small
    label1.text: control.number ? control.track + ". " + control.title :  control.title
    label2.text: control.artist + " | " + control.album
    label2.visible: control.coverArt ? !control.sameAlbum : true

    iconVisible: !control.sameAlbum && control.coverArt
    imageSource: coverArt ? "image://artwork/album:"+ control.artist+":"+control.album : ""
//    template.leftPadding: iconVisible ? 0 : Maui.Style.space.medium
}
