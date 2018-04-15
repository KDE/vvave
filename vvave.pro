QT       += quick
QT       += multimedia
QT       += sql
QT       += websockets
QT       += network
QT       += xml
QT       += qml
QT       += quickcontrols2


TARGET = vvave
TEMPLATE = app

CONFIG += c++11

linux:unix:!android {
    QT       += webengine
    message(Building for Linux KDE)
    include(kde/kde.pri)

} else:android {
    message(Building helpers for Android)
    include(android/android.pri)
    include(android-openssl.pri)
    include(3rdparty/kirigami/kirigami.pri)

    RESOURCES += kirigami-icons.qrc

} else {
    message("Unknown configuration")
}



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
    utils/brain.cpp \
    services/local/socket.cpp \
    pulpo/pulpo.cpp \
    pulpo/htmlparser.cpp \
    services/web/youtube.cpp \
    pulpo/services/deezerService.cpp \
    pulpo/services/lastfmService.cpp \
    pulpo/services/spotifyService.cpp \
    pulpo/services/musicbrainzService.cpp \
    pulpo/services/geniusService.cpp \
    pulpo/services/lyricwikiaService.cpp \ 
    babe.cpp \
    settings/BabeSettings.cpp \
    db/conthread.cpp \
    services/web/babeit.cpp \
    utils/babeconsole.cpp \
    services/local/youtubedl.cpp \
    services/local/linking.cpp


RESOURCES += qml.qrc \

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target


DISTFILES += \
    db/script.sql \
    android-openssl.pri \
    kde/kde.pri \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat \
    android/android.pri


HEADERS += \
    db/collectionDB.h \
    utils/bae.h \
    settings/fileloader.h \
    services/local/taginfo.h \
    services/local/player.h \
    utils/brain.h \
    services/local/socket.h \
    pulpo/enums.h \
    pulpo/pulpo.h \
    pulpo/htmlparser.h \
    services/web/youtube.h \
    pulpo/services/spotifyService.h \
    pulpo/services/geniusService.h \
    pulpo/services/musicbrainzService.h \
    pulpo/services/deezerService.h \
    pulpo/services/lyricwikiaService.h \
    pulpo/services/lastfmService.h \       
    babe.h \
    settings/BabeSettings.h \
    db/conthread.h \
    services/web/babeit.h \
    utils/babeconsole.h \
    utils/singleton.h \
    services/local/youtubedl.h \
    services/local/linking.h


#TAGLIB

    DEPENDPATH += 3rdparty/taglib
    DEPENDPATH += 3rdparty/taglib/ape
    DEPENDPATH += 3rdparty/taglib/asf
    DEPENDPATH += 3rdparty/taglib/flac
    DEPENDPATH += 3rdparty/taglib/it
    DEPENDPATH += 3rdparty/taglib/mod
    DEPENDPATH += 3rdparty/taglib/mp4
    DEPENDPATH += 3rdparty/taglib/mpc
    DEPENDPATH += 3rdparty/taglib/mpeg
    DEPENDPATH += 3rdparty/taglib/mpeg/id3v1
    DEPENDPATH += 3rdparty/taglib/mpeg/id3v2
    DEPENDPATH += 3rdparty/taglib/mpeg/id3v2/frames
    DEPENDPATH += 3rdparty/taglib/ogg
    DEPENDPATH += 3rdparty/taglib/ogg/flac
    DEPENDPATH += 3rdparty/taglib/ogg/opus
    DEPENDPATH += 3rdparty/taglib/ogg/speex
    DEPENDPATH += 3rdparty/taglib/ogg/vorbis
    DEPENDPATH += 3rdparty/taglib/riff
    DEPENDPATH += 3rdparty/taglib/riff/aiff
    DEPENDPATH += 3rdparty/taglib/riff/wav
    DEPENDPATH += 3rdparty/taglib/s3m
    DEPENDPATH += 3rdparty/taglib/toolkit
    DEPENDPATH += 3rdparty/taglib/trueaudio
    DEPENDPATH += 3rdparty/taglib/wavpack
    DEPENDPATH += 3rdparty/taglib/xm


    INCLUDEPATH += 3rdparty/taglib
    INCLUDEPATH += 3rdparty/taglib/ape
    INCLUDEPATH += 3rdparty/taglib/asf
    INCLUDEPATH += 3rdparty/taglib/flac
    INCLUDEPATH += 3rdparty/taglib/it
    INCLUDEPATH += 3rdparty/taglib/mod
    INCLUDEPATH += 3rdparty/taglib/mp4
    INCLUDEPATH += 3rdparty/taglib/mpc
    INCLUDEPATH += 3rdparty/taglib/mpeg
    INCLUDEPATH += 3rdparty/taglib/mpeg/id3v1
    INCLUDEPATH += 3rdparty/taglib/mpeg/id3v2
    INCLUDEPATH += 3rdparty/taglib/mpeg/id3v2/frames
    INCLUDEPATH += 3rdparty/taglib/ogg
    INCLUDEPATH += 3rdparty/taglib/ogg/flac
    INCLUDEPATH += 3rdparty/taglib/ogg/opus
    INCLUDEPATH += 3rdparty/taglib/ogg/speex
    INCLUDEPATH += 3rdparty/taglib/ogg/vorbis
    INCLUDEPATH += 3rdparty/taglib/riff
    INCLUDEPATH += 3rdparty/taglib/riff/aiff
    INCLUDEPATH += 3rdparty/taglib/riff/wav
    INCLUDEPATH += 3rdparty/taglib/s3m
    INCLUDEPATH += 3rdparty/taglib/toolkit
    INCLUDEPATH += 3rdparty/taglib/trueaudio
    INCLUDEPATH += 3rdparty/taglib/wavpack
    INCLUDEPATH += 3rdparty/taglib/xm

SOURCES +=    \
    3rdparty/taglib/ape/apefile.cpp \
    3rdparty/taglib/ape/apefooter.cpp \
    3rdparty/taglib/ape/apeitem.cpp \
    3rdparty/taglib/ape/apeproperties.cpp \
    3rdparty/taglib/ape/apetag.cpp \
    3rdparty/taglib/asf/asfattribute.cpp \
    3rdparty/taglib/asf/asffile.cpp \
    3rdparty/taglib/asf/asfpicture.cpp \
    3rdparty/taglib/asf/asfproperties.cpp \
    3rdparty/taglib/asf/asftag.cpp \
    3rdparty/taglib/flac/flacfile.cpp \
    3rdparty/taglib/flac/flacmetadatablock.cpp \
    3rdparty/taglib/flac/flacpicture.cpp \
    3rdparty/taglib/flac/flacproperties.cpp \
    3rdparty/taglib/flac/flacunknownmetadatablock.cpp \
    3rdparty/taglib/it/itfile.cpp \
    3rdparty/taglib/it/itproperties.cpp \
    3rdparty/taglib/mod/modfile.cpp \
    3rdparty/taglib/mod/modfilebase.cpp \
    3rdparty/taglib/mod/modproperties.cpp \
    3rdparty/taglib/mod/modtag.cpp \
    3rdparty/taglib/mp4/mp4atom.cpp \
    3rdparty/taglib/mp4/mp4coverart.cpp \
    3rdparty/taglib/mp4/mp4file.cpp \
    3rdparty/taglib/mp4/mp4item.cpp \
    3rdparty/taglib/mp4/mp4properties.cpp \
    3rdparty/taglib/mp4/mp4tag.cpp \
    3rdparty/taglib/mpc/mpcfile.cpp \
    3rdparty/taglib/mpc/mpcproperties.cpp \
    3rdparty/taglib/mpeg/id3v1/id3v1genres.cpp \
    3rdparty/taglib/mpeg/id3v1/id3v1tag.cpp \
    3rdparty/taglib/mpeg/id3v2/frames/attachedpictureframe.cpp \
    3rdparty/taglib/mpeg/id3v2/frames/commentsframe.cpp \
    3rdparty/taglib/mpeg/id3v2/frames/generalencapsulatedobjectframe.cpp \
    3rdparty/taglib/mpeg/id3v2/frames/ownershipframe.cpp \
    3rdparty/taglib/mpeg/id3v2/frames/popularimeterframe.cpp \
    3rdparty/taglib/mpeg/id3v2/frames/privateframe.cpp \
    3rdparty/taglib/mpeg/id3v2/frames/relativevolumeframe.cpp \
    3rdparty/taglib/mpeg/id3v2/frames/textidentificationframe.cpp \
    3rdparty/taglib/mpeg/id3v2/frames/uniquefileidentifierframe.cpp \
    3rdparty/taglib/mpeg/id3v2/frames/unknownframe.cpp \
    3rdparty/taglib/mpeg/id3v2/frames/unsynchronizedlyricsframe.cpp \
    3rdparty/taglib/mpeg/id3v2/frames/urllinkframe.cpp \
    3rdparty/taglib/mpeg/id3v2/id3v2extendedheader.cpp \
    3rdparty/taglib/mpeg/id3v2/id3v2footer.cpp \
    3rdparty/taglib/mpeg/id3v2/id3v2frame.cpp \
    3rdparty/taglib/mpeg/id3v2/id3v2framefactory.cpp \
    3rdparty/taglib/mpeg/id3v2/id3v2header.cpp \
    3rdparty/taglib/mpeg/id3v2/id3v2synchdata.cpp \
    3rdparty/taglib/mpeg/id3v2/id3v2tag.cpp \
    3rdparty/taglib/mpeg/mpegfile.cpp \
    3rdparty/taglib/mpeg/mpegheader.cpp \
    3rdparty/taglib/mpeg/mpegproperties.cpp \
    3rdparty/taglib/mpeg/xingheader.cpp \
    3rdparty/taglib/ogg/flac/oggflacfile.cpp \
    3rdparty/taglib/ogg/opus/opusfile.cpp \
    3rdparty/taglib/ogg/opus/opusproperties.cpp \
    3rdparty/taglib/ogg/speex/speexfile.cpp \
    3rdparty/taglib/ogg/speex/speexproperties.cpp \
    3rdparty/taglib/ogg/vorbis/vorbisfile.cpp \
    3rdparty/taglib/ogg/vorbis/vorbisproperties.cpp \
    3rdparty/taglib/ogg/oggfile.cpp \
    3rdparty/taglib/ogg/oggpage.cpp \
    3rdparty/taglib/ogg/oggpageheader.cpp \
    3rdparty/taglib/ogg/xiphcomment.cpp \
    3rdparty/taglib/riff/aiff/aifffile.cpp \
    3rdparty/taglib/riff/aiff/aiffproperties.cpp \
    3rdparty/taglib/riff/wav/infotag.cpp \
    3rdparty/taglib/riff/wav/wavfile.cpp \
    3rdparty/taglib/riff/wav/wavproperties.cpp \
    3rdparty/taglib/riff/rifffile.cpp \
    3rdparty/taglib/s3m/s3mfile.cpp \
    3rdparty/taglib/s3m/s3mproperties.cpp \
    3rdparty/taglib/toolkit/tbytevector.cpp \
    3rdparty/taglib/toolkit/tbytevectorlist.cpp \
    3rdparty/taglib/toolkit/tbytevectorstream.cpp \
    3rdparty/taglib/toolkit/tdebug.cpp \
    3rdparty/taglib/toolkit/tdebuglistener.cpp \
    3rdparty/taglib/toolkit/tfile.cpp \
    3rdparty/taglib/toolkit/tfilestream.cpp \
    3rdparty/taglib/toolkit/tiostream.cpp \
    3rdparty/taglib/toolkit/tpropertymap.cpp \
    3rdparty/taglib/toolkit/trefcounter.cpp \
    3rdparty/taglib/toolkit/tstring.cpp \
    3rdparty/taglib/toolkit/tstringlist.cpp \
    3rdparty/taglib/toolkit/unicode.cpp \
    3rdparty/taglib/trueaudio/trueaudiofile.cpp \
    3rdparty/taglib/trueaudio/trueaudioproperties.cpp \
    3rdparty/taglib/wavpack/wavpackfile.cpp \
    3rdparty/taglib/wavpack/wavpackproperties.cpp \
    3rdparty/taglib/xm/xmfile.cpp \
    3rdparty/taglib/xm/xmproperties.cpp \
    3rdparty/taglib/audioproperties.cpp \
    3rdparty/taglib/fileref.cpp \
    3rdparty/taglib/tag.cpp \
    3rdparty/taglib/tagunion.cpp \

HEADERS += \
    3rdparty/taglib/ape/apefile.h \
    3rdparty/taglib/ape/apefooter.h \
    3rdparty/taglib/ape/apeitem.h \
    3rdparty/taglib/ape/apeproperties.h \
    3rdparty/taglib/ape/apetag.h \
    3rdparty/taglib/asf/asfattribute.h \
    3rdparty/taglib/asf/asffile.h \
    3rdparty/taglib/asf/asfpicture.h \
    3rdparty/taglib/asf/asfproperties.h \
    3rdparty/taglib/asf/asftag.h \
    3rdparty/taglib/flac/flacfile.h \
    3rdparty/taglib/flac/flacmetadatablock.h \
    3rdparty/taglib/flac/flacpicture.h \
    3rdparty/taglib/flac/flacproperties.h \
    3rdparty/taglib/flac/flacunknownmetadatablock.h \
    3rdparty/taglib/it/itfile.h \
    3rdparty/taglib/it/itproperties.h \
    3rdparty/taglib/mod/modfile.h \
    3rdparty/taglib/mod/modfilebase.h \
    3rdparty/taglib/mod/modfileprivate.h \
    3rdparty/taglib/mod/modproperties.h \
    3rdparty/taglib/mod/modtag.h \
    3rdparty/taglib/mp4/mp4atom.h \
    3rdparty/taglib/mp4/mp4coverart.h \
    3rdparty/taglib/mp4/mp4file.h \
    3rdparty/taglib/mp4/mp4item.h \
    3rdparty/taglib/mp4/mp4properties.h \
    3rdparty/taglib/mp4/mp4tag.h \
    3rdparty/taglib/mpc/mpcfile.h \
    3rdparty/taglib/mpc/mpcproperties.h \
    3rdparty/taglib/mpeg/id3v1/id3v1genres.h \
    3rdparty/taglib/mpeg/id3v1/id3v1tag.h \
    3rdparty/taglib/mpeg/id3v2/frames/attachedpictureframe.h \
    3rdparty/taglib/mpeg/id3v2/frames/commentsframe.h \
    3rdparty/taglib/mpeg/id3v2/frames/generalencapsulatedobjectframe.h \
    3rdparty/taglib/mpeg/id3v2/frames/ownershipframe.h \
    3rdparty/taglib/mpeg/id3v2/frames/popularimeterframe.h \
    3rdparty/taglib/mpeg/id3v2/frames/privateframe.h \
    3rdparty/taglib/mpeg/id3v2/frames/relativevolumeframe.h \
    3rdparty/taglib/mpeg/id3v2/frames/textidentificationframe.h \
    3rdparty/taglib/mpeg/id3v2/frames/uniquefileidentifierframe.h \
    3rdparty/taglib/mpeg/id3v2/frames/unknownframe.h \
    3rdparty/taglib/mpeg/id3v2/frames/unsynchronizedlyricsframe.h \
    3rdparty/taglib/mpeg/id3v2/frames/urllinkframe.h \
    3rdparty/taglib/mpeg/id3v2/id3v2extendedheader.h \
    3rdparty/taglib/mpeg/id3v2/id3v2footer.h \
    3rdparty/taglib/mpeg/id3v2/id3v2frame.h \
    3rdparty/taglib/mpeg/id3v2/id3v2framefactory.h \
    3rdparty/taglib/mpeg/id3v2/id3v2header.h \
    3rdparty/taglib/mpeg/id3v2/id3v2synchdata.h \
    3rdparty/taglib/mpeg/id3v2/id3v2tag.h \
    3rdparty/taglib/mpeg/mpegfile.h \
    3rdparty/taglib/mpeg/mpegheader.h \
    3rdparty/taglib/mpeg/mpegproperties.h \
    3rdparty/taglib/mpeg/xingheader.h \
    3rdparty/taglib/ogg/flac/oggflacfile.h \
    3rdparty/taglib/ogg/opus/opusfile.h \
    3rdparty/taglib/ogg/opus/opusproperties.h \
    3rdparty/taglib/ogg/speex/speexfile.h \
    3rdparty/taglib/ogg/speex/speexproperties.h \
    3rdparty/taglib/ogg/vorbis/vorbisfile.h \
    3rdparty/taglib/ogg/vorbis/vorbisproperties.h \
    3rdparty/taglib/ogg/oggfile.h \
    3rdparty/taglib/ogg/oggpage.h \
    3rdparty/taglib/ogg/oggpageheader.h \
    3rdparty/taglib/ogg/xiphcomment.h \
    3rdparty/taglib/riff/aiff/aifffile.h \
    3rdparty/taglib/riff/aiff/aiffproperties.h \
    3rdparty/taglib/riff/wav/infotag.h \
    3rdparty/taglib/riff/wav/wavfile.h \
    3rdparty/taglib/riff/wav/wavproperties.h \
    3rdparty/taglib/riff/rifffile.h \
    3rdparty/taglib/s3m/s3mfile.h \
    3rdparty/taglib/s3m/s3mproperties.h \
    3rdparty/taglib/toolkit/taglib.h \
    3rdparty/taglib/toolkit/tbytevector.h \
    3rdparty/taglib/toolkit/tbytevectorlist.h \
    3rdparty/taglib/toolkit/tbytevectorstream.h \
    3rdparty/taglib/toolkit/tdebug.h \
    3rdparty/taglib/toolkit/tdebuglistener.h \
    3rdparty/taglib/toolkit/tfile.h \
    3rdparty/taglib/toolkit/tfilestream.h \
    3rdparty/taglib/toolkit/tiostream.h \
    3rdparty/taglib/toolkit/tlist.h \
    3rdparty/taglib/toolkit/tmap.h \
    3rdparty/taglib/toolkit/tpropertymap.h \
    3rdparty/taglib/toolkit/trefcounter.h \
    3rdparty/taglib/toolkit/tstring.h \
    3rdparty/taglib/toolkit/tstringlist.h \
    3rdparty/taglib/toolkit/tutils.h \
    3rdparty/taglib/toolkit/unicode.h \
    3rdparty/taglib/trueaudio/trueaudiofile.h \
    3rdparty/taglib/trueaudio/trueaudioproperties.h \
    3rdparty/taglib/wavpack/wavpackfile.h \
    3rdparty/taglib/wavpack/wavpackproperties.h \
    3rdparty/taglib/xm/xmfile.h \
    3rdparty/taglib/xm/xmproperties.h \
    3rdparty/taglib/audioproperties.h \
    3rdparty/taglib/fileref.h \
    3rdparty/taglib/tag.h \
    3rdparty/taglib/taglib_export.h \
    3rdparty/taglib/tagunion.h \
    3rdparty/taglib/config.h \
    3rdparty/taglib/taglib_config.h \

#INCLUDEPATH += /usr/include/python3.6m

#LIBS += -lpython3.6m
#defineReplace(copyToDir) {
#    files = $$1
#    DIR = $$2
#    LINK =

#    for(FILE, files) {
#        LINK += $$QMAKE_COPY $$shell_path($$FILE) $$shell_path($$DIR) $$escape_expand(\\n\\t)
#    }
#    return($$LINK)
#}

#defineReplace(copyToBuilddir) {
#    return($$copyToDir($$1, $$OUT_PWD))
#}

## Copy the binary files dependent on the system architecture
#unix:!macx {
#    message("Linux")
#    QMAKE_POST_LINK += $$copyToBuilddir($$PWD/library/cat)
#}
