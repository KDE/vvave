import QtQuick 2.10
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import AlbumsList 1.0
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

Maui.ItemDelegate
{
    id: control

    property int albumSize : Maui.Style.iconSizes.huge
    property int albumRadius : 0
    property bool showLabels : true

    property alias label1 : _label1
    property alias label2 : _label2
    property alias image : _image

    isCurrentItem: GridView.isCurrentItem
    background: Item {}

    Item
    {
        id: _cover
        anchors.fill: parent

        Image
        {
            id: _image
            width: parent.width
            height: width
            sourceSize.width: width
            sourceSize.height: height

            fillMode: Image.PreserveAspectFit
            smooth: true
            asynchronous: true

            onStatusChanged:
            {
                if (status == Image.Error)
                    source = "qrc:/assets/cover.png"
            }

            layer.enabled: albumRadius
            layer.effect: OpacityMask
            {
                maskSource: Item
                {
                    width: _image.width
                    height: _image.height

                    Rectangle
                    {
                        anchors.centerIn: parent
                        width: _image.adapt ? _image.width : Math.min(_image.width, _image.height)
                        height: _image.adapt ? _image.height : width
                        radius: albumRadius
                    }
                }
            }
        }

        Item
        {
            id: _labelBg
            height: Math.min (parent.height * 0.3, _labelsLayout.implicitHeight ) + Maui.Style.space.big
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
                source: ShaderEffectSource
                {
                    sourceItem: _image
                    sourceRect:Qt.rect(0,
                                       _image.height - _labelBg.height,
                                       _labelBg.width,
                                       _labelBg.height)
                }
                radius: _image.source === "qrc:/assets/cover.png" ? 0 : 50

                Rectangle
                {
                    anchors.fill: parent
                    color: _labelBg.Kirigami.Theme.backgroundColor
                    opacity: 0.4
                }

                layer.enabled: true
                layer.effect: OpacityMask
                {
                    maskSource: Item
                    {
                        width: blur.width
                        height: blur.height

                        Rectangle
                        {
                            anchors.centerIn: parent
                            width: parent.width
                            height: parent.height
                            radius: albumRadius

                            Rectangle
                            {
                                anchors.top: parent.top
                                width: parent.width
                                height: parent.radius
                            }
                        }
                    }
                }
            }

            ColumnLayout
            {
                id: _labelsLayout
                anchors.centerIn: parent
                width: parent.width * 0.9
                height: Math.min(parent.height * 0.9, implicitHeight)
                spacing: 0

                Label
                {
                    id: _label1
                    Layout.fillWidth: visible
                    Layout.fillHeight: visible
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
                    id: _label2
                    Layout.fillWidth: visible
                    Layout.fillHeight: visible
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

    Rectangle
    {
        anchors.fill: parent
        visible: control.isCurrentItem || control.hovered
        color: "transparent"
        border.color: control.isCurrentItem || control.hovered ? Kirigami.Theme.highlightColor : "transparent"
        border.width: 2
        radius: albumRadius
    }

    DropShadow
    {
        anchors.fill: _cover
        visible: !control.hovered
        horizontalOffset: 0
        verticalOffset: 0
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: _cover
    }
}
