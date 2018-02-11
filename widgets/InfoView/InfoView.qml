import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import "../../view_models"

Page
{
    id: infoRoot
    property string lyrics
    property string wikiArtist
    property string wikiAlbum
    property string artistHead

    property int currentView : 0

    clip: true
    Rectangle
    {
        anchors.fill: parent
        z: -999
        color: midLightColor
    }


    SwipeView
    {
        id: infoSwipeView
        anchors.fill: parent

        currentIndex: currentView

        Rectangle
        {
            color: "transparent"
            BabeHolder
            {
                id: lyricsHolder
                anchors.fill: parent
                visible: lyrics ? false : true
                message: "Couldn't find the lyrics!"
            }

            ScrollView
            {
                anchors.fill: parent
                clip: true
                contentWidth: lyricsText.width
                contentHeight: lyricsText.height

                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Text
                {
                    id: lyricsText
                    width: infoRoot.width      // ensure correct width

                    padding: 20
                    text: lyrics
                    color: foregroundColor
                    font.pointSize: fontSizes.big
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter
                    textFormat: Text.RichText
                    wrapMode: Text.Wrap
                }
            }

        }

        Rectangle
        {
            color: "transparent"

            BabeHolder
            {
                id: wikiHolder
                visible: wikiAlbumText.visible && wikiArtistText.visible ? false : true
                message: "Couldn't find the wiki!"
            }

            ColumnLayout
            {

                width:parent.width
                height:parent.height

//                Rectangle
//                {

//                    width: children.width
//                    height: children.height

//                    anchors.horizontalCenter: parent
//                    Image
//                    {
//                        id: img
//                        width: 100
//                        height: 100

//                        fillMode: Image.PreserveAspectFit

//                        source: (artistHead.length>0 && artistHead !== "NONE")? "file://"+encodeURIComponent(artistHead) : "qrc:/assets/cover.png"
//                        layer.enabled: true
//                        layer.effect: OpacityMask
//                        {
//                            maskSource: Item
//                            {
//                                width: img.width
//                                height: img.height
//                                Rectangle
//                                {
//                                    anchors.centerIn: parent
//                                    width: img.adapt ? img.width : Math.min(img.width, img.height)
//                                    height: img.adapt ? img.height : width
//                                    radius: Math.min(width, height)
//                                    border.color: foregroundColor
//                                    border.width: 4
//                                }
//                            }
//                        }
//                    }

//                }


                ScrollView
                {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    clip: true
                    contentWidth: wikiAlbumText.width
                    contentHeight: wikiAlbumText.height

                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    Text
                    {
                        id: wikiAlbumText
                        width: infoRoot.width      // ensure correct width

                        padding: 20
                        text: wikiAlbum
                        visible: wikiAlbum === "NONE" || wikiAlbum.length===0 ? false : true
                        color: foregroundColor
                        font.pointSize: fontSizes.big
                        horizontalAlignment: Qt.AlignHCenter
                        textFormat: Text.RichText
                        wrapMode: Text.Wrap
                    }
                }

                ScrollView
                {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    clip: true
                    contentWidth: wikiArtistText.width
                    contentHeight: wikiArtistText.height

                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    Text
                    {
                        id: wikiArtistText
                        width: infoRoot.width      // ensure correct width

                        padding: 20
                        text: wikiArtist
                        visible: wikiArtist === "NONE" || wikiArtist.length===0 ? false : true

                        color: foregroundColor
                        font.pointSize: fontSizes.big
                        horizontalAlignment: Qt.AlignHCenter
                        textFormat: Text.StyledText
                        wrapMode: Text.Wrap
                    }
                }

            }
        }

    }

}
