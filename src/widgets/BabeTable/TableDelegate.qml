import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui

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
    property bool appendButton : false

    signal appendClicked()

    maskRadius: Maui.Style.radiusV

    isCurrentItem: ListView.isCurrentItem || checked
    draggable: true
    iconSource: "media-album-cover"

    template.isMask: true

    label1.text: control.number ? control.track + ". " + control.title :  control.title
    label2.text: control.artist + " | " + control.album
    label2.visible: control.coverArt ? !control.sameAlbum : true

    iconVisible: !control.sameAlbum && control.coverArt
    imageSource: coverArt ? "image://artwork/album:"+ control.artist+":"+control.album : ""

    ToolButton
    {
        visible: control.appendButton
        icon.name: "list-add"
        onClicked: control.appendClicked()
        icon.color: delegate.label1.color
        flat: true
        icon.width: 16
        icon.height: 16
        padding: 0
        opacity: delegate.hovered ? 0.8 : 0.6
    }
}
