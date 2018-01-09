#include "utils.h"
#include "bae.h"

using namespace BAE;
Utils::Utils(QObject *parent) : QObject(parent)
{ }

void Utils::savePlaylist(const QStringList &list)
{
    qDebug()<<"SAVED PLAYLIST:::"<<list;
    BAE::saveSettings("PLAYLIST", list, "MAINWINDOW");
}

QStringList Utils::lastPlaylist()
{
    return BAE::loadSettings("PLAYLIST","MAINWINDOW",{}).toStringList();
}

void Utils::savePlaylistPos(const int &pos)
{
    BAE::saveSettings("PLAYLIST_POS", pos, "MAINWINDOW");
}

int Utils::lastPlaylistPos()
{
    return BAE::loadSettings("PLAYLIST_POS","MAINWINDOW",QVariant(0)).toInt();
}


