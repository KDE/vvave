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

    default property alias content : _template.content

    property alias checked : _template.checked
    property alias checkable: _template.checkable

    property bool showQuickActions: true
    property bool number : false
    property bool coverArt : false
    property color trackMood : model.color

    readonly property color color : model.color
    readonly property string artist : model.artist
    readonly property string album : model.album
    readonly property string title : model.title
    readonly property url url : model.url
    readonly property int rate : model.rate
    readonly property int track : model.track
    readonly property string artwork : model.artwork

    readonly property color bgColor : Kirigami.Theme.backgroundColor
    readonly property int altHeight : Maui.Style.rowHeight * 1.4
    property bool sameAlbum : false

    signal play()
    signal append()
    signal leftClicked()
    signal toggled(int index, bool state)

    signal artworkCoverClicked()
    signal artworkCoverDoubleClicked()

    Kirigami.Theme.backgroundColor: control.color.length > 0 ? Qt.rgba(trackMood.r, trackMood.g, trackMood.b, 0.2):  bgColor

    isCurrentItem: ListView.isCurrentItem || checked
    implicitHeight: sameAlbum ? Maui.Style.rowHeight : altHeight
    padding: 0

    rightPadding: leftPadding
    leftPadding: Maui.Style.space.small
    draggable: true

    Maui.ListItemTemplate
    {
        id: _template
        anchors.fill: parent
        isCurrentItem: control.isCurrentItem
        iconSizeHint: height - Maui.Style.space.small
        label1.text: control.number ? control.track + ". " + control.title :  control.title
        label2.text: control.artist + " | " + control.album
        label2.visible: control.coverArt ? !control.sameAlbum : true

        label4.font.family: "Material Design Icons"
        label4.text: control.rate ? H.setStars(control.rate) : ""

        iconVisible: !control.sameAlbum && control.coverArt
        imageSource: control.artwork ? control.artwork : "qrc:/assets/cover.png"

        onToggled: control.toggled(index, state)
    }
}
