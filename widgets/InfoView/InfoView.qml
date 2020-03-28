import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import "../../view_models"

Maui.Dialog
{
    id: control

    defaultButtons: false
    property alias lyricsText : lyricsText
    property string wikiArtist
    property string wikiAlbum
    property string artistHead

    property int currentView : 0

    Kirigami.Theme.backgroundColor: "#333"
    Kirigami.Theme.textColor: "#fafafa"

    clip: true

    SwipeView
    {
        id: infoSwipeView
        Layout.fillHeight: true
        Layout.fillWidth: true

        currentIndex: currentView

        Rectangle
        {
            color: "transparent"

            Maui.Holder
            {
                id: lyricsHolder
                visible: lyricsText.text.length > 0 ? false : true
                message: "Couldn't find the lyrics!"
            }

            ScrollView
            {
                anchors.fill: parent
                clip: true
                contentWidth: lyricsText.width
                contentHeight: lyricsText.height

                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                TextEdit
                {
                    id: lyricsText
                    text: currentTrack ? currentTrack.lyrics : ""
                    width: control.width      // ensure correct width
                    height: implicitHeight
                    readOnly: true
                    padding: 20
                    color: "white"
                    font.pointSize: Maui.Style.fontSizes.big
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

            Maui.Holder
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
                        width: control.width      // ensure correct width

                        padding: 20
                        text: wikiAlbum
                        visible: wikiAlbum === "NONE" || wikiAlbum.length===0 ? false : true
                        font.pointSize: Maui.Style.fontSizes.big
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
                        width: control.width      // ensure correct width

                        padding: 20
                        text: wikiArtist
                        visible: wikiArtist === "NONE" || wikiArtist.length===0 ? false : true

                        font.pointSize: Maui.Style.fontSizes.big
                        horizontalAlignment: Qt.AlignHCenter
                        textFormat: Text.StyledText
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }

    function show(track)
    {
        control.open()

        bae.trackLyrics(track.url)
    }
}
