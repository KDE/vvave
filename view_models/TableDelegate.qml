import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

ItemDelegate
{
    id: delegate
    signal rowSelected(int index)

    checkable: true

    contentItem: ColumnLayout
    {
        spacing: 2

        Label
        {
            id: trackTitle
            text: title
            font.bold: true
            elide: Text.ElideRight
            Layout.fillWidth: true
            font.pointSize: 10

        }

        Label
        {
            id: trackInfo
            text: artist + " | " + album
            font.bold: false
            elide: Text.ElideRight
            Layout.fillWidth: true
            font.pointSize: 9

        }
    }



    //        GridLayout
    //        {
    //            id: grid
    //            visible: false

    //            columns: 2
    //            rowSpacing: 10
    //            columnSpacing: 10

    //            Label
    //            {
    //                text: qsTr("Address:")
    //                Layout.leftMargin: 60
    //            }

    //            Label
    //            {
    //                text: address
    //                font.bold: true
    //                elide: Text.ElideRight
    //                Layout.fillWidth: true
    //            }

    //            Label
    //            {
    //                text: qsTr("City:")
    //                Layout.leftMargin: 60
    //            }

    //            Label
    //            {
    //                text: city
    //                font.bold: true
    //                elide: Text.ElideRight
    //                Layout.fillWidth: true
    //            }

    //            Label
    //            {
    //                text: qsTr("Number:")
    //                Layout.leftMargin: 60
    //            }

    //            Label
    //            {
    //                text: number
    //                font.bold: true
    //                elide: Text.ElideRight
    //                Layout.fillWidth: true
    //            }
    //        }
    //    }

    //    states: [
    //        State
    //        {
    //            name: "expanded"
    //            when: delegate.checked

    //            PropertyChanges
    //            {
    //                target: grid
    //                visible: true
    //            }
    //        }
    //    ]
}
