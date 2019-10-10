import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import AlbumsList 1.0
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.ItemDelegate
{
    id: control

    property int albumSize : Maui.Style.iconSizes.huge
    property int albumRadius : 0
    property bool albumCard : true
    property string fillColor : Qt.darker(Kirigami.Theme.backgroundColor, 1.1)
    property bool hide : false
    property bool showLabels : true
    property bool showIndicator :  false
    property bool hideRepeated : false
    property bool increaseCurrentItem : false
    isCurrentItem: GridView.isCurrentItem
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

    Item
    {
        anchors.fill: parent
        anchors.margins: Maui.Style.space.tiny

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
            width: parent.width
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

        Item
        {
            id: _labelBg
            height: Math.min (parent.height * 0.3, _labelsLayout.implicitHeight ) + Maui.Style.space.medium
            width: parent.width
            anchors.bottom: parent.bottom
            visible: showLabels

            Kirigami.Theme.inherit: false
            Kirigami.Theme.backgroundColor: "#333";
            Kirigami.Theme.textColor: "#fafafa"

            FastBlur
            {
                id: blur
                anchors.fill: parent
                radius: 120
                opacity: 1
                source: ShaderEffectSource
                {
                    sourceItem: img
                    sourceRect:Qt.rect(0,
                                       img.height - _labelBg.height,
                                       _labelBg.width,
                                       _labelBg.height)
                }

                Rectangle
                {
                    anchors.fill: parent
                    color: _labelBg.Kirigami.Theme.backgroundColor
                    opacity: 0.2
                }

            }


            ColumnLayout
            {
                id: _labelsLayout
                anchors.centerIn: parent
                width: parent.width * 0.9
                spacing: 0

                Label
                {
                    Layout.fillWidth: visible
                    Layout.fillHeight: visible
                    text: list.query === Albums.ALBUMS ? model.album : model.artist
                    visible: text && control.width > 50
                    horizontalAlignment: Qt.AlignLeft
                    elide: Text.ElideRight
                    font.pointSize: Maui.Style.fontSizes.default
                    font.bold: true
                    font.weight: Font.Bold
                    color: Kirigami.Theme.textColor
                    wrapMode: Text.NoWrap
                }

                Label
                {
                    Layout.fillWidth: visible
                    Layout.fillHeight: visible

                    text: list.query === Albums.ALBUMS ? model.artist : undefined
                    visible: text && (control.width > 70)
                    horizontalAlignment: Qt.AlignLeft
                    elide: Text.ElideRight
                    font.pointSize: Maui.Style.fontSizes.medium
                    color: Kirigami.Theme.textColor
                    wrapMode: Text.NoWrap
                }
            }
        }
    }



}
