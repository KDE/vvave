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

    property bool autoSuggestions : bae.loadSetting("AUTOSUGGESTIONS", "BABE", false) === "true" ? true : false

    function runSearch(searchTxt)
    {
        if(searchTxt)
            if(searchTxt !== searchTable.headerBarTitle)
            {
                if(savedQueries.indexOf(searchTxt) < 0)
                {
                    savedQueries.unshift(searchTxt)
                    //                    suggestionsPopup.model.insert(0, {suggestion: searchInput.text})
                    bae.saveSetting("QUERIES", savedQueries.join(","), "BABE")
                }

                searchTable.headerBarTitle = searchTxt
                var queries = searchTxt.split(",")
                searchRes = bae.searchFor(queries)
                populate(searchView.searchRes)
                searchTable.forceActiveFocus()
                suggestionsPopup.close()
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
        visible: suggestionsPopup.visible
        width: parent.width
        height: parent.height-searchBox.height

        color: darkDarkColor
        z: 999
        opacity: 0.5
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
        width: parent.width
        height: parent.height

        BabeTable
        {
            id: searchTable
            Layout.fillHeight: true
            Layout.fillWidth: true
            trackNumberVisible: false
            headerBarVisible: true
            headerBarExit: true
            headerBarExitIcon: "edit-clear"
            holder.message: "No search results!"
            coverArtVisible: true
            trackDuration: true
            trackRating: true
            onExit: clearSearch()
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
                    iconColor: autoSuggestions ? babeColor : foregroundColor
                    onClicked:
                    {
                        autoSuggestions = !autoSuggestions
                        bae.saveSetting("AUTOSUGGESTIONS", autoSuggestions, "BABE")
                        if(!autoSuggestions)
                            suggestionsPopup.close()
                    }
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
                    focus: true
                    text: ""
                    wrapMode: TextEdit.Wrap
                    //activeFocusOnPress: true
                    onAccepted: runSearch(searchInput.text)
//                    onActiveFocusChanged: if(activeFocus && autoSuggestions) suggestionsPopup.open()
                    onTextEdited: if(autoSuggestions) suggestionsPopup.updateSuggestions()
                }

                BabeButton
                {
                    Layout.rightMargin: contentMargins
                    iconName: "edit-clear"
                    onClicked: searchInput.clear()
                }
            }
        }
    }
}
