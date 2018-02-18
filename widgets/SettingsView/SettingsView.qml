import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami

Kirigami.GlobalDrawer
{
    id: settingsView
    handleVisible: false
    signal iconSizeChanged(int size)
    readonly property bool activeBrainz : bae.brainzState()
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
    function scanDir(folderUrl)
    {
        bae.scanDir(folderUrl)
    }

    SourcesDialog
    {
        id: sourcesDialog
    }

    BabeConsole
    {
        id: babeConsole
    }

    bannerImageSource: "qrc:/assets/banner.svg"

    actions: [

        Kirigami.Action
        {
            text: "Sources"
            onTriggered: sourcesDialog.open()
        },

        Kirigami.Action
        {
            text: "Brainz"

            Kirigami.Action
            {
                id: brainzToggle
                text: checked ? "Turn OFF" : "Turn ON"
                checked: activeBrainz
                checkable: true
                onToggled:
                {
                    bae.saveSetting("BRAINZ", checked === true ? true : false, "BABE")
                    bae.brainz(checked === true ? true : false)
                }
            }
        },

        Kirigami.Action
        {
            text: "Appearance"

            Kirigami.Action
            {
                text: "Icon size"
                Kirigami.Action
                {
                    text: iconSizes.small
                    onTriggered :
                    {
                        bae.saveSetting("ICON_SIZE", text, "BABE")
                        iconSizeChanged(text)
                    }
                }

                Kirigami.Action
                {
                    text: iconSizes.medium
                    onTriggered :
                    {
                        bae.saveSetting("ICON_SIZE", text, "BABE")
                        iconSizeChanged(text)
                    }
                }

                Kirigami.Action
                {
                    text: iconSizes.big
                    onTriggered :
                    {
                        bae.saveSetting("ICON_SIZE", text, "BABE")
                        iconSizeChanged(text)
                    }
                }
            }

            Kirigami.Action
            {
                text: "Theme"
                visible: isMobile
                Kirigami.Action
                {
                    text: "Light"
                    onTriggered : switchColorScheme("Light")
                }

                Kirigami.Action
                {
                    text: "Dark"
                    onTriggered : switchColorScheme("Dark")
                }

                Kirigami.Action
                {
                    text: "Breeze"
                    onTriggered : switchColorScheme("Breeze")
                }
            }
        },

        Kirigami.Action
        {
            text: "Player"

            Kirigami.Action
            {
                text: "Info label"

                Kirigami.Action
                {
                    text: checked ? "ON" : "OFF"
                    checked: infoLabels
                    checkable: true
                    onToggled:
                    {
                        infoLabels = checked
                        bae.saveSetting("PLAYBACKINFO", infoLabels ? true : false, "BABE")

                    }
                }
            }

            Kirigami.Action
            {
                text: "Autoplay"
                checked: autoplay
                checkable: true
                onToggled:
                {
                    autoplay = checked
                    bae.saveSetting("AUTOPLAY", autoplay ? true : false, "BABE")
                }

            }
        },

        Kirigami.Action
        {
            text: "Developer"

            Kirigami.Action
            {
                text: "Wiki"
            }

            Kirigami.Action
            {
                text: "Console log"
                onTriggered: babeConsole.open()
            }
        },

        Kirigami.Action
        {
            text: "About Babe"
        },

        Kirigami.Action
        {
            text: "About Beats"
        }


    ]

    function switchColorScheme(variant)
    {
        bae.saveSetting("THEME", variant, "BABE")

        if(variant === "Light")
        {
            backgroundColor = lightBackgroundColor
            foregroundColor = lightForegroundColor
            textColor = lightTextColor
            babeHighlightColor = lightBabeHighlightColor
            highlightTextColor = lightHighlightTextColor
            midColor = lightMidColor
            midLightColor = lightMidLightColor
            darkColor = lightDarkColor
            baseColor = lightBaseColor
            altColor = lightAltColor
            shadowColor = lightShadowColor

        }else if(variant === "Dark")
        {
            backgroundColor = darkBackgroundColor
            foregroundColor = darkForegroundColor
            textColor = darkTextColor
            babeHighlightColor = darkBabeHighlightColor
            highlightTextColor = darkHighlightTextColor
            midColor = darkMidColor
            midLightColor = darkMidLightColor
            darkColor = darkDarkColor
            baseColor = darkBaseColor
            altColor = darkAltColor
            shadowColor = darkShadowColor

        }else if (variant === "Breeze")
        {
            backgroundColor = bae.backgroundColor()
            foregroundColor = bae.foregroundColor()
            textColor = bae.textColor()
            babeHighlightColor = bae.highlightColor()
            highlightTextColor = bae.highlightTextColor()
            midColor = bae.midColor()
            midLightColor = bae.midLightColor()
            darkColor = bae.darkColor()
            baseColor = bae.baseColor()
            altColor = bae.altColor()
            shadowColor = bae.shadowColor()
        }
    }
}
