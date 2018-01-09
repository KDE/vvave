function playTrack(track)
{
    currentTrack = track
    player.source(currentTrack.url);
    player.play()
    root.title = currentTrack.title + " - " +currentTrack.artist
    currentArtwork = con.getAlbumArt(currentTrack.album, currentTrack.artist) || con.getArtistArt(currentTrack.artist)

}

function pauseTrack()
{
    player.pause()
}

function resumeTrack()
{
    player.play()
}

function nextTrack()
{
    var next

    if(shuffle)
        next = shuffle()
    else
        next = mainPlaylistTable.currentIndex+1 >= mainPlaylistTable.count? 0 : mainPlaylistTable.currentIndex+1

    mainPlaylistTable.currentIndex = next
    playTrack(mainPlaylistTable.model.get(next))
}

function previousTrack()
{
    var previous = mainPlaylistTable.currentIndex-1 >= 0 ? mainPlaylistTable.currentIndex-1 : mainPlaylistTable.count-1
    mainPlaylistTable.currentIndex = previous
    playTrack(mainPlaylistTable.model.get(previous))
}


function shuffle()
{
    var pos =  Math.floor(Math.random() * mainPlaylistTable.count)
    return pos
}

function savePlaylist()
{
    var list = []
    var n =  mainPlaylistTable.count
    for(var i=0 ; i<n; i++)
    {
        var url = mainPlaylistTable.model.get(i).url
        list.push(url)
    }
    util.savePlaylist(list)
}

function savePlaylistPos()
{
    util.savePlaylistPos(mainPlaylistTable.currentIndex)
}
