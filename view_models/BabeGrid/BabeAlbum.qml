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
    property int albumRadius : Maui.Style.radiusV
    property bool showLabels : label1.text.length || label2.text.length

    property alias label1 : _labelsLayout.label1
    property alias label2 : _labelsLayout.label2
    property alias template: _labelsLayout

    property alias image : _image


    Kirigami.Theme.inherit: false
    Kirigami.Theme.backgroundColor: "#333";
    Kirigami.Theme.textColor: "#fafafa"

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

            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: true

            onStatusChanged:
            {
                if (status == Image.Error)
                    source = "qrc:/assets/cover.png"
            }
        }

        LinearGradient
        {
            anchors.fill: parent
            start: Qt.point(0, 0)
            end: Qt.point(0, parent.height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: control.isCurrentItem || control.hovered ? 0.7 : 0.9 ; color: control.Kirigami.Theme.backgroundColor }
            }
        }

        Item
        {
            id: _labelBg
            height: _labelsLayout.implicitHeight + Maui.Style.space.big
            width: parent.width
            anchors.bottom: parent.bottom
            visible: showLabels

            Maui.ListItemTemplate
            {
                id: _labelsLayout
                width: parent.width * 0.9
                anchors.centerIn: parent
                label1.visible: label1.text && control.width > 50
                label1.font.pointSize: Maui.Style.fontSizes.big
                label1.wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                label1.font.bold: true
                label1.font.weight: Font.Bold

                label2.visible: label2.text && (control.width > 70)
                label2.font.pointSize: Maui.Style.fontSizes.medium
                label2.wrapMode: Text.NoWrap
            }

        }

        layer.enabled: albumRadius
        layer.effect: OpacityMask
        {
            maskSource: Item
            {
                width: _cover.width
                height: _cover.height

                Rectangle
                {
                    anchors.fill: parent
                    radius: albumRadius
                }
            }
        }
    }

    Rectangle
    {
        anchors.centerIn: _cover

        width: _image.status === Image.Ready ? Math.min(parent.width, _image.paintedWidth) : parent.width
        height:  _image.status === Image.Ready ? Math.min(parent.height, _image.paintedHeight) : parent.height

        color: "transparent"
        border.color: control.isCurrentItem || control.hovered ? Kirigami.Theme.highlightColor : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.2)
        radius: albumRadius
        opacity: 0.6

        Rectangle
        {
            anchors.fill: parent
            color: "transparent"
            radius: parent.radius - 0.5
            border.color: Qt.lighter(Kirigami.Theme.backgroundColor, 2)
            opacity: 0.8
            anchors.margins: 1
        }
    }
}
