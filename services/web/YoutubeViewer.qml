import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models"

import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.Page
{
    id: videoPlayback
    property alias webView: webViewer.item
    property bool wasPlaying: false
    property var currentYt : ({})
    margins: 0

    headBarExitIcon: "go-previous"
    onExit: stackView.pop(youtubeTable)
    headBarTitle: currentYt ? currentYt.title : "YouTube"

    headBar.rightContent: [

        Maui.ToolButton
        {
            iconName : "link"
            onClicked: webView.url = currentYt.url.replace("embed/", "watch?v=")
        },

        Maui.ToolButton
        {
            iconName : "download"
            onClicked: bae.getYoutubeTrack(JSON.stringify(currentYt))
        }
    ]

    Loader
    {
        id: webViewer
        clip: true
        anchors.fill: parent
        source: isAndroid ? "qrc:/services/web/WebView_A.qml" : "qrc:/services/web/WebView.qml"
        onVisibleChanged: if(!visible) webView.url = "about:blank"
    }

}
