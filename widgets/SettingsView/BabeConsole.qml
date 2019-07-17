import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.1
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import "../../view_models"

Maui.Popup
{

    id: babeConsoleRoot
    closePolicy: Popup.NoAutoClose
    modal: false

    Connections
    {
        target: bae
        onMessage: consoletext.append(">> "+msg+"\n");
    }

    background: Rectangle
    {
        color: darkDarkColor
        border.color: "#111"
    }


    ColumnLayout
    {
        id: consoleLayout
        anchors.fill: parent
        spacing: 0

        ToolButton
        {
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin:  contentMargins
            icon.color: darkTextColor
            anim : true
            icon.name : "dialog-close"
            onClicked : close()
        }

        ScrollView
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: contentMargins

            clip: true
            contentWidth: babeConsoleRoot.width
            contentHeight: consoletext.height

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            TextArea
            {
                id: consoletext
                width: babeConsoleRoot.width
                Layout.fillHeight: true
                Layout.fillWidth: true
                readOnly: true
                font.pointSize: fontSizes.small
                wrapMode: TextEdit.WordWrap
                background: Rectangle
                {
                    color: darkDarkColor
                    implicitWidth: 200
                    implicitHeight: 40
                }

                color: darkTextColor
            }
        }
    }
}
