#include "utils.h"
#include "bae.h"
#include <QPalette>
#include <QWidget>
#include <QColor>

using namespace BAE;
Utils::Utils(QObject *parent) : QObject(parent)
{ }

void Utils::savePlaylist(const QStringList &list)
{
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

QString Utils::backgroundColor()
{

#if defined(Q_OS_ANDROID)
return "#31363b";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Background).name();
#elif defined(Q_OS_WIN32)
return "#31363b";
#endif

}

QString Utils::foregroundColor()
{

#if defined(Q_OS_ANDROID)
return "#FFF";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Text).name();
#elif defined(Q_OS_WIN32)
return "#FFF";
#endif

}

QString Utils::hightlightColor()
{

#if defined(Q_OS_ANDROID)
return "#FFF";
#elif defined(Q_OS_LINUX)
    QWidget widget;
    return widget.palette().color(QPalette::Highlight).name();
#elif defined(Q_OS_WIN32)
return "#FFF";
#endif
}


