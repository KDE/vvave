function playTrack(track)
{
    currentTrack = track
    player.source(currentTrack.url);
    player.play()
    root.title = currentTrack.title + " - " +currentTrack.artist

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
