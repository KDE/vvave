import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: control

    property alias listBrowser : babeList
    property alias listView : babeList.listView
    property alias model : babeList.model
    property alias delegate : babeList.delegate
    property alias count : babeList.count
    property alias currentIndex : babeList.currentIndex
    property alias currentItem : babeList.currentItem

    property alias holder : babeList.holder
    property alias section : babeList.section

    property bool wasPulled : false

    signal pulled()

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false
    flickable: babeList.flickable

    Maui.ListBrowser
    {
        id: babeList
        clip: true
        anchors.fill: parent
        holder.visible: count === 0
        topMargin: Maui.Style.space.medium
   }
}
