
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
