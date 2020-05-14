import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import "../../view_models"
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: videoPlayback
    property alias webView: webView
    property bool wasPlaying: false
    property var currentYt : ({})

    title: currentYt ? currentYt.title : "YouTube"

    headBar.leftContent: ToolButton
    {
        icon.name: "go-previous"
        onClicked: stackView.pop(youtubeTable)
    }

    headBar.rightContent: [

        ToolButton
        {
            icon.name : "link"
            onClicked: webView.item.url = currentYt.url.replace("embed/", "watch?v=")
        },

        ToolButton
        {
            icon.name : "download"
            onClicked: bae.getYoutubeTrack(JSON.stringify(currentYt))
        }
    ]

    WebView
    {
        id: webView
        anchors.fill: parent
        visible: true
        clip: true
        property bool wasPlaying: false

        onVisibleChanged: if(!visible) webView.item.url = "about:blank"


    //    onRecentlyAudibleChanged:
    //    {
    //        console.log("is playing", recentlyAudible)
    //        if(recentlyAudible && isPlaying)
    //            Player.pauseTrack()

    //        if(!recentlyAudible && wasPlaying)
    //            Player.resumeTrack()
    //    }
    }

}
