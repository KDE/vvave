import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.mauikit 1.0 as Maui

import "../../view_models/BabeTable"

import CloudList 1.0
import BaseModel 1.0

BabeTable
{
    id: control

    headBarExit: false

    property alias list : _cloudList

    BaseModel
    {
        id: _cloudModel
        list: _cloudList
    }

    CloudList
    {
        id: _cloudList
        account: currentAccount
    }

    model: _cloudModel

    delegate: TableDelegate
    {
        id: delegate

        width: listView.width

        number :  false
        quickPlay: true
        coverArt : false
        trackDurationVisible : false
        trackRatingVisible : false
        menuItem: false
        remoteArtwork: false
        playingIndicator: false

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
            if(Maui.FM.fileExists(_cloudList.get(index).thumbnail))
            {
                quickPlayTrack(index)
            }else
            {
                _cloudList.requestFile(index)
            }
        }

        onArtworkCoverClicked:
        {
            currentIndex = index
            goToAlbum()
        }
    }
}
