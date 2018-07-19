.import "../db/Queries.js" as Q


function rootWidth()
{
    return root.width;
}

function rootHeight()
{
    return root.height;
}

function setStars(stars)
{
    switch (stars)
    {
    case "0":
    case 0:
        return  " ";

    case "1":
    case 1:
        return  "\uf4CE";

    case "2":
    case 2:
        return "\uf4CE \uf4CE";

    case "3":
    case 3:
        return  "\uf4CE \uf4CE \uf4CE";

    case "4":
    case 4:
        return  "\uf4CE \uf4CE \uf4CE \uf4CE";

    case "5":
    case 5:
        return "\uf4CE \uf4CE \uf4CE \uf4CE \uf4CE";

    default: return "error";
    }
}

function refreshCollection(size)
{
    if(!isMobile && size>0) bae.notify("Collection updated", size+" new tracks added...")

    refreshTracks()
    refreshAlbums()
    refreshArtists()
}

function refreshTracks()
{
    tracksView.clearTable()
    tracksView.populate()
}

function refreshAlbums()
{
    albumsView.grid.clearGrid()
    albumsView.populate(Q.GET.allAlbumsAsc)

}

function refreshArtists()
{
    artistsView.grid.clearGrid()
    artistsView.populate(Q.GET.allArtistsAsc)
}

function notify(title, body)
{
    if(isMobile)
        babeNotify.notify(title+"\n"+body)
    else
        bae.notify(title, body)
}


function addPlaylist(playlist)
{
    playlistsView.playlistViewModel.model.insert(0, playlist)
}

function searchFor(query)
{
    if(currentView !== viewsIndex.search)
        currentView = viewsIndex.search

    searchView.runSearch(query)
}

function addSource()
{
    sourcesDialog.open()
}
