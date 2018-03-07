import QtQuick 2.0
import QtWebEngine 1.5
import "../../utils/Player.js" as Player

WebEngineView
{
    id: webView

    onLoadingChanged:
    {
        if (loadRequest.errorString)
            console.error(loadRequest.errorString);
    }

    onRecentlyAudibleChanged:
    {
        console.log("is playing", recentlyAudible)
        if(recentlyAudible && isPlaying)
        {
            wasPlaying = isPlaying
            Player.pauseTrack()
        }

        if(!recentlyAudible && wasPlaying)
            Player.resumeTrack()
    }
}
