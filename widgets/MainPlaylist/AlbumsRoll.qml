import QtQuick.Controls 2.2
import QtQuick 2.9
import QtQuick.Layouts 1.3

import "../../view_models/BabeGrid"
import org.kde.kirigami 2.0 as Kirigami
import "../../utils/Player.js" as Player

ListView
{
    id: albumsRollRoot
    orientation: ListView.Horizontal
    clip: true
    focus: true
    interactive: true
    currentIndex: currentTrackIndex
    highlightFollowsCurrentItem: true
    highlightMoveDuration: 0
    snapMode: ListView.SnapToOneItem
    model: mainPlaylist.listModel
    highlightRangeMode: ListView.StrictlyEnforceRange
    keyNavigationEnabled: true
    keyNavigationWraps : true
    onMovementEnded:
    {
        var index = indexAt(contentX, contentY)
        if(index !== currentTrackIndex)
            Player.playAt(index)

        //         positionViewAtIndex(index, ListView.Center)
    }

    //    onCurrentIndexChanged: Player.playAt(currentIndex)

    delegate: GridLayout
    {
        height: albumsRollRoot.height
        width: albumsRollRoot.width
        clip: true
        columns: 2
        rows: 2

        rowSpacing: space.tiny
        columnSpacing: space.big

        BabeAlbum
        {
            id: delegate
            Layout.row: 1
            Layout.rowSpan: 2
            Layout.column: 1
            Layout.preferredWidth: iconSizes.big + space.big
            Layout.fillHeight: true


            albumSize : iconSizes.big + space.big
            albumRadius : radiusV
            showLabels: false
            showIndicator: false
            hideRepeated: false
            //        increaseCurrentItem : true

            Connections
            {
                target: delegate
                onClicked:
                {
                    albumsRollRoot.currentIndex = index
                    play(index)
                }
            }
        }

        Label
        {
            Layout.row: 1
            Layout.column: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: model.title
            color: textColor
            font.pointSize: fontSizes.default
            verticalAlignment: Qt.AlignBottom
            clip: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere

        }

        Label
        {
            Layout.row: 2
            Layout.column: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: model.artist + " | " + model.album
            font.pointSize: fontSizes.small
            verticalAlignment: Qt.AlignTop
            clip: true
            color: textColor

            wrapMode: Text.WrapAtWordBoundaryOrAnywhere



        }
    }



    function positionAlbum(index)
    {
        albumsRollRoot.currentIndex = index
        positionViewAtIndex(index, ListView.Center)
    }
}
