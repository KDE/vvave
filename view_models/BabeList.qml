import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami

Item
{
    property alias list : babeList
    property alias model : babeList.model
    property alias delegate : babeList.delegate
    property alias count : babeList.count
    property alias currentIndex : babeList.currentIndex

    property alias holder : holder

    property alias headerBarRight : headerBarActionsRight.children
    property alias headerBarLeft : headerBarActionsLeft.children

    property bool headerBarVisible: true
    property string headerBarTitle
    property bool headerBarExit : true
    property string headerBarExitIcon : "window-close"
    property color headerBarColor : "transparent"

    property bool wasPulled : false

    signal pulled()
    signal exit()


    ColumnLayout
    {
        anchors.fill: parent
        spacing: 0
        Item
        {
            id: headerRoot
            width: parent.width
            height:  visible ?  toolBarHeight : 0
            Layout.fillWidth: true
            visible: headerBarVisible

            Rectangle
            {
                anchors.fill: parent
                color: headerBarColor

                Kirigami.Separator
                {
                    Rectangle
                    {
                        anchors.fill: parent
                        color: Kirigami.Theme.viewFocusColor
                    }

                    anchors
                    {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                }

            }

            RowLayout
            {
                id: headerBar
                anchors.fill: parent
                BabeButton
                {
                    Layout.alignment : Qt.AlignLeft
                    Layout.leftMargin: contentMargins-6
                    width: rowHeight
                    visible: headerBarExit
                    anim : true
                    iconName : headerBarExitIcon //"dialog-close"
                    onClicked : exit()
                }

                Row
                {
                    id: headerBarActionsLeft
                    Layout.alignment : Qt.AlignLeft
                    Layout.leftMargin: headerBarExit ? 0 : contentMargins-6

                }

                Label
                {
                    text : headerBarTitle || babeList.count +" tracks"
                    Layout.fillHeight : true
                    Layout.fillWidth : true
                    Layout.alignment : Qt.AlignCenter

                    elide : Text.ElideRight
                    font.bold : false
                    color : foregroundColor

                    horizontalAlignment : Text.AlignHCenter
                    verticalAlignment :  Text.AlignVCenter
                }

                Row
                {
                    id: headerBarActionsRight
                    Layout.alignment : Qt.AlignRight
                    Layout.rightMargin: contentMargins-6
                }

            }
        }

        ListView
        {
            id: babeList
            Layout.fillHeight: true
            Layout.fillWidth: true

            clip: true

            highlight: Rectangle
            {
                width: babeList.width
                height: babeList.currentItem.height
                color: babeHighlightColor
                //        y: babeList.currentItem.y
                //        Behavior on y
                //        {
                //            SpringAnimation
                //            {
                //                spring: 3
                //                damping: 0.2
                //            }
                //        }
            }

            focus: true
            interactive: true
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 0
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
                NumberAnimation { properties: "x,y"; duration: 100 }
            }

            function clearTable()
            {
                listModel.clear()
            }

            BabeHolder
            {
                id: holder
                visible: babeList.count === 0
            }

            Rectangle
            {
                anchors.fill: parent
                color: "transparent"
                z: -999
            }


            ScrollBar.vertical:BabeScrollBar { }


            onContentYChanged:
            {
                if(contentY < -120)
                    wasPulled = true

                if(contentY == toolBarHeight*-1 && wasPulled)
                { pulled(); wasPulled = false}
            }
        }
    }
}
