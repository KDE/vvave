import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import "../../utils/Help.js" as H
import "../../view_models"
import"../../services/local"

Kirigami.GlobalDrawer
{
    id: settingsView
    handleVisible: false
    signal iconSizeChanged(int size)
    readonly property bool activeBrainz : false /*bae.brainzState()*/
    visible: false

    y: header.height
    height: parent.height - header.height - footer.height
    //    //    width: root.pageStack.wideMode ? views.width -1: root.width
    //    edge: Qt.RightEdge
    //    interactive: true
    //    focus: true
    modal:true
    //    dragMargin :0

    topPadding: 0
    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0

    //    handle.y : 64
    //    handle.anchors.verticalCenter: parent.verticalCenter
    //    handle.anchors.top: parent.bottom
    //    handle.focus: false
    //    handle.y : coverSize
    //handle.parent: ApplicationWindow.overlay


}
