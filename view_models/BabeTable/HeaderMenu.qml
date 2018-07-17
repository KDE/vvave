import QtQuick 2.0
import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.2 as Kirigami

import "../../view_models/BabeMenu"
import "../../utils"
import ".."

BabeMenu
{
    signal saveListClicked()
    signal queueListClicked()
    signal sortClicked()

    property alias menuItem: babeMenu.children

    Column
    {
        id: babeMenu
        MenuItem
        {
            text: "Queue list"
            onTriggered:
            {
                queueListClicked()
                close()
            }
        }

        MenuItem
        {
            text: "Save list to..."
            onTriggered:
            {
                saveListClicked()
                close()
            }
        }

        MenuItem
        {
            text: "Send list to..."
        }

        Kirigami.Separator{ width: parent.width; height: 1}

        MenuItem
        {
            text: "Visible info..."
            onTriggered: {close()}
        }

        Kirigami.Separator{ width: parent.width; height: 1}

        MenuItem
        {
            text: "Sort..."
            onTriggered:
            {
                sortClicked()
                close()
            }
        }

    }
}
