import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

GridLayout
{
    id:placeHolder
    property string emoji
    property string message

    anchors.fill: parent

    columns: 1
    rows: 2

    visible: list.count === 0

    Rectangle
    {

        width:parent.width
        height: parent.height
        Layout.row: 1
        color: util.altColor()
        Image
        {
            id: imageHolder

            anchors.centerIn: parent
            width: 48
            height: 48
            source: emoji? emoji : "qrc:/assets/face.png"
            horizontalAlignment: Qt.AlignHCenter

            fillMode: Image.PreserveAspectFit
        }

        HueSaturation
        {
            anchors.fill: imageHolder
            source: imageHolder
            saturation: -1
            lightness: 0.3
        }
        Label
        {
            id: textHolder
            width: parent.width
            anchors.top: imageHolder.bottom
            opacity: 0.3
            text: message ? qsTr(message) : qsTr("Nothing here...")
            padding: 10
            font.bold: true
            horizontalAlignment: Qt.AlignHCenter
            elide: Text.ElideRight
            color: util.foregroundColor()
        }
    }



}
