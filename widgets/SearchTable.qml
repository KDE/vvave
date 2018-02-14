import QtQuick 2.9

import org.kde.kirigami 2.2 as Kirigami
import QtQuick.Layouts 1.3
import "../view_models"

import "../view_models/BabeTable"
import "../db/Queries.js" as Q

Item
{
    property alias searchInput : searchInput
    property alias searchTable : searchTable
    property var searchRes : []

    function runSearch()
    {
        if(searchInput.text)
        {
            if(searchInput !== searchTable.headerBarTitle)
            {
                var query = searchInput.text
                searchTable.headerBarTitle = query
                var queries = query.split(",")
                searchRes = bae.searchFor(queries)
                populate(searchView.searchRes)
            }
        }
    }

    function clearSearch()
    {
        searchInput.clear()
        searchTable.list.clearTable()
        searchTable.headerBarTitle = ""
        searchRes = []
    }

    function populate(tracks)
    {
        searchTable.list.clearTable()
        for(var i in tracks)
            searchTable.model.append(tracks[i])
    }
    Rectangle
    {
        anchors.fill: parent
        color: altColor
        z: -999
    }
    ColumnLayout
    {
        anchors.fill: parent
        BabeTable
        {
            id: searchTable
            Layout.fillHeight: true
            Layout.fillWidth: true
            trackNumberVisible: false
            headerBarVisible: true
            headerBarExit: false
            holder.message: "No search results!"
            coverArtVisible: true
            trackDuration: true
            trackRating: true

        }

        Rectangle
        {
            id: searchBox
            Layout.fillWidth: true
            width: parent.width
            height: toolBarHeight
            color: searchInput.activeFocus ? midColor : midLightColor
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
                    top: parent.top
                }
            }

            RowLayout
            {
                anchors.fill: parent

                BabeButton
                {
                    Layout.leftMargin: contentMargins
                    visible: true
                    iconName: "view-filter"
                    onClicked: {}
                }

                TextInput
                {
                    id: searchInput
                    color: foregroundColor
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    selectByMouse: !root.isMobile
                    selectionColor: babeHighlightColor
                    selectedTextColor: foregroundColor

                    onAccepted: runSearch()
                }

                BabeButton
                {
                    Layout.rightMargin: contentMargins
                    visible: searchInput.text.length > 0
                    iconName: "edit-clear"
                    onClicked: clearSearch()
                }
            }

        }
    }
}
