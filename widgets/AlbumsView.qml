import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3

import "../view_models/BabeGrid"
import "../view_models/BabeTable"

import "../db/Queries.js" as Q
import "../utils/Help.js" as H
import "../utils/Player.js" as Player

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.maui.vvave 1.0

StackView
{
    id: control
    clip: true

    property alias list : albumsViewGrid.list

    property string currentAlbum: ""
    property string currentArtist: ""

    property var tracks: []

    property alias holder: albumsViewGrid.holder

    signal rowClicked(var track)
    signal playTrack(var track)
    signal queueTrack(var track)
    signal appendTrack(var track)

    signal albumCoverPressedAndHold(string album, string artist)

    property Flickable flickable : currentItem.flickable

    initialItem: BabeGrid
    {
        id: albumsViewGrid
        onAlbumCoverPressed: albumCoverPressedAndHold(album, artist)
        onAlbumCoverClicked: control.populateTable(album, artist)
    }

  Component
  {
      id: _tracksTableComponent

      BabeTable
      {
          trackNumberVisible: true
          coverArtVisible: true
          focus: true
          holder.emoji: "qrc:/assets/media-album-track.svg"
          holder.title : "Oops!"
          holder.body: i18n("This list is empty")
          holder.emojiSize: Maui.Style.iconSizes.huge
          headBar.visible: true
          headBar.farLeftContent: ToolButton
          {
              icon.name: "go-previous"
              onClicked: control.pop()
          }

          onRowClicked:
          {
              control.rowClicked(listModel.get(index))
          }

          onQuickPlayTrack:
          {
              control.playTrack(listModel.get(index))
          }

          onQueueTrack:
          {
              control.queueTrack(listModel.get(index))
          }

          onAppendTrack:
          {
              control.appendTrack(listModel.get(index))
          }

          onPlayAll:
          {
              control.pop()
              Player.playAll(listModel.list.getAll())
          }

          onAppendAll:
          {
              control.pop()
              Player.appendAll(listModel.list.getAll())
          }

          Component.onCompleted:
          {
              var query
              if(currentAlbum && currentArtist)
              {
                  query = Q.GET.albumTracks_.arg(currentAlbum)
                  query = query.arg(currentArtist)

              }else if(currentArtist && !currentAlbum.length)
              {
                  query = Q.GET.artistTracks_.arg(currentArtist)
              }

              listModel.list.query = query
          }
      }
  }

    function populateTable(album, artist)
    {
        currentAlbum = album === undefined ? "" : album
        currentArtist= artist

        control.push(_tracksTableComponent)
    }
}

