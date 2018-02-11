import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "../../view_models"


ItemDelegate
{
    id: delegate

    width: parent.width
    height: rowHeightAlt
    clip: true

    property string textColor: ListView.isCurrentItem ? highlightTextColor : foregroundColor
    signal playSync(int index)

    Rectangle
    {
        anchors.fill: parent
        color: index % 2 === 0 ? midColor : "transparent"
        opacity: 0.3
    }

    MouseArea
    {
        anchors.fill: parent
        acceptedButtons:  Qt.RightButton
        //        onClicked:
        //        {
        //            if(!root.isMobile && mouse.button === Qt.RightButton)
        //                rightClicked()
        //        }
    }

    RowLayout
    {
        anchors.fill: parent

        Item
        {
            Layout.fillHeight: true
            width: parent.height

            BabeButton
            {
                id: playBtn
                anchors.centerIn: parent
                iconName: playlistIcon ? playlistIcon : ""
                iconColor: textColor

            }
        }

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            Label
            {
                id: trackTitle
                height: parent.height
                width: parent.width
                verticalAlignment:  Qt.AlignVCenter
                text: playlist
                font.bold: false
                elide: Text.ElideRight

                font.pointSize: fontSizes.medium
                color: textColor
            }
        }

//        Item
//        {
//            visible: !playlistIcon
//            Layout.fillHeight: true
//            width: parent.height

//            BabeButton
//            {
//                id: syncBtn
//                anchors.centerIn: parent
//                iconName: "amarok_playlist_refresh" //"playlist-generator"
//                iconColor: textColor
//                onClicked: playSync(index)
//            }
//        }
    }



}
