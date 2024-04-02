import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui

import org.maui.vvave

Maui.PopupPage
{
    id: control
    title: i18n("Shortcuts")
    persistent: false
    page.showTitle: false
    headBar.visible: false
    scrollView.padding: 0

    maxHeight: 500 // Copied from Nota. I don't like hardcoded layout, though.
    maxWidth: 350

    Component
    {
        id: _shortcutCategoryComponent
        Maui.SectionGroup
        {
            title: i18n("Unknown")
            function setTitle(rawtext: string)
            {
                this.title = i18n(rawtext)
            }
        }
    }

    Component
    {
        id: _shortcutLabelComponent
        Maui.SectionItem
        {
            label1.text: i18n("Unknown")

            Maui.ToolActions
            {
                id: _actions
                checkable: false
                autoExclusive: false
            }

            function setText(rawtext: string)
            {
                this.label1.text = i18n(rawtext)
            }

            function addKeys(keynames)
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
            console.log("Trying ot push to scollable")
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
