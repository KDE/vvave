import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

Page
{
    property bool isConnected : false

    property alias logginDialog : logginDialog

    LogginForm
    {
        id: logginDialog
        parent: parent
    }

    Rectangle
    {
        visible: logginDialog.visible && !isMobile
        anchors.fill: parent
        z: -999
        color: darkColor
        opacity: 0.5
        height: root.height - playbackControls.height - toolbar.height
        y: toolbar.height
    }

    ColumnLayout
    {
        anchors.fill: parent

                    Item
                    {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Layout.alignment: Qt.AlignCenter
                        Layout.margins: contentMargins*2
                        width: parent.width
                        Image
                        {

                            width: 120
                            anchors.centerIn: parent
                            id: beatsImg
                            fillMode: Image.PreserveAspectFit
                            source: "qrc:/assets/banner-yellow.png"
                            horizontalAlignment: Qt.AlignHCenter
                        }

//                        ColorOverlay
//                        {
//                            anchors.fill: beatsImg
//                            source: beatsImg
//                            color: foregroundColor
//                        }
                    }
    }

}
