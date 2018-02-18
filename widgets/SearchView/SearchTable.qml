import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import QtQuick.Layouts 1.3
import "../../view_models"
import QtGraphicalEffects 1.0

import "../../view_models/BabeTable"
import "../../db/Queries.js" as Q

Item
{
    property alias searchInput : searchInput
    property alias searchTable : searchTable
    property var searchRes : []
    property var savedQueries : []

    function runSearch()
    {
        if(searchInput.text)
            if(searchInput.text !== searchTable.headerBarTitle)
            {
                suggestionsPopup.close()
                if(savedQueries.indexOf(searchInput.text) < 0)
                {
                    savedQueries.unshift(searchInput.text)
//                    suggestionsPopup.model.insert(0, {suggestion: searchInput.text})
                    bae.saveSetting("QUERIES", savedQueries.join(","), "BABE")
                }

                var query = searchInput.text
                searchTable.headerBarTitle = '"'+query+"'"
                var queries = query.split(",")
                searchRes = bae.searchFor(queries)
                populate(searchView.searchRes)
            }
    }

    function clearSearch()
    {
        searchInput.clear()
        searchTable.clearTable()
        searchTable.headerBarTitle = ""
        searchRes = []
        suggestionsPopup.close()
    }

    function populate(tracks)
    {
        searchTable.clearTable()
        for(var i in tracks)
            searchTable.model.append(tracks[i])
    }

    SearchSuggestions
    {
        id: suggestionsPopup
        focus: false
        parent: searchBox
        width: parent.width*0.9
        height: 200
        modal: false
        closePolicy: Popup.CloseOnPressOutsideParent
        y: -(height+contentMargins*2)
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
                    //focus: true
                    //activeFocusOnPress: true
                    onAccepted: runSearch()

                    onTextChanged:  if(searchInput.text.length>0) suggestionsPopup.open()
                }

                BabeButton
                {
                    Layout.rightMargin: contentMargins
                    iconName: "edit-clear"
                    onClicked: clearSearch()
                }
            }
        }
    }
}
