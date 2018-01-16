import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

ItemDelegate
{
    id: delegate
    property string textColor: bae.foregroundColor()

//    checkable: true

    contentItem: GridLayout
    {
        id: gridLayout
        width: parent.width

        rows:1
        columns:1

        Label
        {
            id: folderTitle

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.row: 1
            Layout.column: 1

            text: name
            font.bold: true
            elide: Text.ElideRight

            font.pointSize: 10
            color: textColor

        }

    }
}
