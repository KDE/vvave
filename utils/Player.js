Qt.include("Icons.js")


function playTrack(track)
{
    root.currentTrack = track
    player.source(currentTrack.url);
    player.play()
    root.title = currentTrack.title + " - " +currentTrack.artist
    currentArtwork = con.getAlbumArt(currentTrack.album, currentTrack.artist) || con.getArtistArt(currentTrack.artist)

    playIcon.text = Icon.pause

    if(con.getTrackBabe(currentTrack.url))
        babeBtnIcon.color = "#E91E63"
    else
        babeBtnIcon.color = babeBtnIcon.defaultColor

}

function stop()
{
    player.stop()
    progressBar.value = 0
    coverPlay.visible = false
    root.title = "Babe..."
    playIcon.text = Icon.play
}

function pauseTrack()
{
    player.pause()
    playIcon.text = Icon.play
}

function resumeTrack()
{
    player.play()
    playIcon.text = Icon.pause
}

function nextTrack()
{
    var next
    console.log("shuffle<<", root.shuffle)
    if(root.shuffle)
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


function appendTrack(track)
{

    var empty = mainPlaylistTable.count
    mainPlaylistTable.model.append(track)
    mainPlaylistTable.positionViewAtEnd()

    if(empty === 0 && mainPlaylistTable.count>0)
    {
        mainPlaylistTable.currentIndex = 0
        playTrack(mainPlaylistTable.model.get(0))
    }

}

function appendAlbum(tracks)
{
    for(var i in tracks)
        appendTrack(tracks[i])
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


function clearOutPlaylist()
{
    mainPlaylistTable.clearTable()
    stop()
}

function cleanPlaylist()
{
    var urls = []

    for(var i = 0; i < mainPlaylistTable.count; i++)
    {
        var url = mainPlaylistTable.model.get(i).url

        if(urls.indexOf(url)<0)
            urls.push(url)
        else mainPlaylistTable.model.remove(i)
    }
}

function playAlbum(tracks)
{
    mainPlaylistTable.clearTable()
    for(var i in tracks)
        appendTrack(tracks[i])

    mainPlaylistTable.currentIndex = 0
    playTrack(mainPlaylistTable.model.get(0))

    root.currentView = 0
}

function babeTrack()
{
    if(con.getTrackBabe(root.currentTrack.url))
    {
        con.babeTrack(root.currentTrack.url, false)
        babeBtnIcon.text = Icon.heartOutline
        babeBtnIcon.color = babeBtnIcon.defaultColor

    }else
    {
        con.babeTrack(root.currentTrack.url, true)
        babeBtnIcon.text = Icon.heartOutline
        babeBtnIcon.color = "#E91E63"
    }
}
