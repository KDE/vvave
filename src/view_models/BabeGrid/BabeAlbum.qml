import QtQuick 2.14
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.vvave 1.0

Maui.GridBrowserDelegate
{
    id: control

// template.labelsVisible : label1.text.length || label2.text.length

// label1.visible: label1.text && control.width > 50
 label1.font.bold: true
 label1.font.weight: Font.Bold
 iconSource: "media-album-cover"
 template.labelSizeHint: 40

// label2.visible: label2.text && (control.width > 70)
// label2.font.pointSize: Maui.Style.fontSizes.medium
// label2.wrapMode: Text.NoWrap

//template.fillMode: Image.PreserveAspectFit

}
