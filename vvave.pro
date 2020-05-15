QT *= quick \
    multimedia \
    sql \
    network \
    qml \
    quickcontrols2 \
    concurrent \
    network

CONFIG += ordered
CONFIG += c++17

TARGET = vvave
TEMPLATE = app

VERSION_MAJOR = 1
VERSION_MINOR = 1
VERSION_BUILD = 0

VERSION = $${VERSION_MAJOR}.$${VERSION_MINOR}.$${VERSION_BUILD}
DEFINES += VVAVE_VERSION_STRING=\\\"$$VERSION\\\"

linux:unix:!android {
    message(Building for Linux KDE)
    include($$PWD/kde/kde.pri)
    LIBS += -lMauiKit

} else:android|win32|macos|ios {
    message(Building helpers for Android or Windows)

    android {
        QMAKE_LINK += -nostdlib++
        QT *= androidextras
        ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android_files
        DISTFILES += $$PWD/android_files/AndroidManifest.xml
        DEFINES *= ANDROID_OPENSSL
    }

    android|ios { #build the sources
        QT *= webview

        TAGLIB_REPO = https://github.com/mauikit/taglib
        exists($$PWD/3rdparty/taglib/taglib.pri) {
            message("Using TagLib binaries for Android")
        }else {
            message("Getting Luv icon theme")
            system(git clone $$TAGLIB_REPO $$PWD/3rdparty/taglib)
        }

        include($$PWD/3rdparty/taglib/taglib.pri)

    } else:macos { #from brew installation
        LIBS += -L$$PWD/../../1.11.1/lib/ -ltag.1.17.0

        INCLUDEPATH += $$PWD/../../1.11.1/include
        ICON = $$PWD/macos_files/vvave.icns

    }else:win32 { #from kde craft with msvc
        QT += webengine
        LIBS += -L$$PWD/../../../../CraftRoot/lib/ -ltag
        INCLUDEPATH += $$PWD/../../../../CraftRoot/include
        DEPENDPATH += $$PWD/../../../../CraftRoot/include
        RC_ICONS = $$PWD/windows_files/vvave.ico
    }

#DEFAULT COMPONENTS DEFINITIONS
    DEFINES *= \
        COMPONENT_ACCOUNTS \
        COMPONENT_FM \
        COMPONENT_TAGGING \
        MAUIKIT_STYLE

    include($$PWD/3rdparty/kirigami/kirigami.pri)
    include($$PWD/3rdparty/mauikit/mauikit.pri)

    DEFINES += STATIC_KIRIGAMI

} else {
    message("Unknown configuration")
}

include(pulpo/pulpo.pri)

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += main.cpp \
    db/collectionDB.cpp \
    services/local/taginfo.cpp \
    services/local/player.cpp \
    services/web/youtube.cpp \
    vvave.cpp \
    models/tracks/tracksmodel.cpp \
    models/playlists/playlistsmodel.cpp \
    models/albums/albumsmodel.cpp \
    services/web/NextCloud/nextmusic.cpp \
    services/web/abstractmusicprovider.cpp \
    models/cloud/cloud.cpp

RESOURCES += qml.qrc \

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

HEADERS += \
    db/collectionDB.h \
    utils/bae.h \
    services/local/fileloader.h \
    services/local/taginfo.h \
    services/local/player.h \
    services/web/youtube.h \
    vvave.h \
    models/tracks/tracksmodel.h \
    models/playlists/playlistsmodel.h \
    models/albums/albumsmodel.h \
    services/web/NextCloud/nextmusic.h \
    services/web/abstractmusicprovider.h \
    models/cloud/cloud.h

INCLUDEPATH += \
     $$PWD/services/web \
     $$PWD/services/web/NextCloud

include(install.pri)
