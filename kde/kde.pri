linux:unix:!android
{
    QT       += dbus
    QT       += KConfigCore
    QT       += KNotifications
    QT       += KI18n

    HEADERS += $$PWD/notify.h \
        $$PWD/mpris2.h \
         $$PWD/kdeconnect.h

    SOURCES +=  $$PWD/notify.cpp \
         $$PWD/mpris2.cpp \
         $$PWD/kdeconnect.cpp
}
