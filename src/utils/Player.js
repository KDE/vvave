function playTrack()
{
    player.url = currentTrack.url;
    player.play()
}

function queueTracks(tracks)
{
    if(tracks && tracks.length > 0)
    {
        appendTracksAt(tracks, currentTrackIndex+onQueue+1)
        root.notify("", "Queue", tracks.length + " tracks added put on queue")
        onQueue++
    }
}

function setLyrics(lyrics)
{
    currentTrack.lyrics = lyrics
    infoView.lyricsText.text = lyrics
}

function stop()
{
    player.stop()
    progressBar.value = 0
    progressBar.enabled = false
}

function nextTrack()
{
   playlist.next()
}

function previousTrack()
{
   playlist.previous()
}

function playAt(index)
{
    playlist.currentIndex = index
}

function quickPlay(track)
{
    //    root.pageStack.currentIndex = 0
    appendTrack(track)
    playAt(mainPlaylist.listView.count-1)
    mainPlaylist.listView.positionViewAtEnd()
}

function appendTracksAt(tracks, at)
{
    if(tracks)
        for(var i in tracks)
        {
            mainPlaylist.listModel.list.appendAt(tracks[i], parseInt(at)+parseInt(i))
        }
}

function appendTrack(track)
{
    if(track)
    {
        playlist.append(track)
        if(sync === true)
        {
           playlistsList.addTrack(syncPlaylist, [track.url])
        }
    }
}

function addTrack(track)
{
    if(track)
    {
        appendTrack(track)
        mainPlaylist.listView.positionViewAtEnd()
    }
}

function appendAll(tracks)
{
    for(var track of tracks)
        appendTrack(track)

    mainPlaylist.listView.positionViewAtEnd()
}

function savePlaylist()
{
   playlist.save()
}

function playAll(tracks)
{
    sync = false
    syncPlaylist = ""

    playlist.clear()
    appendAll(tracks)

    if(_drawer.modal && !_drawer.visible)
        _drawer.visible = true

    mainPlaylist.listView.positionViewAtBeginning()
    playAt(0)
}

function appendAllModel(model)
{
   mainPlaylist.listModel.list.copy(model)
   mainPlaylist.listView.positionViewAtEnd()
}


function playAllModel(model)
{
    sync = false
    syncPlaylist = ""

    playlist.clear()
    appendAllModel(model)

    if(_drawer.modal && !_drawer.visible)
        _drawer.visible = true

    mainPlaylist.listView.positionViewAtBeginning()
    playAt(0)
}
