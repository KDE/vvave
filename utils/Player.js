.import org.kde.mauikit 1.0 as Maui

function playTrack(index)
{
    if((index < mainPlaylist.listView.count) && (mainPlaylist.listView.count > 0) && (index > -1))
    {
        prevTrackIndex = currentTrackIndex
        currentTrackIndex = index
        mainPlaylist.listView.currentIndex = currentTrackIndex
        currentTrack = mainPlaylist.listView.itemAtIndex(currentTrackIndex)

        if(typeof(currentTrack) === "undefined") return

        if(!Maui.FM.fileExists(currentTrack.url) && String(currentTrack.url).startsWith("file://"))
        {
            missingAlert(currentTrack)
            return
        }

        player.url = currentTrack.url;
        player.playing = true
    }
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
    root.title = "Babe..."
}

function pauseTrack()
{
    player.playing = false
}

function resumeTrack()
{
    if(!player.play() && !mainlistEmpty)
        playAt(0)
}

function nextTrack()
{
    if(!mainlistEmpty)
    {
        var next = 0
        if(isShuffle && onQueue === 0)
            next = shuffle()
        else
            next = currentTrackIndex+1 >= mainPlaylist.listView.count? 0 : currentTrackIndex+1

        prevTrackIndex = currentTrackIndex
        playAt(next)

        if(onQueue > 0)
        {
            onQueue--
        }
    }
}

function previousTrack()
{
    if(!mainlistEmpty)
    {
        const previous = currentTrackIndex-1 >= 0 ? mainPlaylist.listView.currentIndex-1 : mainPlaylist.listView.count-1
        prevTrackIndex = currentTrackIndex
        playAt(previous)
    }
}

function shuffle()
{
    var pos =  Math.floor(Math.random() * mainPlaylist.listView.count)
    return pos
}

function playAt(index)
{
    if((index < mainPlaylist.listView.count) && (index > -1))
    {
        playTrack(index)
    }
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
            mainPlaylist.list.append(tracks[i], parseInt(at)+parseInt(i))
        }
}

function appendTrack(track)
{
    if(track)
    {
        mainPlaylist.list.append(track)
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
    if(tracks)
    {
        for(var i in tracks)
            appendTrack(tracks[i])

        mainPlaylist.listView.positionViewAtEnd()
    }
}

function savePlaylist()
{
    var list = []
    var n =  mainPlaylist.listView.count
    n = n > 15 ? 15 : n

    for(var i=0 ; i < n; i++)
    {
        var url = mainPlaylist.list.get(i).url
        list.push(url)
    }

    Maui.FM.saveSettings("LASTPLAYLIST", list, "PLAYLIST");
    Maui.FM.saveSettings("PLAYLIST_POS", mainPlaylist.listView.currentIndex, "MAINWINDOW")
}


function clearOutPlaylist()
{
    mainPlaylist.list.clear()
    stop()
}

function cleanPlaylist()
{
    var urls = []

    for(var i = 0; i < mainPlaylist.listView.count; i++)
    {
        var url = mainPlaylist.list.get(i).url

        if(urls.indexOf(url)<0)
            urls.push(url)
        else mainPlaylist.list.remove(i)
    }
}

function playAll(tracks)
{
    sync = false
    syncPlaylist = ""

    mainPlaylist.list.clear()
    appendAll(tracks)

    if(_drawer.modal && !_drawer.visible)
        _drawer.visible = true

    mainPlaylist.listView.positionViewAtBeginning()
    playAt(0)
}
