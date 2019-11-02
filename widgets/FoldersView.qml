import QtQuick 2.0
import QtQuick.Controls 2.10
import org.kde.mauikit 1.0 as Maui
import "../view_models/BabeTable"
import "../db/Queries.js" as Q

Item
{
    id: control
    property alias list : _filterList
    property alias listModel : _filterList.model
    property var tracks : []
    property string currentFolder : ""

    Maui.GridBrowser
    {
        id: browser
        anchors.margins: Maui.Style.space.big
        anchors.fill: parent
        showEmblem: false
        model: ListModel {}
        onItemClicked:
        {
            var item = browser.model.get(index)
            _filterList.title= item.label
            currentFolder = item.path
            filter()
            _listDialog.open()
        }
    }


    Maui.Holder
    {
        anchors.fill: parent
        visible: !browser.count
        emoji: "qrc:/assets/MusicCloud.png"
        isMask: false
        title : "No Folders!"
        body: "Add new music to your sources to browse by folders"
        emojiSize: Maui.Style.iconSizes.huge
    }

    Maui.Dialog
    {
        id: _listDialog
        parent: parent
        maxHeight: maxWidth
        maxWidth: Maui.Style.unit * 600
        defaultButtons: false
        page.padding: 0
        BabeTable
        {
            id: _filterList
            anchors.fill: parent
            coverArtVisible: true
            holder.emoji: "qrc:/assets/MusicCloud.png"
            holder.isMask: false
            holder.title : "No Tracks!"
            holder.body: "This source folder seems to be empty!"
            holder.emojiSize: Maui.Style.iconSizes.huge
        }
    }

    Component.onCompleted: populate()

    function populate()
    {
        browser.model.clear()
        var folders = vvave.sourceFolders();
        if(folders.length > 0)
            for(var i in folders)
                browser.model.append(folders[i])
    }

    function filter()
    {
        var where = "source = \""+currentFolder+"\""
        _filterList.list.query = (Q.GET.tracksWhere_.arg(where))

    }
}
