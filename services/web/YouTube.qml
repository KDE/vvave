import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models"
import "../../view_models/BabeTable"
import org.kde.kirigami 2.2 as Kirigami


Page
{
    id: youtubeViewRoot
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


    Loader
    {
        id: youtubeViewer
        source: isMobile ? "qrc:/services/web/YoutubeViewer_A.qml" : "qrc:/services/web/YoutubeViewer.qml"

    }


    BabePopup
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
                font.pointSize: fontSizes.medium
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
                font.pointSize: fontSizes.medium
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

    function runSearch(searchTxt)
    {
        if(searchTxt)
            if(searchTxt !== youtubeTable.headerBarTitle)
            {
                youtubeTable.headerBarTitle = searchTxt
                youtube.getQuery(searchTxt, bae.loadSetting("YOUTUBELIMIT", "BABE", 25))
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
                onClicked: configPopup.open()
            }

            onRowClicked:
            {
                youtubeViewer.item.open()
                youtubeViewer.item.webView.url= youtubeTable.model.get(index).url
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
