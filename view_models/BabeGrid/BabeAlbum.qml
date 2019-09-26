import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import AlbumsList 1.0
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.GridItemDelegate
{
    id: babeAlbumRoot

    property int albumSize : Maui.Style.iconSizes.huge
    property int albumRadius : 0
    property bool albumCard : true
    property string fillColor : Qt.darker(Kirigami.Theme.backgroundColor, 1.1)
    property bool hide : false
    property bool showLabels : true
    property bool showIndicator :  false
    property bool hideRepeated : false
    property bool increaseCurrentItem : false

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

    visible: !sameAlbum

    ColumnLayout
    {
        anchors.fill: parent
        spacing: 0

        Item
        {
            Layout.alignment: Qt.AlignCenter
            Layout.fillHeight: true
            Layout.minimumHeight: albumSize
            Layout.preferredWidth: albumSize

            DropShadow
            {
                anchors.fill: card
                visible: card.visible
                horizontalOffset: 0
                verticalOffset: 0
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
                anchors.centerIn: parent
                width: albumSize
                height: width
                sourceSize.width: width
                sourceSize.height: height

                fillMode: Image.PreserveAspectFit
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
                anchors.bottomMargin: Maui.Style.space.big
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

       Label
        {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: list.query === Albums.ALBUMS ? model.album : model.artist
            visible: showLabels && (albumSize > 50)
            horizontalAlignment: Qt.AlignHCenter
            elide: Text.ElideRight
            font.pointSize: Maui.Style.fontSizes.default
            font.bold: true
            font.weight: Font.Bold
            color: labelColor
            wrapMode: Text.NoWrap
        }

        Label
        {
            Layout.fillWidth: true
            Layout.fillHeight: true

            text: list.query === Albums.ALBUMS ? model.artist : undefined
            visible: showLabels && text && (albumSize > 70)
            horizontalAlignment: Qt.AlignHCenter
            elide: Text.ElideRight
            font.pointSize: Maui.Style.fontSizes.medium
            color: labelColor
            wrapMode: Text.NoWrap
        }
    }
}
