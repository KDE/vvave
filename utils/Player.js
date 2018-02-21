Qt.include("Icons.js")


function playTrack(track)
{
    if(track)
    {
        currentTrack = track

        if(bae.fileExists(currentTrack.url))
        {
            player.source(currentTrack.url);
            player.play()

            //            root.playIcon.iconName = "media-playback-pause"

            var artwork = currentTrack.artwork
            //    root.mainPlaylist.list.currentItem.playingIndicator = true
            currentArtwork = artwork && artwork.length>0 && artwork !== "NONE" ? artwork : bae.loadCover(currentTrack.url)

            currentBabe = bae.trackBabe(currentTrack.url)

            progressBar.enabled = true

            if(!isMobile)
            {
                title = currentTrack.title + " - " +currentTrack.artist

                if(!root.active)
                    bae.notifySong(currentTrack.url)
            }

            bae.trackLyrics(currentTrack.url)

            //    root.mainPlaylist.infoView.wikiAlbum = bae.albumWiki(root.mainPlaylist.currentTrack.album,root.mainPlaylist.currentTrack.artist)
            //    root.mainPlaylist.infoView.wikiArtist = bae.artistWiki(root.mainPlaylist.currentTrack.artist)
            //    //    root.mainPlaylist.infoView.artistHead = bae.artistArt(root.mainPlaylist.currentTrack.artist)
        }else root.missingAlert(currentTrack)
    }
}

function queueTracks(tracks)
{
    if(tracks)
    {
        if(tracks.length > 0)
        {
            onQueue++
            console.log(onQueue)
            appendTracksAt(tracks, currentTrackIndex+1)
            if(!isMobile)
                bae.notify("Queue", tracks.length + " tracks added put on queue")
        }
    }
}

function setLyrics(lyrics)
{
    currentTrack.lyrics = lyrics
    root.mainPlaylist.infoView.lyricsText.text = lyrics
}

function stop()
{
    player.stop()
    root.progressBar.value = 0
    root.progressBar.enabled = false
    root.title = "Babe..."
}

function pauseTrack()
{
    player.pause()
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
        if(root.shuffle && onQueue === 0)
            next = shuffle()
        else
            next = currentTrackIndex+1 >= mainPlaylist.list.count? 0 : currentTrackIndex+1

        prevTrackIndex = mainPlaylist.list.currentIndex
        playAt(next)

        if(onQueue > 0)
        {
            onQueue--
            console.log(onQueue)
        }
    }
}

function previousTrack()
{
    if(root.mainPlaylist.list.count>0)
    {
        var previous = previous = currentTrackIndex-1 >= 0 ? mainPlaylist.list.currentIndex-1 : currentTrackIndex-1
        prevTrackIndex = mainPlaylist.list.currentIndex
        playAt(previous)
    }
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
        currentTrackIndex = index
        mainPlaylist.list.currentIndex = index
        playTrack(mainPlaylist.list.model.get(index))
    }
}

function quickPlay(track)
{
    //    root.pageStack.currentIndex = 0
    appendTrack(track)
    playAt(root.mainPlaylist.list.count-1)
    root.mainPlaylist.list.positionViewAtEnd()

}

function appendTracksAt(tracks, at)
{
    if(tracks)
        for(var i in tracks)
        {
            if(tracks[i].url !== mainPlaylist.list.model.get(at).url)
                mainPlaylist.list.model.insert(parseInt(at)+parseInt(i), tracks[i])

        }
}

function appendTrack(track)
{
    if(track)
    {
        root.mainPlaylist.list.model.append(track)
        root.animFooter.running = true
        if(root.sync === true)
        {
            root.infoMsgAnim()
            addToPlaylist([track.url], root.syncPlaylist)
        }
    }

    //    if(track)
    //    {
    //        var empty = root.mainPlaylist.list.count
    //        if((empty > 0 && track.url !== root.mainPlaylist.list.model.get(root.mainPlaylist.list.count-1).url) || empty === 0)
    //        {
    //            root.mainPlaylist.list.model.append(track)

    //            if(empty === 0 && root.mainPlaylist.list.count>0)
    //                playAt(0)
    //        }
    //    }
}

function addTrack(track)
{
    if(track)
    {
        appendTrack(track)
        root.mainPlaylist.list.positionViewAtEnd()
    }
}

function appendAll(tracks)
{
    if(tracks)
    {
        for(var i in tracks)
            appendTrack(tracks[i])

        root.mainPlaylist.list.positionViewAtEnd()
    }
}

function savePlaylist()
{
    var list = []
    var n =  root.mainPlaylist.list.count
    n = n > 15 ? 15 : n
    for(var i=0 ; i < n; i++)
    {
        var url = root.mainPlaylist.list.model.get(i).url
        list.push(url)
    }
    bae.savePlaylist(list)
    bae.savePlaylistPos(root.mainPlaylist.list.currentIndex)
}

function clearOutPlaylist()
{
    mainPlaylist.tabe.clearTable()
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

function playAll(tracks)
{
    if(tracks)
    {
        sync = false
        syncPlaylist = ""
        infoMsg = ""

        mainPlaylist.table.clearTable()
        root.pageStack.currentIndex = 0

        for(var i in tracks)
            appendTrack(tracks[i])

        //    root.mainPlaylist.list.currentIndex = 0
        //    playTrack(root.mainPlaylist.list.model.get(0))

        mainPlaylist.list.positionViewAtBeginning()
        playAt(0)
    }
}

function babeTrack(url, value)
{           
    bae.babeTrack(url, value)
}

function addToPlaylist(urls, playlist)
{
    if(urls.length > 0)
    {
        bae.trackPlaylist(urls, playlist)
        //        for(var i in urls)
        //            bae.trackPlaylist(urls[i], playlist)


        if(!isMobile)
            bae.notify(playlist, urls.length + " tracks added to the playlist:\n"+urls.join("\n"))
        //        else
        //            babeNotify.notify(urls.length + " tracks added to " +playlist)

    }
}

