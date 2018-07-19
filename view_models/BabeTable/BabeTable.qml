import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami
import org.kde.maui 1.0 as Maui
import "../../utils/Player.js" as Player
import "../../utils/Help.js" as H

import ".."

BabeList
{
    id: babeTableRoot
    //    cacheBuffer : 300

    focus: true

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

    headBar.leftContent: Maui.ToolButton
    {
        id : playAllBtn
        visible : headBarVisible && count > 0
        anim : true
        iconName : "media-playlist-play"
        onClicked : playAll()
    }

    headBar.rightContent: [

        Maui.ToolButton
        {
            id: appendBtn
            visible: headBarVisible && count > 0
            anim : true
            iconName : "media-playlist-append"//"media-repeat-track-amarok"
            onClicked: appendAll()
        },

        Maui.ToolButton
        {
            id: menuBtn
            iconName: /*"application-menu"*/ "overflow-menu"
            onClicked: isMobile ? headerMenu.open() : headerMenu.popup()
        }
    ]

    PlaylistDialog
    {
        id: playlistDialog
    }

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
    }

    list.highlightFollowsCurrentItem: false
    list.highlightMoveDuration: 0
    list.highlight: Rectangle { }

    ListModel { id: listModel }

    model: listModel

    section.property : sortBy
    section.criteria: ViewSection.FullString
    section.delegate: Maui.LabelDelegate
    {
        label: section
        isSection: true
        boldLabel: true
    }

    //    property alias animBabe: delegate.animBabe
    delegate: TableDelegate
    {
        id: delegate

        width: list.width

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
            if(root.isMobile)
                rowClicked(index)

        }

        onDoubleClicked:
        {
            if(!root.isMobile)
                rowClicked(index)
        }

        onPlay: quickPlayTrack(index)

        onArtworkCoverDoubleClicked: artworkDoubleClicked(index)

    }


    function openItemMenu(index)
    {
        currentIndex = index
        contextMenu.rate = bae.getTrackStars(model.get(currentIndex).url)
        contextMenu.babe = bae.trackBabe(model.get(currentIndex).url)
        if(root.isMobile) contextMenu.open()
        else
            contextMenu.popup()
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

    //    Component.onCompleted: forceActiveFocus()
}
