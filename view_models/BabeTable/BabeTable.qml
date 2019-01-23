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

    focus: true


    property alias list : _tracksList

    property bool trackNumberVisible
    property bool quickPlayVisible : true
    property bool coverArtVisible : false
    property bool menuItemVisible : isMobile
    property bool trackDuration
    property bool trackRating
    property bool allowMenu: true
    property bool isArtworkRemote : false
    property bool showIndicator : false

    property string sortBy: "undefined"

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

    headBar.leftContent: Maui.ToolButton
    {
        id : playAllBtn
        visible : headBar.visible && count > 0
        anim : true
        iconName : "media-playlist-play"
        onClicked : playAll()
    }

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
        onSortClicked: groupDialog.popup()
    }

    GroupDialog
    {
        id: groupDialog
        onSortBy: sortBy = babeTableRoot.sortBy = text

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
            var value = H.faveIt(paths)
            model.get(listView.currentIndex).fav = value ? "1" : "0"
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

            if(paths.length > 1)
            H.moodIt(paths, color)
            else
                list.color(listView.currentIndex, color);

            listView.currentItem.trackMood = color
        }
    }

    listView.highlightFollowsCurrentItem: false
    listView.highlightMoveDuration: 0
    listView.highlight: Rectangle { }

    section.property : sortBy
    section.criteria: ViewSection.FullString
    section.delegate: Maui.LabelDelegate
    {
        label: section
        isSection: true
        boldLabel: true
    }


    BaseModel
    {
        id: _tracksModel
        list: _tracksList
    }

    Tracks
    {
        id: _tracksList
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
        contextMenu.fav = list.get(currentIndex).fav
        contextMenu.show([list.get(currentIndex).url])

        rowPressed(index)
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

    //    Component.onCompleted: forceActiveFocus()
}
