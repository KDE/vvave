import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: control


    property alias listView : babeList.listView
    property alias model : babeList.model
    property alias delegate : babeList.delegate
    property alias count : babeList.count
    property alias currentIndex : babeList.currentIndex
    property alias currentItem : babeList.currentItem

    property alias holder : holder
    property alias section : babeList.section

    property bool wasPulled : false

    signal pulled()

    focus: true

     Maui.Holder
    {
        id: holder
        visible: babeList.count === 0
        focus: true
    }

    Maui.ListBrowser
    {
        id: babeList
        anchors.fill: parent
        clip: true

//        listView.highlight: Rectangle
//        {
//            width: babeList.width
//            height: babeList.currentItem.height
//            color: highlightColor
//        }

//        Keys.onUpPressed: decrementCurrentIndex()
//        Keys.onDownPressed: incrementCurrentIndex()
//        Keys.onReturnPressed: rowClicked(currentIndex)
//        Keys.onEnterPressed: quickPlayTrack(currentIndex)

//        boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.OvershootBounds
//        flickableDirection: Flickable.AutoFlickDirection

        //        snapMode: isMobile? ListView.SnapToItem : ListView.NoSnap

//        addDisplaced: Transition
//        {
//            NumberAnimation { properties: "x,y"; duration: 100 }
//        }

//        ScrollBar.vertical:BabeScrollBar { visible: !isMobile}

//        onContentYChanged:
//        {
//            if(contentY < -120)
//                wasPulled = true

//            if(contentY == 0 && wasPulled)
//            { pulled(); wasPulled = false}
//        }

        // Scroll is too fast on desktop, see QTBUG-56075
        // https://bugreports.qt.io/browse/QTBUG-56075
//        ScrollHelper
//        {
//            enabled: !isMobile
//            id: scrollHelper
//            flickable: babeList
//            anchors.fill: babeList
//        }
    }
}
