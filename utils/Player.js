function playTrack(track)
{
    currentTrack = track
    player.source(currentTrack.url);
    player.play()
    root.title = currentTrack.title + " - " +currentTrack.artist
    currentArtwork = con.getAlbumArt(currentTrack.album, currentTrack.artist) || con.getArtistArt(currentTrack.artist)
    playIcon.text= MdiFont.Icon.pause

}

function pauseTrack()
{
    player.pause()
    playIcon.text= MdiFont.Icon.play

}

function resumeTrack()
{
    player.play()
}

function nextTrack()
{
    var next = mainPlaylistTable.currentIndex+1 >= mainPlaylistTable.count? 0 : mainPlaylistTable.currentIndex+1
    mainPlaylistTable.currentIndex = next
    playTrack(mainPlaylistTable.model.get(next))
}

function previousTrack()
{
    var previous = mainPlaylistTable.currentIndex-1 >= 0 ? mainPlaylistTable.currentIndex-1 : mainPlaylistTable.count-1
    mainPlaylistTable.currentIndex = previous
    playTrack(mainPlaylistTable.model.get(previous))
}
