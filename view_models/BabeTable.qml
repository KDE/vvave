import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../utils/Icons.js" as MdiFont
import "../utils"

ListView
{
    SystemPalette { id: myPalette; colorGroup: SystemPalette.Active }
    id: list

    property int currentRow : -1

    property bool headerBar: false
    property bool trackNumberVisible
    property bool quickBtnsVisible : true
    property bool quickPlayVisible : true

    property bool trackDuration
    property bool trackRating

    property string headerTitle
    property bool headerClose : false
    //    default property alias customItem : customItem.children

    property alias holder : holder

    signal rowClicked(int index)
    signal rowPressed(int index)
    signal quickPlayTrack(int index)
    signal queueTrack(int index)
    signal headerClosed()

    signal playAll()
    signal appendAll()

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

    headerPositioning: ListView.OverlayHeader
    header: Rectangle
    {
        id: tableHeader
        width: parent.width
        height:  headerBar ? 48 : 0
        color: bae.midLightColor()
        visible: headerBar
        z: 999
        RowLayout
        {
            anchors.fill: parent

            ToolButton
            {
                id: closeBtn
                visible: headerClose
                width: parent.height
                height: parent.height

                BabeIcon { text: MdiFont.Icon.close }
                onClicked: headerClosed()
            }

            Label
            {
                text: headerTitle || ""
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignCenter
                elide: Text.ElideRight
                font.pointSize: 12
                font.bold: true
                lineHeight: 0.7
                color: bae.foregroundColor()

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:  Text.AlignVCenter
            }

            ToolButton
            {
                id: appendBtn
                Layout.fillHeight: true
                width: parent.height
                height: parent.height

                BabeIcon {text: MdiFont.Icon.playlistPlus}

                onClicked: appendAll()
            }

            ToolButton
            {
                id: playAllBtn
                Layout.fillHeight: true
                width: parent.height
                height: parent.height

                BabeIcon {text: MdiFont.Icon.playBoxOutline}

                onClicked: playAll()
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

        trackDurationVisible : list.trackDuration
        trackRatingVisible : list.trackRating

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
                currentIndex = index
                if(bae.isMobile())
                    list.rowClicked(index)
            }

            onDoubleClicked:
            {
                if(!bae.isMobile())
                    list.rowClicked(index)
            }

            onPlay: list.quickPlayTrack(index)
            onMenuClicked:
            {
                currentRow = index
                currentIndex = index
                contextMenu.rate = bae.trackRate(list.model.get(currentRow).url)
                if(bae.isMobile()) contextMenu.open()
                else
                    contextMenu.popup()
                list.rowPressed(index)
            }

        }
    }

    ScrollBar.vertical: ScrollBar
    {
        id: scrollBar
        size: 0.3
        position: 0.2
        active: true

        background : Rectangle
        {
            radius: 12
            color: bae.backgroundColor()
        }

        contentItem: Rectangle
        {
            implicitWidth: 6
            implicitHeight: 100
            radius: width / 2
            color: scrollBar.pressed ? bae.hightlightColor() : bae.darkColor()
        }
    }


}
