import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ".."

ListView
{
    SystemPalette { id: myPalette; colorGroup: SystemPalette.Active }
    id: list

    property int currentRow : -1
    property string currentUrl
    property string currentName

    signal rowClicked(int index)
    signal rowPressed(int index)

    width: 320
    height: 480

    clip: true

    highlight: highlight
    highlightFollowsCurrentItem: false

    focus: true
    boundsBehavior: Flickable.StopAtBounds

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
        color: "transparent"
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
        }
    }

    ListModel { id: listModel }

    model: listModel

    delegate: FolderPickerDelegate
    {
        id: delegate
        width: list.width

        Connections
        {
            target: delegate
            onPressAndHold:
            {

            }

            onClicked:
            {
                list.rowClicked(index)
                currentIndex = index
//                currentUrl = model.get(currentIndex).url
            }

        }
    }

    ScrollBar.vertical: ScrollBar { }
}
