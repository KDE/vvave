import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ListView
{
    SystemPalette { id: myPalette; colorGroup: SystemPalette.Active }

    property int currentRow : -1
    property bool trackNumberVisible
    property bool quickBtnsVisible : true
    property bool quickPlayVisible : true
    property alias holder : holder
    signal rowClicked(int index)
    signal rowPressed(int index)
    signal playTrack(int index)
    signal queueTrack(int index)

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

    BabeHolder
    {
        id: holder
        visible: list.count === 0
    }

    Rectangle
    {
        anchors.fill: parent
        color: bae.altColor()
        z: -999
    }

    Component
    {
        id: highlight
        Rectangle
        {
            width: list.width
            height: list.currentItem.height

            color: bae.hightlightColor() || myPalette.highlight
            opacity: 0.2
            y: list.currentItem.y
            //            Behavior on y
            //            {
            //                SpringAnimation
            //                {
            //                    spring: 3
            //                    damping: 0.2
            //                }
            //            }
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
            text: qsTr("Babe it")
            onTriggered: ;
        }
        MenuItem
        {
            text: qsTr("Queue")
            onTriggered:
            {
                console.log(currentRow)
                list.queueTrack(currentRow)
            }
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
        number : trackNumberVisible ? true : false
        quickBtns : quickBtnsVisible
        quickPlay: quickPlayVisible
        Connections
        {
            target: delegate
            onPressAndHold:
            {
                if(Qt.platform.os === "linux")
                    playTrack(currentIndex)
            }

            onClicked:
            {
                list.rowClicked(index)
                currentIndex = index
            }

            onPlayTrack: list.playTrack(index)
            onMenuClicked:
            {
                currentRow = index
                contextMenu.open()
                list.rowPressed(index)
            }

        }
    }

    ScrollBar.vertical: ScrollBar { }


}
