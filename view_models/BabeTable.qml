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
    property bool quickPlayVisible : true
    property bool coverArtVisible : false

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

            ToolButton
            {
                id: playAllBtn
                Layout.fillHeight: true
                width: parent.height
                height: parent.height

                BabeIcon {text: MdiFont.Icon.playBoxOutline}
                onClicked: playAll()
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
                id: menuBtn
                Layout.fillHeight: true
                width: parent.height
                height: parent.height

                BabeIcon {text: MdiFont.Icon.dotsVertical}
                onClicked: {}
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
        quickPlay: quickPlayVisible
        coverArt : coverArtVisible
        trackDurationVisible : list.trackDuration
        trackRatingVisible : list.trackRating

        Connections
        {
            target: delegate

            onPressAndHold: if(bae.isMobile()) openItemMenu(index)
            onRightClicked: openItemMenu(index)

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
        }
    }

    ScrollBar.vertical:BabeScrollBar {}

    function openItemMenu(index)
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
