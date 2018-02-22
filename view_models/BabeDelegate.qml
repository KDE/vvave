import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

ItemDelegate
{
    id: listItem


    width: parent.width
    height: rowHeightAlt

    property bool isSection : false
    property bool boldLabel : false
    property alias label: labelTxt.text
    property alias fontFamily: labelTxt.font.family
    property string textColor: ListView.isCurrentItem ? highlightTextColor : foregroundColor

    Rectangle
    {
        anchors.fill: parent
        color:  isSection ? midLightColor : (index % 2 === 0 ? midColor : "transparent")
        opacity: 0.3
    }

    ColumnLayout
    {
        anchors.fill: parent

        Label
        {
            id: labelTxt
            Layout.margins: contentMargins
            anchors.verticalCenter: parent.verticalCenter

            width: parent.width
            height: parent.height

            horizontalAlignment: Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter

            text: labelTxt.text
            elide: Text.ElideRight
            color: textColor
            font.bold: boldLabel
            font.weight : boldLabel ? Font.Bold : Font.Normal
        }
    }
}
