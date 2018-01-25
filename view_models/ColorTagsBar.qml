import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

Item
{
    property int recSize : 16
    signal colorClicked(string color)


    RowLayout
    {
        anchors.fill: parent
        anchors.centerIn: parent
        ToolButton
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter

            Rectangle
            {
                anchors.centerIn: parent
                width: recSize
                height: recSize
                color: bae.moodColor(0)
                radius: 2
                border.color: bae.altColor()
                border.width: 1
            }

            onClicked: colorClicked(bae.moodColor(0))
        }
        ToolButton
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter

            Rectangle
            {
                anchors.centerIn: parent
                width: recSize
                height: recSize
                color: bae.moodColor(1)
                radius: 2
                border.color: bae.altColor()
                border.width: 1
            }

            onClicked: colorClicked(bae.moodColor(1))
        }
        ToolButton
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter

            Rectangle
            {
                anchors.centerIn: parent
                width: recSize
                height: recSize
                color: bae.moodColor(2)
                radius: 2
                border.color: bae.altColor()
                border.width: 1
            }

            onClicked: colorClicked(bae.moodColor(2))
        }
        ToolButton
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter

            Rectangle
            {
                anchors.centerIn: parent
                width: recSize
                height: recSize
                color: bae.moodColor(3)
                radius: 2
                border.color: bae.altColor()
                border.width: 1
            }

            onClicked: colorClicked(bae.moodColor(3))
        }

        ToolButton
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter

            Rectangle
            {
                anchors.centerIn: parent
                width: recSize
                height: recSize
                color: bae.moodColor(4)
                radius: 2
                border.color: bae.altColor()
                border.width: 1
            }

            onClicked: colorClicked(bae.moodColor(4))
        }
    }
}
