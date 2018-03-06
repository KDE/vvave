import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models"
import QtWebKit 3.0

BabePopup
{
    id: videoPlayback
    property alias webView: webView
    maxHeight: 200

    WebView
    {
        id: webView
        anchors.fill: parent
        onLoadingChanged: {
            if (loadRequest.errorString)
                console.error(loadRequest.errorString);
        }
    }
}
