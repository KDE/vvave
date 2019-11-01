import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import QtWebEngine 1.5
import "../../../view_models"

BabePopup
{
    padding: 0
    maxHeight: parent.height * 0.8
    maxWidth: parent.width * 0.5
    closePolicy: Popup.CloseOnPressOutsideParent
    WebEngineView
    {
        anchors.fill: parent

        url: "https://accounts.spotify.com/en/authorize?response_type=token&client_id=a49552c9276745f5b4752250c2d84367&scope=streaming user-read-private user-read-email&redirect_uri=vvave:%2F%2Fcallback"
        onLoadingChanged:
        {
            var myUrl = url.toString()
            if(myUrl.startsWith("vvave://callback/#access_token="))
            {
                var code = myUrl.slice(("vvave://callback/#access_token=").length, myUrl.length)
                spotify.setCode(code);
                url = "qrc:/services/web/Spotify/spotify.html"

            }

            if(loadRequest.status === WebEngineLoadRequest.LoadSucceededStatus)
                console.log("page loaded sucessfully")
        }

        onNewViewRequested:
        {
            console.log("new view requested")
        }

    }

}
