import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Material 2.1

import org.kde.kirigami 2.2 as Kirigami
import "../utils/Player.js" as Player

ApplicationWindow
{
    id: root
    visible: true
    width: 500
    height: 600
    property string trackUrl : "/home/camilo/Music/Aimee-Mann-I'm With-Stupid/07-Aimee-Mann-All-Over-Now.mp3"
    property var currentTrack : ({})

    Button
    {
        anchors.centerIn: parent
        width: 60
        height: 48
        text: "Play"
        onClicked: Player.playTrack({url: trackUrl})
    }

}
