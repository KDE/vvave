import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models"
import "../../view_models/BabeTable"
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui

Page
{
    id: youtubeViewRoot
    property var searchRes : []
    clip: true

    property alias viewer : youtubeViewer
    property int openVideo : 0

    Connections
    {
        target: youtube
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

    function watchVideo(track)
    {
        if(track && track.url)
        {
            var url = track.url
            if(url && url.length > 0)
            {
                youtubeViewer.currentYt = track
                youtubeViewer.webView.url = url+"?autoplay=1"
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
            youtubePlayer.item.url = newURL+"?autoplay=1+&vq=tiny"
            youtubePlayer.item.runJavaScript("document.title", function(result) { console.log(result); });
        }
    }

    function runSearch(searchTxt)
    {
        if(searchTxt)
            if(searchTxt !== youtubeTable.headBarTitle)
            {
                youtubeTable.headBarTitle = searchTxt
                youtube.getQuery(searchTxt, bae.loadSetting("YOUTUBELIMIT", "BABE", 25))
            }
    }

    function clearSearch()
    {
        searchInput.clear()
        youtubeTable.clearTable()
        youtubeTable.headBarTitle = ""
        searchRes = []
    }

    function populate(tracks)
    {
        youtubeTable.clearTable()
        for(var i in tracks)
            youtubeTable.model.append(tracks[i])
    }

    /*this is for playing the track sin the background without showing the actual video*/
    Loader
    {
        id: youtubePlayer
        source: isAndroid ? "qrc:/services/web/YoutubePlayer_A.qml" :
                            "qrc:/services/web/YoutubePlayer.qml"
    }

    Maui.Popup
    {
        id: configPopup
        parent: parent
        margins: contentMargins

        GridLayout
        {
            anchors.centerIn: parent
            width: parent.width*0.8
            height: parent.height*0.9
            columns: 1
            rows: 6

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
                font.pointSize: fontSizes.default
                Layout.column: 1
                Layout.row: 2
                Layout.fillWidth: true
            }

            TextField
            {
                Layout.column: 1
                Layout.row: 3
                Layout.fillWidth: true
                text: bae.loadSetting("YOUTUBEKEY", "BABE",  youtube.getKey())
            }

            Label
            {
                text: qsTr("Search results")
                verticalAlignment:  Qt.AlignVCenter
                elide: Text.ElideRight
                font.pointSize: fontSizes.default
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
                value: bae.loadSetting("YOUTUBELIMIT", "BABE", 25)
                editable: true
                onValueChanged:
                {
                    bae.saveSetting("YOUTUBELIMIT", value, "BABE")
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


        initialItem: Item
        {
            id: youtubeList
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
                    headBarVisible: true
                    headBarExit: true
                    headBarExitIcon: "edit-clear"
                    headBarTitle: "YouTube"
                    holder.emoji: "qrc:/assets/Astronaut.png"
                    holder.isMask: false
                    holder.title : "No Results!"
                    holder.body: "Try with another query"
                    holder.emojiSize: iconSizes.huge
                    coverArtVisible: true
                    trackDuration: true
                    trackRating: true
                    onExit: clearSearch()
                    isArtworkRemote: true
                    allowMenu: false

                    appendBtn.visible: false
                    playAllBtn.visible: false
                    menuBtn.visible: false

                    headBar.rightContent: Maui.ToolButton
                    {
                        id: menuBtn
                        iconName: "application-menu"
                        onClicked: configPopup.open()
                    }

                    onRowClicked:
                    {
                        watchVideo(youtubeTable.model.get(index))
                    }

                    onQuickPlayTrack:
                    {
                        playTrack(youtubeTable.model.get(index).url)
                    }
                }

                ToolBar
                {
                    id: searchBox
                    Layout.fillWidth: true
                    position: ToolBar.Footer

                    RowLayout
                    {
                        anchors.fill: parent

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
                            onAccepted: runSearch(searchInput.text)

                        }

                        Maui.ToolButton
                        {
                            Layout.rightMargin: contentMargins
                            iconName: "edit-clear"
                            onClicked: searchInput.clear()
                        }

                    }
                }
            }
        }

        YoutubeViewer
        {
            id: youtubeViewer
        }
    }
}
