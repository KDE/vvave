import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.10
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.6 as Kirigami
import org.kde.mauikit 1.0 as Maui
import PlaylistsList 1.0
import TracksList 1.0

import "../../utils"

import "../../view_models"
import "../../db/Queries.js" as Q
import "../../utils/Help.js" as H

BabeList
{
    id: control
    holder.emoji: "qrc:/assets/dialog-information.svg"
    holder.title : qsTr("No Playlists!")
    holder.body: qsTr("Start creating new custom playlists")

    Connections
    {
        target: holder
        onActionTriggered: newPlaylistDialog.open()
    }

    Menu
    {
        id: _playlistMenu

        MenuItem
        {
            text: qsTr("Play")
            onTriggered: populate(Q.GET.playlistTracks_.arg(currentPlaylist), true)
        }

        MenuItem
        {
            text: qsTr("Rename")
        }

        MenuSeparator{}

        MenuItem
        {
            text: qsTr("Delete")
            Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
            onTriggered: removePlaylist()
        }
    }


    Maui.BaseModel
    {
        id: _playlistsModel
        list: playlistsList
    }

    model: _playlistsModel

    section.criteria: ViewSection.FullString
    section.property: "type"
    section.delegate: Maui.LabelDelegate
    {
        label: "Personal"
        isSection: true
        width: control.width
    }

    delegate : Maui.ListDelegate
    {
        id: delegate
        width: control.width
        label: model.playlist

        Connections
        {
            target : delegate

            onClicked :
            {
                control.currentIndex = index
                if(Maui.Handy.singleClick)
                {
                    currentPlaylist = playlistsList.get(index).playlist
                    filterList.group = false
                    populate(Q.GET.playlistTracks_.arg(currentPlaylist), true)
                }
            }

            onDoubleClicked :
            {
                control.currentIndex = index
                if(!Maui.Handy.singleClick)
                {
                    currentPlaylist = playlistsList.get(index).playlist
                    filterList.group = false
                    populate(Q.GET.playlistTracks_.arg(currentPlaylist), true)
                }
            }

            onRightClicked:
            {
                control.currentIndex = index
                currentPlaylist = playlistsList.get(index).playlist
                _playlistMenu.popup()
            }

            onPressAndHold:
            {
                control.currentIndex = index
                currentPlaylist = playlistsList.get(index).playlist
                _playlistMenu.popup()
            }
        }
    }

    listView.header: Rectangle
    {
        z: control.z + 999
        width: control.width
        height: 100 + Maui.Style.rowHeight
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        color: Kirigami.Theme.backgroundColor

        ColumnLayout
        {
           anchors.fill: parent

            ListView
            {
                id: _defaultPlaylists
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.margins: Maui.Style.space.medium
                spacing: Maui.Style.space.medium
                orientation :ListView.Horizontal
                model: playlistsList.defaultPlaylists()
                delegate: ItemDelegate
                {
                    id: _delegate
                    readonly property color m_color: modelData.color
                    readonly property string playlist : modelData.playlist

                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.backgroundColor: Qt.rgba(m_color.r, m_color.g, m_color.b, 0.9)
                    Kirigami.Theme.textColor: "white"

                    anchors.verticalCenter: parent.verticalCenter
                    width: 200
                    height:  parent.height  * 0.9

                    background: Rectangle
                    {
                        color : Kirigami.Theme.backgroundColor
                        radius: Maui.Style.radiusV * 2
                        border.color: m_color
                    }

                    Maui.ListItemTemplate
                    {
                        anchors.fill: parent
                        iconSizeHint: Maui.Style.iconSizes.big
                        label1.text: playlist
                        label1.font.pointSize: Maui.Style.fontSizes.big
                        label1.font.weight: Font.Bold
                        label1.font.bold: true
                        label2.text: modelData.description
                        iconSource: modelData.icon
                        iconVisible: true
                    }

                    Connections
                    {
                        target: _delegate

                        onClicked:
                        {
                            _defaultPlaylists.currentIndex = index

                            currentPlaylist = _delegate.playlist
                            switch(currentPlaylist)
                            {
                            case "Most Played":

                                populate(Q.GET.mostPlayedTracks, false);
                                filterList.list.sortBy = Tracks.COUNT
                                break;

                            case "Rating":
                                filterList.list.sortBy = Tracks.RATE
                                filterList.group = true

                                populate(Q.GET.favoriteTracks, false);
                                break;

                            case "Recent":
                                populate(Q.GET.recentTracks, false);
                                filterList.list.sortBy = Tracks.ADDDATE
                                filterList.group = true
                                break;

                            case "Favs":
                                populate(Q.GET.babedTracks, false);
                                break;

                            case "Online":
                                populate(Q.GET.favoriteTracks, false);
                                break;

                            case "Tags":
                                populateExtra(Q.GET.tags, "Tags")
                                break;

                            case "Relationships":
                                populate(Q.GET.favoriteTracks, false);
                                break;

                            case "Popular":
                                populate(Q.GET.favoriteTracks, false);
                                break;

                            case "Genres":
                                populateExtra(Q.GET.genres, "Genres")
                                break;

                            default:
                                break;

                            }
                        }

                    }

                }
            }

            Item
            {
                Layout.fillWidth: true
                Layout.margins: Maui.Style.space.medium
                Layout.preferredHeight:  Maui.Style.rowHeight
                ColorTagsBar
                {
                    anchors.fill: parent
                    onColorClicked: populate(Q.GET.colorTracks_.arg(color.toLowerCase()), true)
                }
            }
        }
    }
}
