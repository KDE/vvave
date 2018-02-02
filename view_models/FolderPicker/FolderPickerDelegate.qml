import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

ItemDelegate
{
    id: delegate
    property string textColor: foregroundColor
    width: parent.width
    height: rowHeightAlt
    //    checkable: true

    RowLayout
    {
        id: rowLayout
        anchors.fill: parent
        spacing:0

        Item
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignLeft
            Layout.margins: 15
            anchors.verticalCenter: parent.verticalCenter


            Label
            {
                id: folderTitle
                width: parent.width
                height: parent.height
                verticalAlignment:  Qt.AlignVCenter

                text: name
                font.bold: true
                elide: Text.ElideRight

                font.pointSize: 10
                color: textColor

            }
        }


    }
}
