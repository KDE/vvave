import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

Item
{
    property int recSize : iconSizes.small
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
                border.color: altColor
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
                border.color: altColor
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
                border.color: altColor
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
                border.color: altColor
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
                border.color: altColor
                border.width: 1
            }

            onClicked: colorClicked(vvave.moodColor(4))
        }
    }
}
