import QtQuick 2.0

import "../../view_models"

BabePopup
{
    id: searchSuggestionsRoot
    property alias model : suggestionsList.model
    BabeList
    {
        id: suggestionsList
        anchors.fill: parent
        headerBarVisible: false

        model: ListModel {id: suggestionsModel}

        delegate: BabeDelegate
        {
            id: delegate
            label: suggestion

            Connections
            {
                target: delegate

                onClicked:
                {
                    suggestionsList.currentIndex = index
                    searchInput.text = suggestionsList.model.get(index).suggestion
                    runSearch()

                }
            }
        }
    }

    onOpened:
    {
        suggestionsList.clearTable()

        var qq = bae.loadSetting("QUERIES", "BABE", {})
        savedQueries = qq.split(",")

        for(var i=0; i < 5; i++)
            if(i < savedQueries.length )
                suggestionsList.model.append({suggestion: savedQueries[i]})
    }
}
