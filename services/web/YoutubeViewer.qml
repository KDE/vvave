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

        Rectangle
        {
            id: headerRoot
            width: parent.width
            height:  visible ?  toolBarHeight : 0
            Layout.fillWidth: true
            focus: true
            color: darkDarkColor

            Kirigami.Separator
            {
                visible: !isMobile
                width: parent.width
                height: 1
                anchors
                {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
            }

            RowLayout
            {
                id: headerBar
                anchors.fill: parent

                BabeButton
                {
                    Layout.alignment : Qt.AlignLeft
                    Layout.leftMargin: contentMargins
                    width: rowHeight
                    iconName : "arrow-left"
                    iconColor: darkForegroundColor
                    onClicked: stackView.pop(youtubeList)
                }

                Label
                {
                    text : currentYt ? currentYt.title : "YouTube"
                    Layout.fillHeight : true
                    Layout.fillWidth : true
                    Layout.alignment : Qt.AlignCenter

                    elide : Text.ElideRight
                    font.bold : false
                    color : darkForegroundColor
                    font.pointSize: fontSizes.big
                    horizontalAlignment : Text.AlignHCenter
                    verticalAlignment :  Text.AlignVCenter
                }

                BabeButton
                {
                    Layout.alignment : Qt.AlignLeft
                    width: rowHeight
                    iconName : "link"
                    iconColor: darkForegroundColor
                    onClicked: webView.url = currentYt.url.replace("embed/", "watch?v=")
                }

                BabeButton
                {
                    Layout.alignment : Qt.AlignLeft
                    width: rowHeight
                    iconName : "download"
                    iconColor: darkForegroundColor
                    onClicked: bae.getYoutubeTrack(JSON.stringify(currentYt))

                }

                BabeButton
                {
                    Layout.alignment : Qt.AlignLeft
                    Layout.rightMargin: contentMargins
                    width: rowHeight
                    iconName : "overflow-menu"
                    iconColor: darkForegroundColor
                }
            }
        }

        Loader
        {
            id: webViewer
            Layout.fillHeight: true
            Layout.fillWidth: true
            source: isMobile ? "qrc:/services/web/WebView_A.qml" : "qrc:/services/web/WebView.qml"
            onVisibleChanged:
            {
                if(!visible) webView.url = "about:blank"

                console.log(webView.url, visible)
            }

        }

    }
}
