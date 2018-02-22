
linux:unix:!android {
    message(Building for Linux)
    QT       += dbus
    QT       += KConfigCore
    QT       += KNotifications
    QT       += KI18n

    HEADERS += \ kde/notify.h \
        kde/mpris2.h

    SOURCES += kde/notify.cpp \
        kde/mpris2.cpp
}

HEADERS += \
    $$PWD/kdeconnect.h

SOURCES += \
    $$PWD/kdeconnect.cpp


