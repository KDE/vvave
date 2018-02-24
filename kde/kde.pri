
linux:unix:!android
{
    QT       += dbus
    QT       += KConfigCore
    QT       += KNotifications
    QT       += KI18n

    HEADERS += \ kde/notify.h \
        kde/mpris2.h \
        kde/kdeconnect.h

    SOURCES += kde/notify.cpp \
        kde/mpris2.cpp \
        kde/kdeconnect.cpp
}
