import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import AlbumsList 1.0

ItemDelegate
{
    id: babeAlbumRoot

    property int itemWidth : albumSize
    property int itemHeight: albumSize
    property int albumSize : iconSizes.huge
    property int albumRadius : 0
    property bool albumCard : true
    property string fillColor : Qt.darker(backgroundColor, 1.1)
    property bool hide : false
    property bool showLabels : true
    property bool showIndicator :  false
    property bool isCurrentListItem : ListView.isCurrentItem
    property bool hideRepeated : false
    property bool increaseCurrentItem : false

    property color labelColor : GridView.isCurrentItem  || hovered || down ? highlightColor : textColor
    //    height: typeof album === 'undefined' ? parseInt(albumSize+(albumSize*0.3)) : parseInt(albumSize+(albumSize*0.4))

    readonly property bool sameAlbum :
    {
        if(hideRepeated)
        {
            if(albumsRollRoot.model.get(index-1))
            {
                if(albumsRollRoot.model.get(index-1).album === album && albumsRollRoot.model.get(index-1).artist === artist)
                    true
                else
                    false
            }else false
        }else false
    }

    height: visible ? itemHeight : 0
    width : visible ? itemWidth : 0

    visible: !sameAlbum
    hoverEnabled: !isMobile
    //    spacing: 0

    background: Rectangle
    {
        color: "transparent"
    }

    ColumnLayout
    {
        anchors.fill: parent
        anchors.centerIn: parent

        Item
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumHeight: albumSize
            Layout.minimumHeight: albumSize

            DropShadow
            {
                anchors.fill: card
                visible: card.visible
                horizontalOffset: 0
                verticalOffset: 3
                radius: 8.0
                samples: 17
                color: "#80000000"
                source: card
            }

            Rectangle
            {
                id: card
                z: -999
                visible: albumCard
                anchors.centerIn: img
                anchors.fill: img

                color: fillColor
                radius: albumRadius
            }

            Image
            {
                id: img
                width: increaseCurrentItem ? albumSize * (isCurrentListItem ? 1 : 0.85) : albumSize
                height: width

                anchors.centerIn: parent

                sourceSize.width: parent.width
                sourceSize.height: parent.height

                fillMode: Image.PreserveAspectFit
                cache: true
                antialiasing: true
                smooth: true
                asynchronous: true

                source:
                {
                    if(artwork)
                        (artwork.length > 0 && artwork !== "NONE")? "file://"+encodeURIComponent(artwork) : "qrc:/assets/cover.png"
                    else "qrc:/assets/cover.png"
                }
                layer.enabled: albumRadius
                layer.effect: OpacityMask
                {
                    maskSource: Item
                    {
                        width: img.width
                        height: img.height

                        Rectangle
                        {
                            anchors.centerIn: parent
                            width: img.adapt ? img.width : Math.min(img.width, img.height)
                            height: img.adapt ? img.height : width
                            radius: albumRadius
                            border.color: borderColor
                        }
                    }
                }
            }

            Rectangle
            {
                visible : showIndicator && currentTrackIndex === index

                height: img.height * 0.1
                width: img.width * 0.1
                anchors.bottom: parent.bottom
                anchors.bottomMargin: space.big
                anchors.horizontalCenter:parent.horizontalCenter
                radius: Math.min(width, height)
                color: "#f84172"

                AnimatedImage
                {
                    source: "qrc:/assets/heart_indicator_white.gif"
                    anchors.centerIn: parent
                    height: parent.height * 0.6
                    width: parent.width * 0.6
                    playing: parent.visible
                }
            }
        }

        Item
        {
            visible: showLabels
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: 0

            ColumnLayout
            {
                anchors.fill: parent
                spacing: space.tiny

                Item
                {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    //            Layout.margins: space.medium

                    Label
                    {
                        width: parent.width * 0.8
                        anchors.centerIn: parent
                        text: list.query === Albums.ALBUMS ? model.album : model.artist
                        visible: true
                        horizontalAlignment: Qt.AlignHCenter
                        elide: Text.ElideRight
                        font.pointSize: fontSizes.default
                        font.bold: true
                        font.weight: Font.Bold
                        color: labelColor
                    }
                }

                Item
                {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop

                    Label
                    {
                        width: parent.width*0.8
                        anchors.centerIn: parent

                        text: list.query === Albums.ALBUMS ? model.artist : undefined
                        visible: text
                        horizontalAlignment: Qt.AlignHCenter
                        elide: Text.ElideRight
                        font.pointSize: fontSizes.medium
                        color: labelColor
                    }
                }
            }

        }
    }
}
