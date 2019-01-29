import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami
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
    property alias listView : babeTableRoot.listView
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

    property alias headerMenu: headerMenu
    property alias contextMenu : contextMenu

    property alias playAllBtn : playAllBtn
    property alias appendBtn : appendBtn
    property alias menuBtn : menuBtn

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

    headBar.leftContent: [
        Maui.ToolButton
        {
            id : playAllBtn
            visible : headBar.visible && count > 0
            anim : true
            iconName : "media-playlist-play"
            onClicked : playAll()
        },

        Maui.ToolButton
        {
            id: sortBtn
            anim: true
            iconName: "view-sort"

            onClicked: sortMenu.popup()

            Maui.Menu
            {
                id: sortMenu

                Maui.MenuItem
                {
                    text: qsTr("Title")
                    checkable: true
                    checked: list.sortBy === Tracks.TITLE
                    onTriggered: list.sortBy = Tracks.TITLE
                }

                Maui.MenuItem
                {
                    text: qsTr("Artist")
                    checkable: true
                    checked: list.sortBy === Tracks.ARTIST
                    onTriggered: list.sortBy = Tracks.ARTIST
                }

                Maui.MenuItem
                {
                    text: qsTr("Album")
                    checkable: true
                    checked: list.sortBy === Tracks.ALBUM
                    onTriggered: list.sortBy = Tracks.ALBUM
                }

                Maui.MenuItem
                {
                    text: qsTr("Rate")
                    checkable: true
                    checked: list.sortBy === Tracks.RATE
                    onTriggered: list.sortBy = Tracks.RATE
                }


                Maui.MenuItem
                {
                    text: qsTr("Fav")
                    checkable: true
                    checked: list.sortBy === Tracks.FAV
                    onTriggered: list.sortBy = Tracks.FAV
                }


                Maui.MenuItem
                {
                    text: qsTr("Release date")
                    checkable: true
                    checked: list.sortBy === Tracks.RELEASEDATE
                    onTriggered: list.sortBy = Tracks.RELEASEDATE
                }

                Maui.MenuItem
                {
                    text: qsTr("Add date")
                    checkable: true
                    checked: list.sortBy === Tracks.ADDDATE
                    onTriggered: list.sortBy = Tracks.ADDDATE
                }

                MenuSeparator{}

                Maui.MenuItem
                {
                    text: qsTr("Group")
                    checkable: true
                    checked: group
                    onTriggered: group = !group
                }
            }
        }
    ]

    headBar.rightContent: [

        Maui.ToolButton
        {
            id: appendBtn
            visible: headBar.visible && count > 0
            anim : true
            iconName : "media-playlist-append"//"media-repeat-track-amarok"
            onClicked: appendAll()
        },

        Maui.ToolButton
        {
            id: menuBtn
            iconName: /*"application-menu"*/ "overflow-menu"
            onClicked: headerMenu.popup()
        }
    ]

    HeaderMenu
    {
        id: headerMenu
        onSaveListClicked: saveList()
        onQueueListClicked: queueList()
    }

    TableMenu
    {
        id: contextMenu

        menuItem: [
            Maui.MenuItem
            {
                text: qsTr("Select...")
                onTriggered:
                {
                    H.addToSelection(listView.model.get(listView.currentIndex))
                    contextMenu.close()
                }
            },
            MenuSeparator {},
            Maui.MenuItem
            {
                text: qsTr("Go to Artist")
                onTriggered: goToArtist()

            },
            Maui.MenuItem
            {
                text: qsTr("Go to Album")
                onTriggered: goToAlbum()
            }
        ]

        onFavClicked:
        {
            list.fav(listView.currentIndex, !(list.get(listView.currentIndex).fav == "1"))
        }

        onQueueClicked: H.queueIt(paths)
        onSaveToClicked:
        {
            playlistDialog.tracks = paths
            playlistDialog.open()
        }
        onOpenWithClicked: bae.showFolder(paths)

        onRemoveClicked:
        {
            listModel.remove(listView.currentIndex)
        }

        onRateClicked:
        {
            var value = H.rateIt(paths, rate)
            listView.currentItem.rate(H.setStars(value))
            listView.model.get(listView.currentIndex).rate = value
        }

        onColorClicked:
        {
                list.color(listView.currentIndex, color);
        }
    }

    listView.highlightFollowsCurrentItem: false
    listView.highlightMoveDuration: 0
    listView.highlight: Rectangle { }

    section.criteria: ViewSection.FullString
    section.delegate: Maui.LabelDelegate
    {
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
        coverArt : coverArtVisible
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
        contextMenu.show([list.get(currentIndex).url])

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
        root.pageStack.currentIndex = 1
        root.currentView = viewsIndex.albums
        var item = listView.model.get(listView.currentIndex)
        albumsView.populateTable(item.album, item.artist)
        contextMenu.close()
    }

    function goToArtist()
    {
        root.pageStack.currentIndex = 1
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
                break
            }

        section.property =  prop
    }
}
