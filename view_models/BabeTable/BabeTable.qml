import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui

import BaseModel 1.0
import TracksList 1.0

import "../../utils/Player.js" as Player
import "../../utils/Help.js" as H
import "../../db/Queries.js" as Q

import ".."

BabeList
{
    id: babeTableRoot
    //    cacheBuffer : 300

    property alias list : _tracksList
    property alias listModel : _tracksModel
    property alias removeDialog : _removeDialog

    property bool trackNumberVisible
    property bool quickPlayVisible : true
    property bool coverArtVisible : false
    property bool menuItemVisible : isMobile
    property bool trackDuration
    property bool trackRating
    property bool allowMenu: true
    property bool isArtworkRemote : false
    property bool showIndicator : false

    property bool group : false

    property alias contextMenu : contextMenu
    property alias contextMenuItems : contextMenu.contentData

    property alias playAllBtn : playAllBtn
    property alias appendBtn : appendBtn

    signal rowClicked(int index)
    signal rowPressed(int index)
    signal quickPlayTrack(int index)
    signal queueTrack(int index)

    signal artworkDoubleClicked(int index)

    signal playAll()
    signal appendAll()

    //    altToolBars: true

    onGroupChanged: groupBy()

    focus: true

    //headBar.middleStrech: false
    headBar.leftSretch: false
    headBar.rightContent: Kirigami.ActionToolBar
    {
        position: Controls.ToolBar.Header
        Layout.fillWidth: true
        actions:   [
            Kirigami.Action
            {
                id : playAllBtn
                text: qsTr("Play all")
                icon.name : "media-playlist-play"
                onTriggered: playAll()
            },
            Kirigami.Action
            {
                id: appendBtn
                text: qsTr("Append")
                icon.name : "media-playlist-append"//"media-repeat-track-amarok"
                onTriggered: appendAll()
            },
            Kirigami.Action
            {
                id: sortBtn
                text: qsTr("Sort")
                icon.name: "view-sort"
                Kirigami.Action
                {
                    text: qsTr("Title")
                    checkable: true
                    checked: list.sortBy === Tracks.TITLE
                    onTriggered: list.sortBy = Tracks.TITLE
                }

//                Kirigami.Action
//                {
//                    text: qsTr("Track")
//                    checkable: true
//                    checked: list.sortBy === Tracks.TRACK
//                    onTriggered: list.sortBy = Tracks.TRACK
//                }

//                Kirigami.Action
//                {
//                    text: qsTr("Artist")
//                    checkable: true
//                    checked: list.sortBy === Tracks.ARTIST
//                    onTriggered: list.sortBy = Tracks.ARTIST
//                }

//                Kirigami.Action
//                {
//                    text: qsTr("Album")
//                    checkable: true
//                    checked: list.sortBy === Tracks.ALBUM
//                    onTriggered: list.sortBy = Tracks.ALBUM
//                }

//                Kirigami.Action
//                {
//                    text: qsTr("Most played")
//                    checkable: true
//                    checked: list.sortBy === Tracks.COUNT
//                    onTriggered: list.sortBy = Tracks.COUNT
//                }

//                Kirigami.Action
//                {
//                    text: qsTr("Rate")
//                    checkable: true
//                    checked: list.sortBy === Tracks.RATE
//                    onTriggered: list.sortBy = Tracks.RATE
//                }

//                Kirigami.Action
//                {
//                    text: qsTr("Fav")
//                    checkable: true
//                    checked: list.sortBy === Tracks.FAV
//                    onTriggered: list.sortBy = Tracks.FAV
//                }

//                Kirigami.Action
//                {
//                    text: qsTr("Release date")
//                    checkable: true
//                    checked: list.sortBy === Tracks.RELEASEDATE
//                    onTriggered: list.sortBy = Tracks.RELEASEDATE
//                }

//                Kirigami.Action
//                {
//                    text: qsTr("Add date")
//                    checkable: true
//                    checked: list.sortBy === Tracks.ADDDATE
//                    onTriggered: list.sortBy = Tracks.ADDDATE
//                }


//                Kirigami.Action
//                {
//                    text: qsTr("Group")
//                    checkable: true
//                    checked: group
//                    onTriggered: group = !group
//                }
            },

            Kirigami.Action
            {
                text: qsTr("Select")
                icon.name: "item-select"
                onTriggered: selectionMode = !selectionMode
                checkable: false
                checked: selectionMode
            }
        ]
    }



    Maui.Dialog
    {
        id: _removeDialog
        property int index
        title: qsTr("Remove track")
        message: qsTr("You can delete the file from your computer or remove it from your collection")
        rejectButton.text: qsTr("Delete")
        //        rejectButton.icon.name: "archive-remove"
        acceptButton.text: qsTr("Remove")

        onAccepted:
        {
            list.remove(listView.currentIndex)
            close()
        }

        onRejected:
        {
            if(Maui.FM.removeFile(list.get(index).url))
                list.remove(listView.currentIndex)
            close()
        }
    }

    TableMenu
    {
        id: contextMenu


        MenuSeparator {}

        MenuItem
        {
            text: qsTr("Go to Artist")
            onTriggered: goToArtist()

        }

        MenuItem
        {
            text: qsTr("Go to Album")
            onTriggered: goToAlbum()
        }


        onFavClicked:
        {
            list.fav(listView.currentIndex, !(list.get(listView.currentIndex).fav == "1"))
        }

        onQueueClicked: Player.queueTracks([list.get(listView.currentIndex)])

        onSaveToClicked:
        {
            playlistDialog.tracks = [list.get(listView.currentIndex).url]
            playlistDialog.open()
        }

        onOpenWithClicked: Maui.FM.openLocation([list.get(listView.currentIndex).url])

        onRemoveClicked:
        {
            _removeDialog.index= listView.currentIndex
            _removeDialog.open()
        }

        onRateClicked:
        {
            list.rate(listView.currentIndex, rate);
        }

        onColorClicked:
        {
            list.color(listView.currentIndex, color);
        }

        onInfoClicked:
        {
            infoView.show(list.get(listView.currentIndex))
        }

        onCopyToClicked:
        {
            cloudView.list.upload(listView.currentIndex)
        }

        onShareClicked:
        {
            isAndroid ? Maui.Android.shareDialog(list.get(listView.currentIndex)) :
                        shareDialog.show([list.get(listView.currentIndex).url])
        }
    }

    section.criteria: ViewSection.FullString
    section.delegate: Maui.LabelDelegate
    {
        id: _sectionDelegate
        label: section
        isSection: true
        boldLabel: true
        colorScheme.backgroundColor: "#333"
        colorScheme.textColor: "#fafafa"

        background: Rectangle
        {
            color:  colorScheme.backgroundColor
        }
    }


    BaseModel
    {
        id: _tracksModel
        list: _tracksList
    }

    Tracks
    {
        id: _tracksList
        onSortByChanged: if(babeTableRoot.group) babeTableRoot.groupBy()
    }

    model: _tracksModel

    //    property alias animBabe: delegate.animBabe
    delegate: TableDelegate
    {
        id: delegate

        width: listView.width

        number : trackNumberVisible ? true : false
        quickPlay: quickPlayVisible
        coverArt : coverArtVisible ? (babeTableRoot.width > 300) : coverArtVisible
        trackDurationVisible : trackDuration
        trackRatingVisible : trackRating
        menuItem: menuItemVisible
        remoteArtwork: isArtworkRemote
        playingIndicator: showIndicator

        onPressAndHold: if(isMobile && allowMenu) openItemMenu(index)
        onRightClicked: if(allowMenu) openItemMenu(index)

        onClicked:
        {
            currentIndex = index
            if(selectionMode)
            {
                H.addToSelection(listView.model.get(listView.currentIndex))
                return
            }

            if(isMobile)
                rowClicked(index)

        }

        onDoubleClicked:
        {
            currentIndex = index
            if(!isMobile)
                rowClicked(index)
        }

        onPlay:
        {
            currentIndex = index
            quickPlayTrack(index)
        }

        onArtworkCoverClicked:
        {
            currentIndex = index
            goToAlbum()
        }
    }

    function openItemMenu(index)
    {
        currentIndex = index
        contextMenu.rate = list.get(currentIndex).rate
        contextMenu.fav = list.get(currentIndex).fav == "1"
        contextMenu.popup()

        rowPressed(index)

        console.log(list.get(currentIndex).fav)
    }

    function saveList()
    {
        var trackList = []
        if(model.count > 0)
        {
            for(var i = 0; i < model.count; ++i)
                trackList.push(model.get(i).url)

            playlistDialog.tracks = trackList
            playlistDialog.open()
        }
    }

    function queueList()
    {
        var trackList = []

        if(model.count > 0)
        {
            for(var i = 0; i < model.count; ++i)
                trackList.push(model.get(i))

            Player.queueTracks(trackList)
        }
    }

    function goToAlbum()
    {
        root.currentView = viewsIndex.albums
        var item = listView.model.get(listView.currentIndex)
        albumsView.populateTable(item.album, item.artist)
        contextMenu.close()
    }

    function goToArtist()
    {
        root.currentView = viewsIndex.artists
        var item = listView.model.get(listView.currentIndex)
        artistsView.populateTable(undefined, item.artist)
        contextMenu.close()
    }

    function groupBy()
    {
        var prop = "undefined"

        if(group)
            switch(list.sortBy)
            {
            case Tracks.TITLE:
                prop = "title"
                break
            case Tracks.ARTIST:
                prop = "artist"
                break
            case Tracks.ALBUM:
                prop = "album"
                break
            case Tracks.RATE:
                prop = "rate"
                break
            case Tracks.FAV:
                prop = "fav"
                break
            case Tracks.ADDDATE:
                prop = "adddate"
                break
            case Tracks.RELEASEDATE:
                prop = "releasedate"
                break;
            case Tracks.COUNT:
                prop = "count"
                break
            }

        section.property =  prop
    }
}
