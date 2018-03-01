import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami
import QtQuick.Controls.Material 2.1

Page
{
    id: babeListRoot
    property alias list : babeList
    property alias model : babeList.model
    property alias delegate : babeList.delegate
    property alias count : babeList.count
    property alias currentIndex : babeList.currentIndex
    property alias currentItem : babeList.currentItem
    property alias holder : holder
    property alias section : babeList.section
    property alias headerBarRight : headerBarActionsRight.children
    property alias headerBarLeft : headerBarActionsLeft.children

    property bool headerBarVisible: true
    property string headerBarTitle
    property bool headerBarExit : true
    property string headerBarExitIcon : "window-close"

    property color headerBarColor : backgroundColor
    property color textColor : foregroundColor

    property bool wasPulled : false


    signal pulled()
    signal exit()

    focus: true

    function clearTable()
    {
        list.model.clear()
    }

    ColumnLayout
    {
        anchors.fill: parent
        spacing: 0

        ToolBar
        {
            id: headerRoot
            width: parent.width
            height:  visible ?  toolBarHeight : 0
            Layout.fillWidth: true
            visible: headerBarVisible
            focus: true            

            RowLayout
            {
                id: headerBar
                anchors.fill: parent
                BabeButton
                {
                    Layout.alignment : Qt.AlignLeft
                    Layout.leftMargin: contentMargins
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
                    Layout.leftMargin: headerBarExit ? 0 : contentMargins
                }

                Label
                {
                    text : headerBarTitle || babeList.count +" tracks"
                    Layout.fillHeight : true
                    Layout.fillWidth : true
                    Layout.alignment : Qt.AlignCenter

                    elide : Text.ElideRight
                    font.bold : false
                    color : textColor
                    font.pointSize: fontSizes.big
                    horizontalAlignment : Text.AlignHCenter
                    verticalAlignment :  Text.AlignVCenter
                }

                Row
                {
                    id: headerBarActionsRight
                    Layout.alignment : Qt.AlignRight
                    Layout.rightMargin: contentMargins
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

            BabeHolder
            {
                id: holder
                visible: babeList.count === 0
                color : textColor
                focus: true
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
