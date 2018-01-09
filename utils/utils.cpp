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
