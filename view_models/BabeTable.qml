import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ListView
{
    SystemPalette { id: myPalette; colorGroup: SystemPalette.Active }

    property int currentRow : -1
    signal rowClicked(int index)
    signal rowPressed(int index)

    width: 320
    height: 480

    highlight: highlight
    highlightFollowsCurrentItem: false

    focus: true
    boundsBehavior: Flickable.StopAtBounds

    id: list
    flickableDirection: Flickable.AutoFlickDirection

    snapMode: ListView.SnapToItem

    function clearTable()
    {
        listModel.clear()
    }


    Component
    {
        id: highlight
        Rectangle
        {
            width: list.width
            height: list.currentItem.height

            color: myPalette.highlight
            opacity: 0.2
            y: list.currentItem.y
            Behavior on y
            {
                SpringAnimation
                {
                    spring: 3
                    damping: 0.2
                }
            }
        }
    }

    Menu
    {
        id: contextMenu
        x: parent.width / 2 - width / 2
        y: parent.height / 2 - height / 2
        modal: true

        Label
        {
            padding: 10
            font.bold: true
            width: parent.width
            horizontalAlignment: Qt.AlignHCenter
            elide: Text.ElideRight
            text: currentRow >= 0 ? list.model.get(currentRow).title : ""
        }
        MenuItem
        {
            text: qsTr("Edit...")
            onTriggered: ;
        }
        MenuItem
        {
            text: qsTr("Remove")
            onTriggered: ;
        }
        MenuItem
        {
            text: qsTr("Edit...")
            onTriggered: ;
        }
        MenuItem
        {
            text: qsTr("Remove")
            onTriggered: ;
        }
        MenuItem
        {
            text: qsTr("Edit...")
            onTriggered: ;
        }
        MenuItem
        {
            text: qsTr("Remove")
            onTriggered: ;
        }
    }

    ListModel { id: listModel }

    model: listModel

    delegate: TableDelegate
    {
        id: delegate
        width: list.width

        Connections
        {
            target: delegate
            onPressAndHold:
            {
                currentRow = index
                contextMenu.open()
                list.rowPressed(index)
            }
            onClicked:
            {
                list.rowClicked(index)
                currentIndex = index
            }
        }
    }

    ScrollBar.vertical: ScrollBar { }


}
