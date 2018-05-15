import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.maui 1.0 as Maui
import QtQuick.Layouts 1.3
import "../../view_models"
import QtGraphicalEffects 1.0

import "../../view_models/BabeTable"
import "../../db/Queries.js" as Q

Page
{
    property alias searchInput : searchInput
    property alias searchTable : searchTable
    property var searchRes : []
    property var savedQueries : []

    property bool autoSuggestions : bae.loadSetting("AUTOSUGGESTIONS", "BABE", false) === "true" ? true : false

    function runSearch(searchTxt)
    {
        if(searchTxt)
            if(searchTxt !== searchTable.headBarTitle)
            {
                if(savedQueries.indexOf(searchTxt) < 0)
                {
                    savedQueries.unshift(searchTxt)
                    //                    suggestionsPopup.model.insert(0, {suggestion: searchInput.text})
                    bae.saveSetting("QUERIES", savedQueries.join(","), "BABE")
                }

                searchTable.headBarTitle = searchTxt
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
        searchTable.headBarTitle = ""
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

    ColumnLayout
    {
        anchors.fill: parent
        width: parent.width
        height: parent.height

        Layout.margins: 0
        spacing: 0

        BabeTable
        {
            id: searchTable
            Layout.fillHeight: true
            Layout.fillWidth: true
            trackNumberVisible: false
            headBarVisible: true
            headBarExit: true
            headBarExitIcon: "edit-clear"
            holder.message: "<h2>No search results!</h2><p>Try with another query</p>"
            coverArtVisible: true
            trackDuration: true
            trackRating: true
            onExit: clearSearch()
        }

        ToolBar
        {
            id: searchBox
            Layout.fillWidth: true
            position: ToolBar.Footer

            RowLayout
            {
                anchors.fill: parent

                Maui.ToolButton
                {
                    visible: true
                    iconName: "view-filter"
                    iconColor: autoSuggestions ? babeColor : textColor
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
                    color: textColor
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment:  Text.AlignVCenter
                    selectByMouse: !isMobile
                    selectionColor: highlightColor
                    selectedTextColor: highlightedTextColor
                    focus: true
                    text: ""
                    wrapMode: TextEdit.Wrap
                    //activeFocusOnPress: true
                    onAccepted: runSearch(searchInput.text)
                    //                    onActiveFocusChanged: if(activeFocus && autoSuggestions) suggestionsPopup.open()
                    onTextEdited: if(autoSuggestions) suggestionsPopup.updateSuggestions()

                }

                Maui.ToolButton
                {
                    iconName: "edit-clear"
                    onClicked: searchInput.clear()
                }
            }
        }
    }
}
