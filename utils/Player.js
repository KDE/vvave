Qt.include("Icons.js")


function playTrack(track)
{
    if(track)
    {
        root.currentTrack = track

        if(bae.fileExists(root.currentTrack.url))
        {
            player.source(root.currentTrack.url);
            player.play()
            root.playIcon.iconName = "media-playback-pause"


            var artwork = root.currentTrack.artwork
            //    root.mainPlaylist.list.currentItem.playingIndicator = true
            root.currentArtwork = artwork && artwork.length>0 && artwork !== "NONE" ? artwork : bae.loadCover(root.mainPlaylist.currentTrack.url)

            if(!root.isMobile)
            {
                root.title = root.currentTrack.title + " - " +root.currentTrack.artist

                if(!root.active)
                    bae.notifySong(root.currentTrack.url)
            }

            var lyrics = root.currentTrack.lyrics

            //    if(!lyrics || lyrics.length === 0 || lyrics === "NONE" )
            //        bae.trackLyrics(root.mainPlaylist.currentTrack.url)
            //    else
            root.mainPlaylist.infoView.lyrics =  lyrics

            //    root.mainPlaylist.infoView.wikiAlbum = bae.albumWiki(root.mainPlaylist.currentTrack.album,root.mainPlaylist.currentTrack.artist)
            //    root.mainPlaylist.infoView.wikiArtist = bae.artistWiki(root.mainPlaylist.currentTrack.artist)
            //    //    root.mainPlaylist.infoView.artistHead = bae.artistArt(root.mainPlaylist.currentTrack.artist)
        }else root.missingAlert(root.currentTrack)
    }
}


function stop()
{
    player.stop()
    root.mainPlaylist.progressBar.value = 0
    root.mainPlaylist.cover.visible = false
    root.title = "Babe..."
    root.playIcon.iconName = "media-playback-start"
}

function pauseTrack()
{
    player.pause()
    root.playIcon.iconName = "media-playback-start"
}

function resumeTrack()
{
    player.play()
    root.playIcon.iconName = "media-playback-pause"
}

function nextTrack()
{
    if(root.mainPlaylist.list.count>0)
    {
        var next = 0
        if(root.shuffle)
            next = shuffle()
        else
            next = root.mainPlaylist.list.currentIndex+1 >= root.mainPlaylist.list.count? 0 : root.mainPlaylist.list.currentIndex+1

        root.prevTrackIndex = root.mainPlaylist.list.currentIndex
        playAt(next)
    }
}

function previousTrack()
{
    if(root.mainPlaylist.list.count>0)
    {
        var previous = previous = root.mainPlaylist.list.currentIndex-1 >= 0 ? root.mainPlaylist.list.currentIndex-1 : root.mainPlaylist.list.count-1
        root.prevTrackIndex = root.mainPlaylist.list.currentIndex
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
        root.mainPlaylist.list.currentIndex = index
        playTrack(root.mainPlaylist.list.model.get(index))
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
            if(tracks[i].url !== root.mainPlaylist.list.model.get(at).url)
                root.mainPlaylist.list.model.insert(parseInt(at)+parseInt(i), tracks[i])

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

function playAll(tracks)
{
    if(tracks)
    {
        root.sync = false
        root.syncPlaylist = ""
        root.infoMsg = ""

        root.mainPlaylist.list.clearTable()
        root.pageStack.currentIndex = 0

        for(var i in tracks)
            appendTrack(tracks[i])

        //    root.mainPlaylist.list.currentIndex = 0
        //    playTrack(root.mainPlaylist.list.model.get(0))

        root.mainPlaylist.list.positionViewAtBeginning()
        playAt(0)
    }


}

function babeTrack()
{           

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

