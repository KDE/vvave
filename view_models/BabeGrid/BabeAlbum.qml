import QtQuick 2.14
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

import org.maui.vvave 1.0

Maui.ItemDelegate
{
    id: control

    property int albumSize : Maui.Style.iconSizes.huge
    property int albumRadius : 0
    property bool showLabels : true

    property alias label1 : _labelsLayout.label1
    property alias label2 : _labelsLayout.label2
    property alias template: _labelsLayout

    property alias image : _image

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


            Maui.ListItemTemplate
            {
                id: _labelsLayout
                anchors.centerIn: parent
                width: parent.width * 0.9
                height: Math.min(parent.height * 0.9, implicitHeight)
                implicitHeight: label1.implicitHeight + label2.implicitHeight + spacing

                label1.visible: label1.text && control.width > 50
                label1.font.pointSize: Maui.Style.fontSizes.default
                label1.font.bold: true
                label1.font.weight: Font.Bold

                label2.visible: label2.text && (control.width > 70)
                label2.font.pointSize: Maui.Style.fontSizes.medium
                label2.wrapMode: Text.NoWrap
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
