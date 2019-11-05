.import org.kde.kirigami 2.7 as Kirigami

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
        return  "";

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

function notify(title, body)
{
    if(Kirigami.Settings.isMobile)
        root.notify(title+"\n"+body)
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

function addToSelection(item)
{
    if(selectionBar.contains(item.url))
    {
        selectionBar.removeAtUri(item.url)
        return
    }

    item.thumbnail= item.artwork
    item.icon = "audio-x-generic"
    item.label= item.title
    item.mime= "image/png"
    item.tooltip= item.url
    item.path= item.url
    selectionBar.append(item.url, item)
}
