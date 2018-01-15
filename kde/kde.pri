

unix:linux:!android:
{
QT       += dbus
 QT       += KConfigCore
 QT       += KNotifications
 QT       += KI18n

HEADERS += \ kde/notify.h \
    kde/mpris2.h

SOURCES += kde/notify.cpp \
    kde/mpris2.cpp

}

android:
{
QT       -= dbus
 QT       -= KConfigCore
 QT       -= KNotifications
 QT       -= KI18n

HEADERS -= \ kde/notify.h \
    kde/mpris2.h

SOURCES -= kde/notify.cpp \
    kde/mpris2.cpp
}
