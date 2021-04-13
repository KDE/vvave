import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

import org.maui.vvave 1.0

import "../../view_models/BabeTable"
import "../../view_models/BabeGrid"
import "../../utils/Player.js" as Player

Maui.Page
{
    id: control
    property alias list : _cloudList

    headBar.visible: !_listView.holder.visible

    headBar.leftContent: Maui.ToolActions
    {
        expanded: isWide
        enabled: listModel.list.count > 0
        checkable: false
        autoExclusive: false
        display: ToolButton.TextBesideIcon
        defaultIconName: "media-playback-start"

        Action
        {
            icon.name : "media-playlist-play"
            text: i18n("Play")
//            onTriggered: playAll()
        }

        Action
        {
            icon.name : "media-playlist-append"
            text: i18n("Append")
//            onTriggered: appendAll()
        }
    }

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        placeholderText: i18n("Filter")
        onAccepted: _cloudModel.filter = text
        onCleared: _cloudModel.filter = ""
    }

    Maui.ListBrowser
    {
        id: _listView
        anchors.fill: parent
        holder.visible: count === 0
        holder.emoji: "qrc:/assets/dialog-information.svg"
        holder.title : i18n("Opps!")
        holder.body: i18n("You don't have an account set up.\nYou can set up your account now by clicking here or under the Accounts options in the main menu")

        Connections
        {
            target: _listView.holder
            function onActionTriggered()
            {
                if(root.accounts)
                    root.accounts.open()
            }
        }

        model: Maui.BaseModel
        {
            id: _cloudModel
            list: Cloud
            {
                id: _cloudList

                onFileReady: Player.addTrack(track)
            }
        }

        section.property: "artist"
        section.criteria: ViewSection.FullString
        section.delegate: Item
        {
            width: ListView.view.width
            implicitHeight: Maui.Style.rowHeight*2.5

            Rectangle
            {
                color: Qt.tint(control.Kirigami.Theme.textColor, Qt.rgba(control.Kirigami.Theme.backgroundColor.r, control.Kirigami.Theme.backgroundColor.g, control.Kirigami.Theme.backgroundColor.b, 0.9))
                anchors.centerIn: parent
                width: parent.width
                height: Maui.Style.rowHeight * 1.5

                radius: Maui.Style.radiusV

                Maui.ListItemTemplate
                {
                    anchors.centerIn:  parent
                    label1.text: String(section)

                    label1.font.pointSize: Maui.Style.fontSizes.big
                    label1.font.bold: true
                    width: parent.width
                    imageSizeHint: height * 0.7
                    maskRadius: height/2
                    imageBorder: false

                    imageSource: "image://artwork/artist:"+ String(section)
                }
            }
        }

        flickable.header: Rectangle
        {
            width: parent.width
            height: 150
            color: Kirigami.Theme.backgroundColor
            visible: _headList.count > 0

            ListView
            {
                id: _headList
                anchors.fill: parent
                anchors.margins: Maui.Style.space.medium
                spacing: Maui.Style.space.medium
                orientation: ListView.Horizontal

                model: list.artists

                delegate: BabeAlbum
                {
                    height: 120
                    width: height
                    albumRadius: Maui.Style.radiusV
                    isCurrentItem: ListView.isCurrentItem
                    anchors.verticalCenter: parent.verticalCenter
                    showLabels: true
                    label1.text: modelData.artist
                    image.source: "image://artwork/artist:"+ modelData.artist
                }
            }
        }

        flickable.headerPositioning: ListView.PullBackHeader

        delegate: TableDelegate
        {
            id: delegate
            width: parent.width
            number :  false
            coverArt : false

            ToolButton
            {
                icon.name: "document-download"
                Layout.fillHeight: true
            }

            onClicked:
            {
                _listView.currentIndex = index
                //                if(selectionMode)
                //                {
                //                    H.addToSelection(control.list.get(_listView.currentIndex))
                //                    return
                //                }

                list.getFileUrl(index);

                //                if(isMobile)
                //                    rowClicked(index)

            }

            //            onDoubleClicked:
            //            {
            //                currentIndex = index
            //                if(!isMobile)
            //                    rowClicked(index)
            //            }

            //            onPlay:
            //            {
            //                currentIndex = index
            //                if(FB.FM.fileExists("file://" + _cloudList.get(index).thumbnail))
            //                {
            //                    quickPlayTrack(index)
            //                }else
            //                {
            //                    _cloudList.requestFile(index)
            //                }
            //            }

            //            onArtworkCoverClicked:
            //            {
            //                currentIndex = index
            //                goToAlbum()
            //            }
        }

    }

}
