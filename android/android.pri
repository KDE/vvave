android {

QT += androidextras

HEADERS += \
    $$PWD/android.h \
    $$PWD/android.h \
    $$PWD/notificationclient.h

SOURCES += \
    $$PWD/android.cpp \
    $$PWD/notificationclient.cpp

DISTFILES += \
    $$PWD/src/SendIntent.java \
    $$PWD/src/NotificationClient.java \
    $$PWD/src/MyService.java


ANDROID_PACKAGE_SOURCE_DIR = $$PWD/src

}
