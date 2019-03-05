import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3
import "../../view_models"
import QtGraphicalEffects 1.0

import "../../view_models/BabeTable"
import "../../db/Queries.js" as Q


BabeTable
{
    id: searchTable

    property alias searchInput : searchInput
    property var savedQueries : []

//    property bool autoSuggestions : bae.loadSetting("AUTOSUGGESTIONS", "BABE", false) === "true" ? true : false
    property bool autoSuggestions : false


    Layout.fillHeight: true
    Layout.fillWidth: true
    trackNumberVisible: false
    headBar.visible: true
    headBarExit: true
    headBarExitIcon: "edit-clear"
    holder.emoji: "qrc:/assets/BugSearch.png"
    holder.isMask: false
    holder.title : "No search results!"
    holder.body: "Try with another query"
    holder.emojiSize: iconSizes.huge
    coverArtVisible: true
    trackDuration: true
    trackRating: true
    onExit: clearSearch()

    footBar.middleContent:  Maui.TextField
    {
        id: searchInput
        placeholderText: qsTr("Search...")
        width: footBar.middleLayout.width * 0.9

        onAccepted: runSearch(searchInput.text)
        //                    onActiveFocusChanged: if(activeFocus && autoSuggestions) suggestionsPopup.open()
        onTextEdited: if(autoSuggestions) suggestionsPopup.updateSuggestions()

    }


//    footBar.leftContent: Maui.ToolButton
//    {
//        visible: true
//        iconName: "view-filter"
//        iconColor: autoSuggestions ? babeColor : textColor
//        onClicked:
//        {
//            autoSuggestions = !autoSuggestions
//            Maui.FM.saveSettings("AUTOSUGGESTIONS", autoSuggestions, "BABE")
//            if(!autoSuggestions)
//                suggestionsPopup.close()
//        }
//    }

    SearchSuggestions
    {
        id: suggestionsPopup
//        focus: false
        parent: parent
//        modal: false
//        closePolicy: Popup.CloseOnPressOutsideParent
    }

    Rectangle
    {
        visible: suggestionsPopup.visible
        width: parent.width
        height: parent.height - searchInput.height

        color: darkDarkColor
        z: 999
        opacity: 0.5
    }


    function runSearch(searchTxt)
    {
        if(searchTxt)
            if(searchTxt !== searchTable.headBarTitle)
            {
                if(savedQueries.indexOf(searchTxt) < 0)
                {
                    savedQueries.unshift(searchTxt)
                    //                    suggestionsPopup.model.insert(0, {suggestion: searchInput.text})
                    Maui.FM.saveSettings("QUERIES", savedQueries.join(","), "BABE")
                }

                searchTable.headBarTitle = searchTxt
                var queries = searchTxt.split(",")
                searchTable.list.searchQueries(queries)
                searchTable.forceActiveFocus()
                suggestionsPopup.close()
            }
    }

    function clearSearch()
    {
        searchInput.clear()
        searchTable.clearTable()
        searchTable.headBarTitle = ""
        suggestionsPopup.close()
    }

    function populate(tracks)
    {
        searchTable.clearTable()
        for(var i in tracks)
            searchTable.model.append(tracks[i])
    }

}

