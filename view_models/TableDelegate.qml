import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

ItemDelegate
{
    id: delegate
    signal rowSelected(int index)

    property bool numberVisible : false
    checkable: true

    contentItem: GridLayout
    {
        id: gridLayout
        rows:2
        columns:3

        Label
        {
            id: trackNumber
            visible: numberVisible
            width: 16
            Layout.fillHeight: true
            Layout.row: 1
            Layout.column: 1
            Layout.rowSpan: 2
            Layout.alignment: Qt.AlignLeft

            text: track
            font.bold: true
            elide: Text.ElideRight

            font.pointSize: 10

        }


        Label
        {
            id: trackTitle

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.row: 1
            Layout.column: 2

            text: title
            font.bold: true
            elide: Text.ElideRight

            font.pointSize: 10

        }

        Label
        {
            id: trackInfo

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.row: 2
            Layout.column: 2

            text: artist + " | " + album
            font.bold: false
            elide: Text.ElideRight
            font.pointSize: 9

        }
    }
}
