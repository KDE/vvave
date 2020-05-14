import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import "../../view_models"
import "../../view_models/BabeTable"
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.maui.vvave 1.0 as Vvave

Maui.Page
{
    id: youtubeViewRoot
    property var searchRes : []
    clip: true
    property alias viewer : youtubeViewer
    property int openVideo : 0
    headBar.visible: false

    Connections
    {
        target: Vvave.YouTube
        onQueryResultsReady:
        {
            searchRes = res;
            populate(searchRes)
            youtubeTable.forceActiveFocus()

            if(openVideo > 0)
            {
                console.log("trying to open video")
                watchVideo(youtubeTable.model.get(openVideo-1))
                openVideo = 0
            }
        }
    }


    /*this is for playing the track sin the background without showing the actual video*/

    WebView
    {
        id: webView
        anchors.fill: parent
        visible: false
        clip: true
        property bool wasPlaying: false
    //    onRecentlyAudibleChanged:
    //    {
    //        console.log("is playing", recentlyAudible)
    //        if(recentlyAudible && isPlaying)
    //            Player.pauseTrack()

    //        if(!recentlyAudible && wasPlaying)
    //            Player.resumeTrack()
    //    }
    }

    Maui.Dialog
    {
        id: configPopup
        parent: parent
        page.margins: Maui.Style.contentMargins
        widthHint: 0.9
        heightHint: 0.9

        maxHeight: 200
        maxWidth: 300
        defaultButtons: false

        GridLayout
        {
            anchors.fill: parent
            columns: 1
            rows: 6
            clip: true

            Item
            {
                Layout.column: 1
                Layout.row: 1
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Label
            {
                text: qsTr("Custom API Key")
                verticalAlignment:  Qt.AlignVCenter
                elide: Text.ElideRight
                font.pointSize: Maui.Style.fontSizes.default
                Layout.column: 1
                Layout.row: 2
                Layout.fillWidth: true
            }

            TextField
            {
                Layout.column: 1
                Layout.row: 3
                Layout.fillWidth: true
                text: Maui.FM.loadSettings("YOUTUBEKEY", "BABE",  Vvave.YouTube.getKey())
            }

            Label
            {
                text: qsTr("Search results")
                verticalAlignment:  Qt.AlignVCenter
                elide: Text.ElideRight
                font.pointSize: Maui.Style.fontSizes.default
                Layout.column: 1
                Layout.row: 4
                Layout.fillWidth: true
            }

            SpinBox
            {
                Layout.alignment: Qt.AlignRight
                Layout.column: 1
                Layout.row: 5
                Layout.fillWidth: true
                from: 1
                to: 50
                value: Maui.FM.loadSettings("YOUTUBELIMIT", "BABE", 25)
                editable: true
                onValueChanged:
                {
                    Maui.FM.saveSettings("YOUTUBELIMIT", value, "BABE")
                }
            }

            Item
            {
                Layout.column: 1
                Layout.row: 6
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

        }
    }


    StackView
    {
        id: stackView
        anchors.fill: parent
        focus: true

        pushEnter: Transition
        {
            PropertyAnimation
            {
                property: "opacity"
                from: 0
                to:1
                duration: 200
            }
        }

        pushExit: Transition
        {
            PropertyAnimation
            {
                property: "opacity"
                from: 1
                to:0
                duration: 200
            }
        }

        popEnter: Transition
        {
            PropertyAnimation {
                property: "opacity"
                from: 0
                to:1
                duration: 200
            }
        }

        popExit: Transition
        {
            PropertyAnimation
            {
                property: "opacity"
                from: 1
                to:0
                duration: 200
            }
        }


        initialItem: BabeTable
        {
            id: youtubeTable
            trackNumberVisible: false
            headBar.visible: false
            holder.visible: count === 0
            holder.emoji: "qrc:/assets/dialog-information.svg"
            holder.isMask: true
            holder.title : "No Results!"
            holder.body: "Try with another query"
            holder.emojiSize: Maui.Style.iconSizes.huge
            coverArtVisible: true
            model: ListModel{}
            onRowClicked:
            {
                watchVideo(youtubeTable.model.get(index))
            }

            onQuickPlayTrack:
            {
                playTrack(youtubeTable.model.get(index).url)
            }
        }

        YoutubeViewer
        {
            id: youtubeViewer
        }
    }

    footBar.leftContent: ToolButton
    {
        id: menuBtn
        icon.name: "application-menu"
        onClicked: configPopup.open()
    }

    footBar.rightContent: ToolButton
    {
        icon.name: "edit-clear"
        onClicked: clearSearch()
    }

    footBar.middleContent: Maui.TextField
    {
        id: searchInput
        Layout.fillWidth: true

        placeholderText: qsTr("Search videos...")
        wrapMode: TextEdit.Wrap
        onAccepted: runSearch(searchInput.text)
    }

    function watchVideo(track)
    {
        if(track && track.url)
        {
            var url = track.url
            if(url && url.length > 0)
            {
                youtubeViewer.currentYt = track
                youtubeViewer.webView.item.url = url+"?autoplay=1"
                stackView.push(youtubeViewer)

            }
        }
    }

    function playTrack(url)
    {
        if(url && url.length > 0)
        {
            var newURL = url.replace("embed/", "watch?v=")
            console.log(newURL)
            webView.item.url = newURL+"?autoplay=1+&vq=tiny"
            webView.item.runJavaScript("document.title", function(result) { console.log(result); });
        }
    }

    function runSearch(searchTxt)
    {
        if(searchTxt)
            if(searchTxt !== youtubeTable.title)
            {
                youtubeTable.title = searchTxt
                Vvave.YouTube.getQuery(searchTxt, Maui.FM.loadSettings("YOUTUBELIMIT", "BABE", 25))
            }
    }

    function clearSearch()
    {
        searchInput.clear()
        youtubeTable.listView.model.clear()
        youtubeTable.title = ""
        searchRes = []
    }

    function populate(tracks)
    {
        youtubeTable.model.clear()
        for(var i in tracks)
            youtubeTable.model.append(tracks[i])
    }
}
