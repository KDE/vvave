import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.10
import org.kde.mauikit 1.0 as Maui
import org.maui.vvave 1.0 as Vvave

Item
{
    property int recSize: Maui.Style.iconSizes.medium
    readonly property int recRadius : recSize*0.05
    signal colorClicked(string color)

    RowLayout
    {
        anchors.fill: parent
        spacing: Maui.Style.space.small

        Repeater
        {
            model: Vvave.Vvave.moodColors()

            MouseArea
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                onClicked: colorClicked(modelData)
                propagateComposedEvents: false
                Rectangle
                {
                    color: modelData
                    anchors.verticalCenter: parent.verticalCenter
                    height: recSize
                    width: height
                    radius: Maui.Style.radiusV
                    border.color: Qt.darker(color, 1.7)
                    anchors.centerIn: parent
                }
            }


        }

    }
}
