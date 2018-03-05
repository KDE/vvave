import QtQuick 2.9
import QtWebKit 3.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models"
import "../../view_models/BabeTable"
import org.kde.kirigami 2.2 as Kirigami


Page
{
    id: youtubeViewRoot
    property alias web : webView
    property var searchRes : []
    clip: true
    Connections
    {
        target: youtube
        onQueryResultsReady:
        {
            searchRes = res;
            populate(searchRes)
            youtubeTable.forceActiveFocus()
        }
    }

    BabePopup
    {
        id: videoPlayback
        WebView
        {
            id: webView
            anchors.fill: parent
            onLoadingChanged: {
                if (loadRequest.errorString)
                    console.error(loadRequest.errorString);
            }
        }
    }

    function runSearch(searchTxt)
    {
        if(searchTxt)
            if(searchTxt !== youtubeTable.headerBarTitle)
            {
                youtubeTable.headerBarTitle = searchTxt
                youtube.getQuery(searchTxt)
            }

    }

    function clearSearch()
    {
        searchInput.clear()
        youtubeTable.clearTable()
        youtubeTable.headerBarTitle = ""
        searchRes = []
    }

    function populate(tracks)
    {
        youtubeTable.clearTable()
        for(var i in tracks)
            youtubeTable.model.append(tracks[i])
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
            id: youtubeTable
            Layout.fillHeight: true
            Layout.fillWidth: true
            trackNumberVisible: false
            headerBarVisible: true
            headerBarExit: true
            headerBarExitIcon: "edit-clear"
            holder.message: "No YouTube results!"
            coverArtVisible: true
            trackDuration: true
            trackRating: true
            onExit: clearSearch()
            isArtworkRemote: true

            appendBtn.visible: false
            playAllBtn.visible: false
            menuBtn.visible: false

            headerBarRight: BabeButton
            {
                id: menuBtn
                iconName: "application-menu"
            }

            onRowClicked:
            {
                videoPlayback.open()
                webView.url= youtubeTable.model.get(index).url
            }

            onQuickPlayTrack:
            {
                bae.getYoutubeTrack(JSON.stringify(youtubeTable.model.get(index)))
            }


        }

        Kirigami.Separator
        {
            visible: !isMobile
            Layout.fillWidth: true
            width: parent.width
            height: 1
        }

        ToolBar
        {
            id: searchBox
            Layout.fillWidth: true
            width: parent.width
            height: toolBarHeight
            position: ToolBar.Footer

            Rectangle
            {
                anchors.fill: parent
                z: -999
                color: backgroundColor
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
                    focus: true
                    text: ""
                    wrapMode: TextEdit.Wrap
                    onAccepted: runSearch(searchInput.text)
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
