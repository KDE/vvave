.import org.mauikit.filebrowsing as FB

.import org.maui.vvave as Vvave

function playTrack()
{
    player.url = currentTrack.url ? currentTrack.url : "";
    player.play()
}

function queueTracks(tracks)
{
    if(tracks && tracks.length > 0)
    {
        appendTracksAt(tracks, currentTrackIndex+1)
        // root.notify("", "Queue", tracks.length + " tracks added put on queue")
        // This freezes the whole UI. It should probably be a toast popup instead.
        // Something similar AbstractApplicationWindow::showPassiveNotification() from Kirigami would be less flow-breaking.
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
}

function changeCurrentIndex(index)
{
    root.playlistManager.changeCurrentIndex(index)
}

function nextTrack()
{
    root.playlistManager.next()
}

function previousTrack()
{
    root.playlistManager.previous()
}

function playAt(index)
{
    root.playlistManager.play(index)
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
    for(var i in tracks)
    {
        mainPlaylist.listModel.list.appendAt(tracks[i], parseInt(at)+parseInt(i))
    }
}

function appendUrls(urls)
{
    mainPlaylist.listModel.list.appendUrls(urls)
}

function appendUrlsAt(urls, at)
{
    mainPlaylist.listModel.list.insertUrls(urls, at)
}

function appendTrack(track)
{
    if(track)
    {
        root.playlistManager.append(track)
        if(sync === true)
        {
            FB.Tagging.tagUrl(track.url, syncPlaylist)
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

function playAll(tracks)
{
    sync = false
    syncPlaylist = ""

    root.playlistManager.clear()
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

    if (model.count > 1 && root.playlistManager.playMode == Vvave.Playlist.Shuffle)
        root.playlistManager.shuffleRange(
            mainPlaylist.listView.count - model.count,
            mainPlaylist.listView.count
        )
}

function playQuery(query)
{
    const tracks = Vvave.Vvave.getTracks(query)
    playAll(tracks)
}

function playAllModel(model)
{
    sync = false
    syncPlaylist = ""

    root.playlistManager.clear()
    appendAllModel(model)

    if(_drawer.modal && !_drawer.visible)
        _drawer.visible = true

    mainPlaylist.listView.positionViewAtBeginning()
    playAt(0)
}

function shuffleAllModel(model)
{
    sync = false
    syncPlaylist = ""

    root.playlistManager.clear()
    appendAllModel(model)

    if(_drawer.modal && !_drawer.visible)
        _drawer.visible = true

    mainPlaylist.listView.positionViewAtBeginning()
    root.playlistManager.playMode = Vvave.Playlist.Shuffle
    playAt(0)
}
