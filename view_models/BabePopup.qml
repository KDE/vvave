import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1
import org.kde.kirigami 2.2 as Kirigami

Popup
{
    property int maxWidth : unit * 200
    property int maxHeight : maxWidth

    parent: ApplicationWindow.overlay

    width: parent ===  ApplicationWindow.overlay ? (root.pageStack.wideMode ?  parent.width * 0.4 :
                                                                              (isMobile ? parent.width * 0.8 :
                                                                                          parent.width * 0.7)) :
                                                   parent.width * 0.7 > maxWidth ? maxWidth :
                                                                                   parent.width * 0.7
    height: parent ===  ApplicationWindow.overlay ? (root.pageStack.wideMode ?  parent.height * 0.5 :
                                                                               (isMobile ? parent.height * 0.8 :
                                                                                           parent.height * 0.7)) :
                                                    parent.height * 0.7 > maxHeight ? maxHeight :
                                                                                      parent.height * 0.7


    x: parent.width / 2 - width / 2
    y: parent.height / 2 - height / 2
    z: 999

    modal: true
    focus: true
    clip: true


    margins: 0
    padding: space.small

    enter: Transition
    {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0;  duration: 150 }
    }

    exit: Transition
    {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
    }

    Material.accent: babeColor
    Material.background: backgroundColor
    Material.primary: backgroundColor
    Material.foreground: textColor

}
