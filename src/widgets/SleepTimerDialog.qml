import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui

Maui.PopupPage
{
    id: control

    title: i18n("Sleep Timer")

    component OptionEntry : CheckBox
    {
        Layout.fillWidth: true
        checkable: true
        autoExclusive: true
    }

    property string option : "none"


    ButtonGroup
    {
        id: _group
    }

    OptionEntry
    {
        ButtonGroup.group: _group
        text: i18n("15 minutes")
        onToggled: () =>
                   {
                       if(checked)
                       {
                           control.option = "15m"
                       }else
                       {
                           control.option = "none"
                       }
                   }
    }

    OptionEntry
    {
        ButtonGroup.group: _group
        text: i18n("30 minutes")
        onToggled: () =>
                   {
                       if(checked)
                       {
                           control.option = "30m"
                       }else
                       {
                           control.option = "none"
                       }
                   }
    }

    OptionEntry
    {
        ButtonGroup.group: _group
        text: i18n("1 hour")
        onToggled: () =>
                   {
                       if(checked)
                       {
                           control.option = "60m"
                       }else
                       {
                           control.option = "none"
                       }
                   }
    }

    OptionEntry
    {
        ButtonGroup.group: _group
        text: i18n("End of track")
        onToggled: () =>
                   {
                       if(checked)
                       {
                           control.option = "eot"
                       }else
                       {
                           control.option = "none"
                       }
                   }
    }

    OptionEntry
    {
        ButtonGroup.group: _group
        text: i18n("End of playlist")
        onToggled: () =>
                   {
                       if(checked)
                       {
                           control.option = "eop"
                       }else
                       {
                           control.option = "none"
                       }
                   }
    }

    OptionEntry
    {
        ButtonGroup.group: _group
        text: i18n("Off")
        checked: true
        onToggled: () =>
                   {
                       if(checked)
                       {
                           control.option = "none"
                       }else
                       {
                           control.option = "none"
                       }
                   }
    }

    MenuSeparator
    {

    }

    CheckBox
    {
        enabled: control.option !== "none"
        Layout.fillWidth: true
        text: i18n("Close application after")
        onToggled: closeAfterSleep = checked
    }


    actions: [
        Action
        {
            text: i18n("Cancel")
            onTriggered: control.close()
        },

        Action
        {
            text: i18n("Accept")
            onTriggered:
            {
                setSleepTimer(control.option)
                control.close()
            }
        }
    ]
}
