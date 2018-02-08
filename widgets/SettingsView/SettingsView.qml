import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami



Kirigami.GlobalDrawer
{
    id: settingsView
    handleVisible: true
    signal iconSizeChanged(int size)
    readonly property bool activeBrainz : bae.brainzState()

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
                text: checked ? "ON" : "OFF"
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
                    text: "16"
                    onTriggered :
                    {
                        bae.saveSetting("ICON_SIZE", text, "BABE")
                        iconSizeChanged(text)
                    }
                }

                Kirigami.Action
                {
                    text: isMobile ? "24" : "22"
                    onTriggered :
                    {
                        bae.saveSetting("ICON_SIZE", text, "BABE")
                        iconSizeChanged(text)
                    }
                }

                Kirigami.Action
                {
                    text: "32"
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
                text: "Time labels"

                Kirigami.Action
                {
                    text: checked ? "ON" : "OFF"
                    checked: timeLabels
                    checkable: true
                    onToggled:
                    {
                        //                    bae.saveSetting("BRAINZ", checked === true ? true : false, "BABE")
                        timeLabels = checked
                    }
                }
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
