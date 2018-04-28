import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models"

import org.kde.kirigami 2.2 as Kirigami

Page
{
    id: videoPlayback
    property alias webView: webViewer.item
    property bool wasPlaying: false
    property var currentYt : ({})

    ColumnLayout
    {
        anchors.fill: parent

        spacing: 0

        ToolBar
        {
            id: headerRoot
            width: parent.width
            Layout.fillWidth: true
            focus: true

            RowLayout
            {
                id: headerBar
                anchors.fill: parent

                BabeButton
                {
                    Layout.alignment : Qt.AlignLeft
                    Layout.leftMargin: contentMargins
                    width: rowHeight
                    iconName : "go-previous"
                    onClicked: stackView.pop(youtubeList)
                }

                Label
                {
                    text : currentYt ? currentYt.title : "YouTube"
                    Layout.fillHeight : true
                    Layout.fillWidth : true
                    Layout.alignment : Qt.AlignCenter
                    color: textColor
                    elide : Text.ElideRight
                    font.bold : false
                    font.pointSize: fontSizes.big
                    horizontalAlignment : Text.AlignHCenter
                    verticalAlignment :  Text.AlignVCenter
                }

                BabeButton
                {
                    Layout.alignment : Qt.AlignLeft
                    width: rowHeight
                    iconName : "link"
                    onClicked: webView.url = currentYt.url.replace("embed/", "watch?v=")
                }

                BabeButton
                {
                    Layout.alignment : Qt.AlignLeft
                    width: rowHeight
                    iconName : "download"
                    onClicked: bae.getYoutubeTrack(JSON.stringify(currentYt))

                }

                BabeButton
                {
                    Layout.alignment : Qt.AlignLeft
                    Layout.rightMargin: contentMargins
                    width: rowHeight
                    iconName : "overflow-menu"
                }
            }
        }

        Loader
        {
            id: webViewer
            clip: true
            Layout.fillHeight: true
            Layout.fillWidth: true
            source: isAndroid ? "qrc:/services/web/WebView_A.qml" : "qrc:/services/web/WebView.qml"
            onVisibleChanged:
            {
                if(!visible) webView.url = "about:blank"

                console.log(webView.url, visible)
            }

        }

    }
}
