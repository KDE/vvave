import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ListView
{
    SystemPalette { id: myPalette; colorGroup: SystemPalette.Active }
    id: list

    property int currentRow : -1
    property bool trackNumberVisible
    property bool quickBtnsVisible : true
    property bool quickPlayVisible : true
    property alias holder : holder
    signal rowClicked(int index)
    signal rowPressed(int index)
    signal quickPlayTrack(int index)
    signal queueTrack(int index)

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

   TableMenu
   {
       id: contextMenu
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
                if(!bae.isMobile())
                    list.quickPlayTrack(currentIndex)
            }

            onClicked:
            {
                list.rowClicked(index)
                currentIndex = index
            }

            onPlay: list.quickPlayTrack(index)
            onMenuClicked:
            {
                currentRow = index
                contextMenu.rate = bae.trackRate(list.model.get(currentRow).url)
                contextMenu.open()
                list.rowPressed(index)
            }

        }
    }

    ScrollBar.vertical: ScrollBar { }


}
