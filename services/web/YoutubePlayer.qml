import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import "../../view_models"
import QtWebEngine 1.5
import "../../utils/Player.js" as Player
import "YoutubeHelper.js" as YTH
WebEngineView
{
    id: webView
    anchors.fill: parent
    visible: true
    property bool wasPlaying: false


    onLoadingChanged:
    {
        if (loadRequest.errorString)
            console.error(loadRequest.errorString);
    }

    onRecentlyAudibleChanged:
    {
        console.log("is playing", recentlyAudible)
        if(recentlyAudible && isPlaying)
            Player.pauseTrack()

        if(!recentlyAudible && wasPlaying)
            Player.resumeTrack()
    }
}
