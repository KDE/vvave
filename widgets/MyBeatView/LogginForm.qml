import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Item
{

    Rectangle
    {
        anchors.fill: parent
        z: -999
        color: midLightColor

        //        Image
        //        {
        //            id: musicBg
        //            source: "qrc:/assets/music_img.jpg"
        //            smooth: true
        //            visible: false
        //            anchors.fill: parent
        //        }

        //        FastBlur
        //        {
        //            anchors.fill: musicBg
        //            source: musicBg
        //            radius: 64
        //        }
    }

    ColumnLayout
    {
        anchors.fill: parent

        //        Item
        //        {
        //            id: banner
        //            Layout.fillWidth: true
        //            anchors.top: parent.top
        //            height: 64
        //            width: parent.width

        ////            Rectangle
        ////            {
        ////                anchors.fill: parent
        ////                z: -999
        ////                color: "#dedede"
        ////                opacity: 0.5
        ////            }




        //        }


        Item
        {

            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout
            {
                width: parent.width *0.4
                height: parent.height *0.4
                anchors.centerIn: parent

                Item
                {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    Layout.margins: contentMargins
                    width: parent.width
                    Image
                    {
                        anchors.centerIn: parent
                        id: beatsImg
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                        source: "qrc:/assets/beat.svg"
                        horizontalAlignment: Qt.AlignHCenter
                    }

                    ColorOverlay
                    {
                        anchors.fill: beatsImg
                        source: beatsImg
                        color: foregroundColor
                    }
                }

                Item
                {
                    width: parent.width
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    height: 48
                    TextField
                    {
                        id: nickId

                        anchors.fill: parent
                        anchors.centerIn: parent
                        placeholderText: "nick or email"
                        color: foregroundColor
                        horizontalAlignment: Text.AlignHCenter


                    }
                }
                Item
                {
                    width: parent.width

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter

                    height: 48

                    TextField
                    {
                        id: password
                        anchors.fill: parent
                        anchors.centerIn: parent
                        placeholderText: "password"
                        color: foregroundColor
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Button
                {
                    width: parent.width

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter

                    id: loginBtn

                    background: Rectangle
                    {
                        color: babeColor
                        radius: 3
                    }

                    contentItem: Text
                    {
                        text: "Login"
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        color: highlightTextColor
                        font.bold: true
                        font.pointSize: 11
                    }

                }


            }

        }
    }
}
