import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami
import "../../utils/Player.js" as Player

import ".."

BabeList
{
    id: babeTableRoot
    holder.message: "<h2>This list is empty</h2><p>You can sdd new music sources from the settings</p>"
    //    cacheBuffer : 300
    headerBarColor: backgroundColor
    labelColor: textColor

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

    headerBarLeft:  BabeButton
    {
        id : playAllBtn
        visible : headerBarVisible && count > 0
        anim : true
        iconName : "media-playlist-play"
        onClicked : playAll()
    }

    headerBarRight: [

        BabeButton
        {
            id: appendBtn
            visible: headerBarVisible && count > 0
            anim : true
            iconName : "media-playlist-append"//"media-repeat-track-amarok"
            onClicked: appendAll()
        },

        BabeButton
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
    }

    TableMenu
    {
        id: contextMenu
    }

    ListModel { id: listModel }

    model: listModel


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
        color: babeTableRoot.labelColor
        bgColor: headerBarColor
        remoteArtwork: isArtworkRemote
        playingIndicator: showIndicator

        Connections
        {
            target: delegate

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
