import QtQuick 2.0
import QtQuick.Controls 2.2
import org.kde.maui 1.0 as Maui
import "../view_models/BabeTable"
import "../db/Queries.js" as Q

StackView
{
    id: stack
    property alias list : filterList
    property var tracks : []
    property string currentFolder : ""

    initialItem: Maui.Page
    {
        anchors.fill: parent
        headBarTitle: qsTr("Source folders")
        headBarExit: false
        margins: space.large

        Maui.GridBrowser
        {
            anchors.fill: parent
            id: browser
            onItemClicked:
            {
                stack.push(filterList)
                var item = browser.model.get(index)
                filterList.headBarTitle= item.label
                currentFolder = item.path
                filter()
            }
        }
    }

    BabeTable
    {
        id: filterList
        coverArtVisible: true
        headBarExitIcon: "go-previous"
        holder.emoji: "qrc:/assets/MusicCloud.png"
        holder.isMask: false
        holder.title : "No Tracks!"
        holder.body: "This source folder seems to be empty!"
        holder.emojiSize: iconSizes.huge

        onExit:
        {
            stack.pop()
        }
    }

    function populate()
    {
        browser.model.clear()
        var folders = bae.getFolders();
        if(folders.length > 0)
            for(var i in folders)
                browser.model.append(folders[i])
    }

    function filter()
    {
        filterList.model.clear()
        tracks = getTracks()

        for(var i in tracks)
            filterList.model.append(tracks[i])
    }

    function getTracks()
    {
        var where = "sources_url = \""+currentFolder+"\""
        return bae.get(Q.GET.tracksWhere_.arg(where))
    }
}
