import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1
import org.kde.kirigami 2.2 as Kirigami

import "../../view_models"

BabePopup
{

    closePolicy: Popup.NoAutoClose
    modal: false

    Connections
    {
        target: bae
        onMessage: consoletext.append(">> "+msg+"\n");
    }


    ColumnLayout
    {
        anchors.fill: parent
        spacing: 0

        BabeButton
        {
            Layout.alignment: Qt.AlignLeft
            Layout.margins: contentMargins

            anim : true
            iconName : "dialog-close"
            onClicked : close()
        }

        TextArea
        {
            id: consoletext
            Layout.fillHeight: true
            Layout.fillWidth: true
            readOnly: true
            font.pointSize: fontSizes.small
            background: Rectangle
            {
                color: darkDarkColor
                implicitWidth: 200
                implicitHeight: 40
            }

            color: darkForegroundColor

        }
    }


}
