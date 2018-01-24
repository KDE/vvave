import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "../utils"


ItemDelegate
{
    id: delegate

    width: parent.width
    height: 48
    clip: true

    property string textColor: ListView.isCurrentItem ? bae.hightlightTextColor() : bae.foregroundColor()


    Rectangle
    {
        anchors.fill: parent
        color: index % 2 === 0 ? bae.midColor() : "transparent"
        opacity: 0.3
    }



    MouseArea
    {
        anchors.fill: parent
        acceptedButtons:  Qt.RightButton
        onClicked:
        {
            if(!root.isMobile && mouse.button === Qt.RightButton)
                rightClicked()
        }
    }

    RowLayout
    {
        id: gridLayout
        anchors.fill: parent
        spacing: 20

        Item
        {
            Layout.fillHeight: true
            width: parent.height

            ToolButton
            {
                id: playBtn
                anchors.centerIn: parent
                BabeIcon { icon: playlistIcon; color: textColor }
            }
        }


        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.margins: 15
            anchors.verticalCenter: parent.verticalCenter

            Label
            {
                id: trackTitle

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.row: 1
                Layout.column: 2
                verticalAlignment:  Qt.AlignVCenter
                text: playlist
                font.bold: true
                elide: Text.ElideRight

                font.pointSize: 10
                color: textColor
            }

        }
    }



}
