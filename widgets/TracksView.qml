import QtQuick 2.9
import "../view_models"


BabeTable
{
    id: tracksView
    trackNumberVisible: false
   Component.onCompleted:
   {
       var map = con.get("select * from tracks")
       for(var i in map)
       {
           tracksView.model.append(map[i])
       }
   }
}


