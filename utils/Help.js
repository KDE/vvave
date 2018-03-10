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

    console.log("Clearing tables")
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
    albumsView.clearGrid()
    albumsView.populate()

}

function refreshArtists()
{
    artistsView.clearGrid()
    artistsView.populate()
}

function notify(title, body)
{
    if(isMobile)
        babeNotify(title+"\n"+body)
    else
        bae.notify(title, body)
}
