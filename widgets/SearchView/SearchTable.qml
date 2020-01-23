import QtQuick 2.10
import QtQuick.Controls 2.10
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

    trackNumberVisible: false
    holder.emoji: "qrc:/assets/dialog-information.svg"
    holder.isMask: true
    holder.title : qsTr("No search results!")
    holder.body: qsTr("Try with another query")
    holder.emojiSize: Maui.Style.iconSizes.huge
    coverArtVisible: true

    headBar.leftContent: Maui.TextField
    {
        id: searchInput
        placeholderText: qsTr("Search...")
        Layout.fillWidth: true

        onAccepted: runSearch(searchInput.text)
        //                    onActiveFocusChanged: if(activeFocus && autoSuggestions) suggestionsPopup.open()
        onTextEdited: if(autoSuggestions) suggestionsPopup.updateSuggestions()
        onCleared: clearSearch()
    }

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

        color: Kirigami.Theme.backgroundColor
        z: 999
        opacity: 0.5
    }


    function runSearch(searchTxt)
    {
        if(searchTxt)
            {
                if(savedQueries.indexOf(searchTxt) < 0)
                {
                    savedQueries.unshift(searchTxt)
                    //                    suggestionsPopup.model.insert(0, {suggestion: searchInput.text})
                    Maui.FM.saveSettings("QUERIES", savedQueries.join(","), "BABE")
                }
                var queries = searchTxt.split(",")
                searchTable.list.searchQueries(queries)
                searchTable.forceActiveFocus()
                suggestionsPopup.close()
            }
    }

    function clearSearch()
    {
        searchInput.clear()
        searchTable.list.clear()
        suggestionsPopup.close()
    }

    function populate(tracks)
    {
        searchTable.clearTable()
        for(var i in tracks)
            searchTable.model.append(tracks[i])
    }
}

