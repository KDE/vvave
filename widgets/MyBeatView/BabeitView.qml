import QtQuick 2.0
import QtQuick.Controls 2.2

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
        visible: logginDialog.visible
        anchors.fill: parent
        z: -999
        color: darkColor
        opacity: 0.5
        height: root.height - playbackControls.height - toolbar.height
        y: toolbar.height
    }

}
