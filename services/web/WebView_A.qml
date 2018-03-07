import QtQuick 2.0
import QtWebView 1.1
import "../../utils/Player.js" as Player

WebView
{
    id: webView

    onLoadingChanged:
    {
        if (loadRequest.errorString)
            console.error(loadRequest.errorString);
    }
}
