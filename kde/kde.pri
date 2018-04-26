QT       += dbus
QT       += KConfigCore
QT       += KNotifications
QT       += KI18n
QT       += webengine

HEADERS += \
    $$PWD/notify.h \
    $$PWD/mpris2.h \
    $$PWD/kdeconnect.h

SOURCES += \
    $$PWD/notify.cpp \
    $$PWD/mpris2.cpp \
    $$PWD/kdeconnect.cpp

LIBS += -ltag

WEBENGINE_CONFIG+=proprietary_codecs
