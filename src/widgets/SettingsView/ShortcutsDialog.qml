import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.2 as Maui

import org.maui.vvave 1.0

Maui.SettingsDialog
{

    id: control
    title: i18n("Shortcuts")
    persistent: false
    page.showTitle: false
    headBar.visible: false
    maxHeight: 500 // Copied from Nota. I don't like hardcoded layout, though.
    maxWidth: 350

    Component
    {
        id: _shortcutCategoryComponent
        Maui.SettingsSection {
            title: i18n("Unknown")
            function setTitle(rawtext: string) : undefined
            {
                this.title = i18n(rawtext)
            }
        }
    }

    Component
    {
        id: _shortcutLabelComponent
        Maui.SettingTemplate
        {
            label1.text: i18n("Unknown")

            Maui.ToolActions
            {
                id: _actions
                checkable: false
                autoExclusive: false
            }

            function setText(rawtext: string) : undefined
            {
                this.label1.text = i18n(rawtext)
            }

            function addKeys(keynames: array<string>) : undefined
            {
                for (let name of keynames) {
                    _actions.actions.push(
                        _shortcutComboComponent.createObject(
                            _actions,
                            {text: name} // (Probably no `i18n`?)
                        )
                    )
                }
            }
        }
    }

    Component
    {
        id: _shortcutComboComponent
        Action {}
    }

    Component.onCompleted: {
        let categories = []
        let category_shortcuts = {}
        for (let i = 0; i < shortcuts.length; i++) {
            let sc = shortcuts[i]
            if (!(sc.dialogCategory in category_shortcuts)) {
                categories.push(sc.dialogCategory)
                category_shortcuts[sc.dialogCategory] = []
            }
            category_shortcuts[sc.dialogCategory].push({
                label: sc.dialogLabel,
                // combo: sc.nativeText.split(/(?<=[^\+])\+|\+(?=[^\+])/)
                combo: sc.nativeText
                    .split("+")
                    .map((key) => key == "" ? "+" : key)
                    .join("\n")
                    .replace(/\+\n\+/g, "+")
                    .split("\n")
                // Split on "+" but try to handle shortcuts that include a literal [+] key.
                // QML doesn't like lookbehinds, so we get this chain.
            })
        }

        for (let category of categories) {
            let section = _shortcutCategoryComponent.createObject(control)
            scrollable.push(section)
            section.setTitle(category)
            for (let shortcut of category_shortcuts[category]) {
                let label = _shortcutLabelComponent.createObject(section)
                section.content.push(label)
                label.setText(shortcut.label)
                label.addKeys(shortcut.combo)
            }
        }

    }
}
