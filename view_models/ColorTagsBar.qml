import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.10
import org.kde.mauikit 1.0 as Maui

Item
{
    property int recSize: Maui.Style.iconSizes.small
    readonly property int recRadius : recSize*0.05
    signal colorClicked(string color)

    RowLayout
    {
        width: parent.width
        anchors.fill: parent
        anchors.centerIn: parent
        ToolButton
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            flat: true
            Rectangle
            {
                anchors.centerIn: parent
                width: recSize
                height: recSize
                color: vvave.moodColor(0)
                radius: recRadius
                border.color: color
                border.width: 1
            }

            onClicked: colorClicked(vvave.moodColor(0))
        }
        ToolButton
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter

            flat: true
            Rectangle
            {
                anchors.centerIn: parent
                width: recSize
                height: recSize
                color: vvave.moodColor(1)
                radius: recRadius
                border.color: color
                border.width: 1
            }

            onClicked: colorClicked(vvave.moodColor(1))
        }
        ToolButton
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            flat: true
            Rectangle
            {
                anchors.centerIn: parent
                width: recSize
                height: recSize
                color: vvave.moodColor(2)
                radius: recRadius
                border.color: color
                border.width: 1
            }

            onClicked: colorClicked(vvave.moodColor(2))
        }
        ToolButton
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            flat: true
            Rectangle
            {
                anchors.centerIn: parent
                width: recSize
                height: recSize
                color: vvave.moodColor(3)
                radius: recRadius
                border.color: color
                border.width: 1
            }

            onClicked: colorClicked(vvave.moodColor(3))
        }

        ToolButton
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            flat: true
            Rectangle
            {
                anchors.centerIn: parent
                width: recSize
                height: recSize
                color: vvave.moodColor(4)
                radius: recRadius
                border.color: color
                border.width: 1
            }

            onClicked: colorClicked(vvave.moodColor(4))
        }
    }
}
