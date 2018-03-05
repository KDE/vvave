import QtQuick 2.9
import QtWebView 1.1
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models"

Page
{
    property alias web : webView
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
