import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ".."

BabeList
{
    id: list

    property int currentRow : -1
    property string currentUrl
    property string currentName

    signal rowClicked(int index)
    signal rowPressed(int index)


    ListModel { id: listModel }

    model: listModel

    delegate: BabeDelegate
    {
        id: delegate
        label : name

        Connections
        {
            target: delegate
            onClicked:
            {
                currentIndex = index
                list.rowClicked(index)
            }
        }
    }

    ScrollBar.vertical: ScrollBar { }
}
