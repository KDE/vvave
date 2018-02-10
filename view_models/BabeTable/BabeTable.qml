import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami

import ".."

BabeList
{
//    id: list
    holder.message: "<h2>This list is empty</h2><p>You can sdd new music sources from the settings</p>"
    //    cacheBuffer : 300
    headerBarColor: midLightColor

    property bool trackNumberVisible
    property bool quickPlayVisible : true
    property bool coverArtVisible : false
    property bool menuItemVisible : isMobile
    property int prevIndex
    property bool trackDuration
    property bool trackRating

    property alias headerMenu: headerMenu
    property alias contextMenu : contextMenu

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
        iconName : /*"amarok_clock"*/ "media-playback-start"
        onClicked : playAll()
    }

    headerBarRight: [
        BabeButton
        {
            id: appendBtn
            visible: headerBarVisible && count > 0
            anim : true
            iconName : "archive-insert"//"media-repeat-track-amarok"
            onClicked: appendAll()
        },

        BabeButton
        {
            id: menuBtn
            iconName: /*"application-menu"*/ "overflow-menu"
            onClicked: headerMenu.popup()
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


        Connections
        {
            target: delegate

            onPressAndHold: if(root.isMobile) openItemMenu(index)
            onRightClicked: openItemMenu(index)

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
        for(var i = 0; i < model.count; ++i)
            trackList.push(model.get(i).url)

        playlistDialog.tracks = trackList
        playlistDialog.open()
    }

    //    Component.onCompleted: forceActiveFocus()
}
