import QtQuick 2.10
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.3

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
property bool appendButton : false

    signal appendClicked()

    maskRadius: Maui.Style.radiusV

    isCurrentItem: ListView.isCurrentItem || checked
    draggable: true

//    iconSizeHint: Maui.Style.iconSizes.medium
//    template.imageSizeHint:  48
    iconSource: "media-album-cover"

    template.isMask: true

    label1.text: control.number ? control.track + ". " + control.title :  control.title
    label2.text: control.artist + " | " + control.album
    label2.visible: control.coverArt ? !control.sameAlbum : true

    iconVisible: !control.sameAlbum && control.coverArt
    imageSource: coverArt ? "image://artwork/album:"+ control.artist+":"+control.album : ""
    //    template.leftPadding: iconVisible ? 0 : Maui.Style.space.medium

    AbstractButton
    {
        Layout.fillHeight: true
        Layout.preferredWidth: Maui.Style.rowHeight
        visible: control.appendButton
        icon.name: "list-add"
        onClicked: control.appendClicked()


        Maui.Icon
        {
            anchors.centerIn: parent
            height: Maui.Style.iconSizes.small
            width: height
            source: parent.icon.name
            color: delegate.label1.color
        }

        opacity: delegate.hovered ? 0.8 : 0.6
    }
}
