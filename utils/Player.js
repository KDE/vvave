Qt.include("Icons.js")


function playTrack(track)
{
    root.mainPlaylist.currentTrack = track
    player.source(root.mainPlaylist.currentTrack.url);
    player.play()
    root.title = root.mainPlaylist.currentTrack.title + " - " +root.mainPlaylist.currentTrack.artist
    root.mainPlaylist.currentArtwork = root.mainPlaylist.currentTrack.artwork || bae.loadCover(root.mainPlaylist.currentTrack.url)

    root.mainPlaylist.playIcon.text = Icon.pause

    if(bae.trackBabe(root.mainPlaylist.currentTrack.url))
        root.mainPlaylist.babeBtnIcon.color = bae.babeColor()
    else
        root.mainPlaylist.babeBtnIcon.color = root.mainPlaylist.babeBtnIcon.defaultColor

    var lyrics = root.mainPlaylist.currentTrack.lyrics

    if(!lyrics)
        bae.trackLyrics(root.mainPlaylist.currentTrack.url)
    else
        root.mainPlaylist.infoView.lyrics =  lyrics

    root.mainPlaylist.infoView.wikiAlbum = bae.albumWiki(root.mainPlaylist.currentTrack.album,root.mainPlaylist.currentTrack.artist)
    root.mainPlaylist.infoView.wikiArtist = bae.artistWiki(root.mainPlaylist.currentTrack.artist)
    //    root.mainPlaylist.infoView.artistHead = bae.artistArt(root.mainPlaylist.currentTrack.artist)

}


function stop()
{
    player.stop()
    root.mainPlaylist.progressBar.value = 0
    root.mainPlaylist.cover.visible = false
    root.title = "Babe..."
    root.mainPlaylist.playIcon.text = Icon.play
}

function pauseTrack()
{
    player.pause()
    root.mainPlaylist.playIcon.text = Icon.play
}

function resumeTrack()
{
    player.play()
    root.mainPlaylist.playIcon.text = Icon.pause
}

function nextTrack()
{
    var next = 0
    if(root.mainPlaylist.shuffle)
        next = shuffle()
    else
        next = root.mainPlaylist.list.currentIndex+1 >= root.mainPlaylist.list.count? 0 : root.mainPlaylist.list.currentIndex+1

    root.mainPlaylist.list.currentIndex = next
    playTrack(root.mainPlaylist.list.model.get(next))
}

function previousTrack()
{
    var previous = root.mainPlaylist.list.currentIndex-1 >= 0 ? root.mainPlaylist.list.currentIndex-1 : root.mainPlaylist.list.count-1
    root.mainPlaylist.list.currentIndex = previous
    playTrack(root.mainPlaylist.list.model.get(previous))
}


function shuffle()
{
    var pos =  Math.floor(Math.random() * root.mainPlaylist.list.count)
    return pos
}

function playAt(index)
{
    if(index < root.mainPlaylist.list.count)
    {
        root.mainPlaylist.list.currentIndex = index
        playTrack(root.mainPlaylist.list.model.get(index))
    }
}

function quickPlay(track)
{
    root.currentView = 0
    appendTrack(track)
    playAt(root.mainPlaylist.list.count-1)
    root.mainPlaylist.list.positionViewAtEnd()

}

function appendTrack(track)
{
    var empty = root.mainPlaylist.list.count
    root.mainPlaylist.list.model.append(track)

    if(empty === 0 && root.mainPlaylist.list.count>0)
    {
        root.mainPlaylist.list.currentIndex = 0
        playTrack(root.mainPlaylist.list.model.get(0))
    }
}

function addTrack(track)
{
    appendTrack(track)
    root.mainPlaylist.list.positionViewAtEnd()
}

function appendAlbum(tracks)
{
    for(var i in tracks)
        appendTrack(tracks[i])
    root.mainPlaylist.list.positionViewAtEnd()
}

function savePlaylist()
{
    var list = []
    var n =  root.mainPlaylist.list.count
    for(var i=0 ; i<n; i++)
    {
        var url = root.mainPlaylist.list.model.get(i).url
        list.push(url)
    }
    bae.savePlaylist(list)
    bae.savePlaylistPos(root.mainPlaylist.list.currentIndex)
}

function clearOutPlaylist()
{
    root.mainPlaylist.list.clearTable()
    stop()
}

function cleanPlaylist()
{
    var urls = []

    for(var i = 0; i < root.mainPlaylist.list.count; i++)
    {
        var url = root.mainPlaylist.list.model.get(i).url

        if(urls.indexOf(url)<0)
            urls.push(url)
        else root.mainPlaylist.list.model.remove(i)
    }
}

function playAlbum(tracks)
{
    root.mainPlaylist.list.clearTable()
    root.currentView = 0

    for(var i = 0; i< tracks.length; i++)
        appendTrack(tracks[i])

    //    root.mainPlaylist.list.currentIndex = 0
    //    playTrack(root.mainPlaylist.list.model.get(0))

    root.mainPlaylist.list.positionViewAtBeginning()

}

function babeTrack()
{
    if(bae.trackBabe(root.mainPlaylist.currentTrack.url))
    {
        bae.babeTrack(root.mainPlaylist.currentTrack.url, false)
        root.mainPlaylist.babeBtnIcon.text = Icon.heartOutline
        root.mainPlaylist.babeBtnIcon.color = root.mainPlaylist.babeBtnIcon.defaultColor

    }else
    {
        bae.babeTrack(root.mainPlaylist.currentTrack.url, true)
        root.mainPlaylist.babeBtnIcon.text = Icon.heartOutline
        root.mainPlaylist.babeBtnIcon.color = "#E91E63"
    }
}
