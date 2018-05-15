import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models"
import "../../view_models/BabeTable"
import "../../widgets/PlaylistsView"
import "../../utils/Help.js" as H
import "../../db/Queries.js" as Q
import Link.Codes 1.0

import org.kde.kirigami 2.2 as Kirigami
import org.kde.maui 1.0 as Maui

ColumnLayout
{
    id: linkingViewRoot
    property alias linkingConf : linkingConf
    signal rowClicked(var track)
    signal quickPlayTrack(var track)
    signal playAll(var tracks)
    signal playSync(var playlist)
    signal appendAll(var tracks)

    spacing: 0

    Kirigami.PageRow
    {
        id: linkingPage
        Layout.fillHeight: true
        Layout.fillWidth: true

        clip: true
        separatorVisible: wideMode
        initialPage: [playlistList, linkingResults]
        defaultColumnWidth: Kirigami.Units.gridUnit * 15
        interactive: false

        LinkingDialog
        {
            id: linkingConf
        }

        Page
        {
            id: playlistList
            clip: true
            anchors.fill: parent

            SwipeView
            {
                id: linkingSwipe
                anchors.fill: parent

                interactive: false
                clip: true

                LinkingListModel
                {
                    id: linkingModel
                }

                BabeList
                {
                    id: linkingFilter

                    headBarExitIcon: "go-previous"

                    model : ListModel {}
                    delegate: BabeDelegate
                    {
                        id: delegate
                        label : tag
                        Connections
                        {
                            target: delegate
                            onClicked: populateFromFilter(index, linkingFilter.headBarTitle)
                        }
                    }

                    onExit: linkingSwipe.currentIndex = 0
                }

            }
        }

        Page
        {
            id: linkingResults
            anchors.fill: parent
            clip: true

            BabeTable
            {
                id: filterList
                anchors.fill: parent
                quickPlayVisible: true
                coverArtVisible: false
                trackRating: true
                trackDuration: false
                allowMenu: false
                headBarVisible: true
                headBarExitIcon: "go-previous"
                headBarExit: !linkingPage.wideMode
                headBarTitle: linkingPage.wideMode ? "" : linkingModel.model.get(linkingModel.currentIndex).playlist
                onExit: if(!linkingPage.wideMode)
                            linkingPage.currentIndex = 0

                holder.message:  "<h2>"+link.getDeviceName()+"</h2><p>Your linked playlist is empty</p>"
                holder.emoji: "qrc:/assets/face-hug.png"

                appendBtn.visible: false
                playAllBtn.visible: false
                menuBtn.visible: false

                section.criteria: ViewSection.FullString
                section.delegate: BabeDelegate
                {
                    label: filterList.section.property === qsTr("stars") ? H.setStars(section) : section
                    isSection: true
                    boldLabel: true
                    fontFamily: "Material Design Icons"

                }

                Connections
                {
                    target: filterList
                    onRowClicked: {}
                    onQuickPlayTrack:
                    {

//                        link.collectTrack(filterList.model.get(index).url)
//                        player.playRemote("ftp://"+link.getIp()+filterList.model.get(index).url)


                    }
                    onPlayAll: {}
                    onPulled: {}
                }
            }
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
//        width: parent.width
//        height: toolBarHeight
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
                color: textColor
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment:  Text.AlignVCenter
                selectByMouse: !root.isMobile
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

    Connections
    {
        target: link
        onServerConReady:
        {
            isServing = true
            H.notify(deviceName, "You're now linked!")
        }

        onClientConError:
        {
            isLinked = false
            H.notify("Linking error", "error connecting to server")
        }

        onDevicesLinked:
        {
            isLinked = true
            H.notify("Linked!", "The link is ready")
            refreshPlaylists()
        }

        onClientConDisconnected:
        {
            isLinked = false;
            H.notify("Unlinked!", "The client is disconnected")

        }

        onServerConDisconnected:
        {
            isServing = false;
            H.notify("Unlinked!", "The server is disconnected")
        }

        onResponseReady: parseResponse(res)
    }

    function refreshPlaylists()
    {
        for(var i=11; i < linkingModel.count; i++)
            linkingModel.model.remove(i)

        if(isLinked)
            link.ask(LINK.PLAYLISTS, Q.GET.playlists)
    }

    function appendPlaylists(res)
    {
        if(res.length>0)
            for(var i in res)
                linkingModel.model.append(res[i])
    }

    function appendToExtraList(res)
    {
        if(res.length>0)
            for(var i in res)
                linkingFilter.model.append(res[i])
    }

    function populateExtra(code, query, title)
    {
        linkingSwipe.currentIndex = 1

        link.ask(code, query)
        linkingFilter.clearTable()
        linkingFilter.headBarTitle = title
    }

    function parseResponse(res)
    {
        switch(res.CODE)
        {
        case LINK.PLAYLISTS:
            appendPlaylists(res.MSG)
            break
        case LINK.FILTER:
            appendToExtraList(res.MSG)
            break
        case LINK.QUERY:
        case LINK.SEARCHFOR:
            populate(res.MSG)
            break

        default: console.log(res.CODE, res.MSG); break;
        }
    }

    function populateFromFilter(index, title)
    {
        linkingFilter.currentIndex = index
        var tag = linkingFilter.model.get(index).tag
        switch(title)
        {
        case "Albums":
            var artist = linkingFilter.model.get(index).artist
            var query = Q.GET.albumTracks_.arg(tag)
            link.ask(LINK.QUERY, query.arg(artist))
            break
        case "Artists":
            query = Q.GET.artistTracks_.arg(tag)
            link.ask(LINK.QUERY, query.arg(tag))
            break
        case "Genres":
            query = Q.GET.genreTracks_.arg(tag)
            link.ask(LINK.QUERY, query.arg(tag))
            break
        case "Tags":
            query = Q.GET.tagTracks_.arg(tag)
            link.ask(LINK.QUERY, query.arg(tag))
            break
        default: break
        }
    }

    function populate(tracks)
    {
        if(!linkingPage.wideMode)
            linkingPage.currentIndex = 1

        filterList.clearTable()

        if(tracks.length>0)
            for(var i in tracks)
                filterList.model.append(tracks[i])
    }


    function runSearch(searchTxt)
    {
        if(searchTxt)
            if(searchTxt !== filterList.headBarTitle)
            {
                filterList.headBarTitle = searchTxt
                link.ask(LINK.SEARCHFOR, searchTxt)
            }
    }

    function clearSearch()
    {
        searchInput.clear()
        youtubeTable.clearTable()
        youtubeTable.headBarTitle = ""
        searchRes = []
    }



}

