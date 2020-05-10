QT *= network \
        xml

CONFIG += ordered

SOURCES += \
#    $$PWD/services/deezerService.cpp \
    $$PWD/services/lastfmService.cpp \
#    $$PWD/services/spotifyService.cpp \
#    $$PWD/services/musicbrainzService.cpp \
#    $$PWD/services/geniusService.cpp \
#    $$PWD/services/lyricwikiaService.cpp \
    $$PWD/pulpo.cpp \
#    $$PWD/htmlparser.cpp \
    $$PWD/service.cpp

HEADERS += \
#    $$PWD/services/spotifyService.h \
#    $$PWD/services/geniusService.h \
#    $$PWD/services/musicbrainzService.h \
#    $$PWD/services/deezerService.h \
#    $$PWD/services/lyricwikiaService.h \
    $$PWD/services/lastfmService.h \
    $$PWD/enums.h \
    $$PWD/pulpo.h \
#    $$PWD/htmlparser.h \
    $$PWD/service.h


DEPENDPATH += \
    $$PWD \
    $$PWD/services \

INCLUDEPATH += \
    $$PWD \
    $$PWD/services \

#include($$PWD/QGumboParser/QGumboParser.pri)
