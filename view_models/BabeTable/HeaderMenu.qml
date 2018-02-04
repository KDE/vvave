import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../view_models/BabeMenu"
import "../../utils"
import ".."

BabeMenu
{
    signal saveListClicked();

    property alias menuItem: babeMenu.children


    Column
    {
        id: babeMenu
        BabeMenuItem
        {
            text: "Queue list"
            onTriggered: {}
        }

        BabeMenuItem
        {
            text: "Save list to..."
            onTriggered: saveListClicked()
        }

        BabeMenuItem
        {
            text: "Send list to..."
            onTriggered: {}
        }
    }
}
