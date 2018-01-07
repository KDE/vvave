import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

ListView
{
    SystemPalette { id: myPalette; colorGroup: SystemPalette.Active }

    property int currentRow : -1
    property bool trackNumberVisible

    signal rowClicked(int index)
    signal rowPressed(int index)

    width: 320
    height: 480

    clip: true

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


    GridLayout
    {
        id:placeHolder

        anchors.fill: parent

        columns: 1
        rows: 2

        visible: list.count === 0

        Rectangle
        {

            width:parent.width
            height: parent.height
            Layout.row: 1

            Image
            {
                id: imageHolder

                anchors.centerIn: parent
                width: 48
                height: 48
                source: "qrc:/assets/face.png"
                horizontalAlignment: Qt.AlignHCenter

                fillMode: Image.PreserveAspectFit
            }

            HueSaturation
            {
                anchors.fill: imageHolder
                source: imageHolder
                saturation: -1
                lightness: 0.3
            }
            Label
            {
                id: textHolder
                width: parent.width
                anchors.top: imageHolder.bottom
                opacity: 0.3
                text: qsTr("Nothing here...")
                padding: 10
                font.bold: true
                horizontalAlignment: Qt.AlignHCenter
                elide: Text.ElideRight
            }
        }



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
        numberVisible : trackNumberVisible ? true : false
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
