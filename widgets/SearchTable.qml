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
            if(searchInput !== searchView.headerTitle)
            {
                var query = searchInput.text
                searchTable.headerTitle = query
                var queries = query.split(",")
                searchRes = bae.searchFor(queries)
                populate(searchView.searchRes)
            }
        }
    }

    function clearSearch()
    {
        searchInput.clear()
        searchTable.clearTable()
        searchTable.headerTitle = ""
        searchRes = []
    }

    function populate(tracks)
    {
        searchTable.clearTable()
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
            headerBar: true
            //    headerClose: true
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
                    Layout.fillHeight: true
                    visible: searchInput.activeFocus
                    iconName: "edit-clear"
                    onClicked: clearSearch()
                }
            }

        }
    }
}
