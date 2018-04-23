QT += androidextras webview

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
    $$PWD/src/MyService.java \
    $$PWD/AndroidManifest.xml \
    $$PWD/gradlew \
    $$PWD/build.gradle \
    $$PWD/gradlew.bat \
    $$PWD/gradle.properties \
    $$PWD/local.properties \
    $$PWD/gradle/wrapper/gradle-wrapper.jar \
    $$PWD/gradlew \
    $$PWD/res/values/libs.xml \
    $$PWD/gradle/wrapper/gradle-wrapper.properties


ANDROID_PACKAGE_SOURCE_DIR = $$PWD/


RESOURCES += \
    $$PWD/android.qrc \
    $$PWD/../kirigami-icons.qrc \
    $$PWD/../icons.qrc

