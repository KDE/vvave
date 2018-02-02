import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models/FolderPicker"
import "../../utils"
import ".."

ListView
{
    id: list

    //    cacheBuffer : 300

    property bool headerBar: false
    property bool trackNumberVisible
    property bool quickPlayVisible : true
    property bool coverArtVisible : false
    property bool menuItemVisible : isMobile
    property int prevIndex
    property bool trackDuration
    property bool trackRating

    property string headerTitle
    property bool headerClose : false

    property alias holder : holder

    signal rowClicked(int index)
    signal rowPressed(int index)
    signal quickPlayTrack(int index)
    signal queueTrack(int index)
    signal headerClosed()
    signal artworkDoubleClicked(int index)

    signal playAll()
    signal appendAll()

    clip: true

    highlight: Rectangle
    {
        width: list.width
        height: list.currentItem.height
        color: babeHighlightColor
        y: list.currentItem.y
    }

    focus: true
    interactive: true
    highlightFollowsCurrentItem: false
    keyNavigationWraps: !isMobile
    keyNavigationEnabled : !isMobile

    Keys.onUpPressed: decrementCurrentIndex()
    Keys.onDownPressed: incrementCurrentIndex()
    Keys.onReturnPressed: rowClicked(currentIndex)
    Keys.onEnterPressed: quickPlayTrack(currentIndex)

    boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.DragAndOvershootBounds
    flickableDirection: Flickable.AutoFlickDirection

    snapMode: ListView.SnapToItem

    addDisplaced: Transition
    {
        NumberAnimation { properties: "x,y"; duration: 1000 }
    }

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
        height:  headerBar ?  48 : 0
        color: midLightColor
        visible: headerBar
        z: 999

        RowLayout
        {
            anchors.fill: parent
            anchors.centerIn: parent

            BabeButton
            {
                id: closeBtn
                visible: headerClose

                iconName: "window-close" //"dialog-close"
                onClicked: headerClosed()
            }

            BabeButton
            {
                id: playAllBtn
                Layout.fillHeight: true
                visible: headerBar && count > 0

                iconName: /*"amarok_clock"*/ "media-playback-start"
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
                font.bold: isMobile
                color: foregroundColor

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:  Text.AlignVCenter
            }

            BabeButton
            {
                id: appendBtn
                Layout.fillHeight: true
                visible: headerBar && count > 0

                iconName : "archive-insert"//"media-repeat-track-amarok"
                onClicked: appendAll()
            }

            BabeButton
            {
                id: menuBtn
                Layout.fillHeight: true
                iconName: /*"application-menu"*/ "overflow-menu"
                onClicked: {}
            }
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
        menuItem: menuItemVisible

        Connections
        {
            target: delegate

            //            onPressAndHold: if(root.isMobile) openItemMenu(index)
            onRightClicked: openItemMenu(index)

            onClicked:
            {
                currentIndex = index
                if(root.isMobile)
                    list.rowClicked(index)

            }

            onDoubleClicked:
            {
                if(!root.isMobile)
                    list.rowClicked(index)

            }

            onPlay: list.quickPlayTrack(index)

            onArtworkCoverDoubleClicked: list.artworkDoubleClicked(index)
        }
    }

    ScrollBar.vertical:BabeScrollBar { }



    function openItemMenu(index)
    {
        currentIndex = index
        contextMenu.rate = bae.getTrackStars(list.model.get(list.currentIndex).url)
        if(root.isMobile) contextMenu.open()
        else
            contextMenu.popup()
        list.rowPressed(index)
    }

    //    Component.onCompleted: forceActiveFocus()
}
