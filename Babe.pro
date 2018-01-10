QT       += quick
QT       += multimedia
QT       += sql
QT       += widgets
QT       += websockets
QT       += network
QT       += xml

CONFIG += c++11

include(android-openssl.pri)
#android: {
#    include(3rdparty/kirigami/kirigami.pri)
#}

DEPENDPATH += taglib
DEPENDPATH += taglib/ape
DEPENDPATH += taglib/asf
DEPENDPATH += taglib/flac
DEPENDPATH += taglib/it
DEPENDPATH += taglib/mod
DEPENDPATH += taglib/mp4
DEPENDPATH += taglib/mpc
DEPENDPATH += taglib/mpeg
DEPENDPATH += taglib/mpeg/id3v1
DEPENDPATH += taglib/mpeg/id3v2
DEPENDPATH += taglib/mpeg/id3v2/frames
DEPENDPATH += taglib/ogg
DEPENDPATH += taglib/ogg/flac
DEPENDPATH += taglib/ogg/opus
DEPENDPATH += taglib/ogg/speex
DEPENDPATH += taglib/ogg/vorbis
DEPENDPATH += taglib/riff
DEPENDPATH += taglib/riff/aiff
DEPENDPATH += taglib/riff/wav
DEPENDPATH += taglib/s3m
DEPENDPATH += taglib/toolkit
DEPENDPATH += taglib/trueaudio
DEPENDPATH += taglib/wavpack
DEPENDPATH += taglib/xm


INCLUDEPATH += taglib
INCLUDEPATH += taglib/ape
INCLUDEPATH += taglib/asf
INCLUDEPATH += taglib/flac
INCLUDEPATH += taglib/it
INCLUDEPATH += taglib/mod
INCLUDEPATH += taglib/mp4
INCLUDEPATH += taglib/mpc
INCLUDEPATH += taglib/mpeg
INCLUDEPATH += taglib/mpeg/id3v1
INCLUDEPATH += taglib/mpeg/id3v2
INCLUDEPATH += taglib/mpeg/id3v2/frames
INCLUDEPATH += taglib/ogg
INCLUDEPATH += taglib/ogg/flac
INCLUDEPATH += taglib/ogg/opus
INCLUDEPATH += taglib/ogg/speex
INCLUDEPATH += taglib/ogg/vorbis
INCLUDEPATH += taglib/riff
INCLUDEPATH += taglib/riff/aiff
INCLUDEPATH += taglib/riff/wav
INCLUDEPATH += taglib/s3m
INCLUDEPATH += taglib/toolkit
INCLUDEPATH += taglib/trueaudio
INCLUDEPATH += taglib/wavpack
INCLUDEPATH += taglib/xm

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
    settings/settings.cpp \
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
        taglib/ape/apefile.cpp \
        taglib/ape/apefooter.cpp \
        taglib/ape/apeitem.cpp \
        taglib/ape/apeproperties.cpp \
        taglib/ape/apetag.cpp \
        taglib/asf/asfattribute.cpp \
        taglib/asf/asffile.cpp \
        taglib/asf/asfpicture.cpp \
        taglib/asf/asfproperties.cpp \
        taglib/asf/asftag.cpp \
        taglib/flac/flacfile.cpp \
        taglib/flac/flacmetadatablock.cpp \
        taglib/flac/flacpicture.cpp \
        taglib/flac/flacproperties.cpp \
        taglib/flac/flacunknownmetadatablock.cpp \
        taglib/it/itfile.cpp \
        taglib/it/itproperties.cpp \
        taglib/mod/modfile.cpp \
        taglib/mod/modfilebase.cpp \
        taglib/mod/modproperties.cpp \
        taglib/mod/modtag.cpp \
        taglib/mp4/mp4atom.cpp \
        taglib/mp4/mp4coverart.cpp \
        taglib/mp4/mp4file.cpp \
        taglib/mp4/mp4item.cpp \
        taglib/mp4/mp4properties.cpp \
        taglib/mp4/mp4tag.cpp \
        taglib/mpc/mpcfile.cpp \
        taglib/mpc/mpcproperties.cpp \
        taglib/mpeg/id3v1/id3v1genres.cpp \
        taglib/mpeg/id3v1/id3v1tag.cpp \
        taglib/mpeg/id3v2/frames/attachedpictureframe.cpp \
        taglib/mpeg/id3v2/frames/commentsframe.cpp \
        taglib/mpeg/id3v2/frames/generalencapsulatedobjectframe.cpp \
        taglib/mpeg/id3v2/frames/ownershipframe.cpp \
        taglib/mpeg/id3v2/frames/popularimeterframe.cpp \
        taglib/mpeg/id3v2/frames/privateframe.cpp \
        taglib/mpeg/id3v2/frames/relativevolumeframe.cpp \
        taglib/mpeg/id3v2/frames/textidentificationframe.cpp \
        taglib/mpeg/id3v2/frames/uniquefileidentifierframe.cpp \
        taglib/mpeg/id3v2/frames/unknownframe.cpp \
        taglib/mpeg/id3v2/frames/unsynchronizedlyricsframe.cpp \
        taglib/mpeg/id3v2/frames/urllinkframe.cpp \
        taglib/mpeg/id3v2/id3v2extendedheader.cpp \
        taglib/mpeg/id3v2/id3v2footer.cpp \
        taglib/mpeg/id3v2/id3v2frame.cpp \
        taglib/mpeg/id3v2/id3v2framefactory.cpp \
        taglib/mpeg/id3v2/id3v2header.cpp \
        taglib/mpeg/id3v2/id3v2synchdata.cpp \
        taglib/mpeg/id3v2/id3v2tag.cpp \
        taglib/mpeg/mpegfile.cpp \
        taglib/mpeg/mpegheader.cpp \
        taglib/mpeg/mpegproperties.cpp \
        taglib/mpeg/xingheader.cpp \
        taglib/ogg/flac/oggflacfile.cpp \
        taglib/ogg/opus/opusfile.cpp \
        taglib/ogg/opus/opusproperties.cpp \
        taglib/ogg/speex/speexfile.cpp \
        taglib/ogg/speex/speexproperties.cpp \
        taglib/ogg/vorbis/vorbisfile.cpp \
        taglib/ogg/vorbis/vorbisproperties.cpp \
        taglib/ogg/oggfile.cpp \
        taglib/ogg/oggpage.cpp \
        taglib/ogg/oggpageheader.cpp \
        taglib/ogg/xiphcomment.cpp \
        taglib/riff/aiff/aifffile.cpp \
        taglib/riff/aiff/aiffproperties.cpp \
        taglib/riff/wav/infotag.cpp \
        taglib/riff/wav/wavfile.cpp \
        taglib/riff/wav/wavproperties.cpp \
        taglib/riff/rifffile.cpp \
        taglib/s3m/s3mfile.cpp \
        taglib/s3m/s3mproperties.cpp \
        taglib/toolkit/tbytevector.cpp \
        taglib/toolkit/tbytevectorlist.cpp \
        taglib/toolkit/tbytevectorstream.cpp \
        taglib/toolkit/tdebug.cpp \
        taglib/toolkit/tdebuglistener.cpp \
        taglib/toolkit/tfile.cpp \
        taglib/toolkit/tfilestream.cpp \
        taglib/toolkit/tiostream.cpp \
        taglib/toolkit/tpropertymap.cpp \
        taglib/toolkit/trefcounter.cpp \
        taglib/toolkit/tstring.cpp \
        taglib/toolkit/tstringlist.cpp \
        taglib/toolkit/unicode.cpp \
        taglib/trueaudio/trueaudiofile.cpp \
        taglib/trueaudio/trueaudioproperties.cpp \
        taglib/wavpack/wavpackfile.cpp \
        taglib/wavpack/wavpackproperties.cpp \
        taglib/xm/xmfile.cpp \
        taglib/xm/xmproperties.cpp \
        taglib/audioproperties.cpp \
        taglib/fileref.cpp \
        taglib/tag.cpp \
        taglib/tagunion.cpp \
    utils/utils.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
n

DISTFILES += \
    db/script.sql \
    android-openssl.pri \
#    3rdparty/kirigami/kirigami.pri


HEADERS += \
    db/collectionDB.h \
    utils/bae.h \
    settings/settings.h \
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
        taglib/ape/apefile.h \
        taglib/ape/apefooter.h \
        taglib/ape/apeitem.h \
        taglib/ape/apeproperties.h \
        taglib/ape/apetag.h \
        taglib/asf/asfattribute.h \
        taglib/asf/asffile.h \
        taglib/asf/asfpicture.h \
        taglib/asf/asfproperties.h \
        taglib/asf/asftag.h \
        taglib/flac/flacfile.h \
        taglib/flac/flacmetadatablock.h \
        taglib/flac/flacpicture.h \
        taglib/flac/flacproperties.h \
        taglib/flac/flacunknownmetadatablock.h \
        taglib/it/itfile.h \
        taglib/it/itproperties.h \
        taglib/mod/modfile.h \
        taglib/mod/modfilebase.h \
        taglib/mod/modfileprivate.h \
        taglib/mod/modproperties.h \
        taglib/mod/modtag.h \
        taglib/mp4/mp4atom.h \
        taglib/mp4/mp4coverart.h \
        taglib/mp4/mp4file.h \
        taglib/mp4/mp4item.h \
        taglib/mp4/mp4properties.h \
        taglib/mp4/mp4tag.h \
        taglib/mpc/mpcfile.h \
        taglib/mpc/mpcproperties.h \
        taglib/mpeg/id3v1/id3v1genres.h \
        taglib/mpeg/id3v1/id3v1tag.h \
        taglib/mpeg/id3v2/frames/attachedpictureframe.h \
        taglib/mpeg/id3v2/frames/commentsframe.h \
        taglib/mpeg/id3v2/frames/generalencapsulatedobjectframe.h \
        taglib/mpeg/id3v2/frames/ownershipframe.h \
        taglib/mpeg/id3v2/frames/popularimeterframe.h \
        taglib/mpeg/id3v2/frames/privateframe.h \
        taglib/mpeg/id3v2/frames/relativevolumeframe.h \
        taglib/mpeg/id3v2/frames/textidentificationframe.h \
        taglib/mpeg/id3v2/frames/uniquefileidentifierframe.h \
        taglib/mpeg/id3v2/frames/unknownframe.h \
        taglib/mpeg/id3v2/frames/unsynchronizedlyricsframe.h \
        taglib/mpeg/id3v2/frames/urllinkframe.h \
        taglib/mpeg/id3v2/id3v2extendedheader.h \
        taglib/mpeg/id3v2/id3v2footer.h \
        taglib/mpeg/id3v2/id3v2frame.h \
        taglib/mpeg/id3v2/id3v2framefactory.h \
        taglib/mpeg/id3v2/id3v2header.h \
        taglib/mpeg/id3v2/id3v2synchdata.h \
        taglib/mpeg/id3v2/id3v2tag.h \
        taglib/mpeg/mpegfile.h \
        taglib/mpeg/mpegheader.h \
        taglib/mpeg/mpegproperties.h \
        taglib/mpeg/xingheader.h \
        taglib/ogg/flac/oggflacfile.h \
        taglib/ogg/opus/opusfile.h \
        taglib/ogg/opus/opusproperties.h \
        taglib/ogg/speex/speexfile.h \
        taglib/ogg/speex/speexproperties.h \
        taglib/ogg/vorbis/vorbisfile.h \
        taglib/ogg/vorbis/vorbisproperties.h \
        taglib/ogg/oggfile.h \
        taglib/ogg/oggpage.h \
        taglib/ogg/oggpageheader.h \
        taglib/ogg/xiphcomment.h \
        taglib/riff/aiff/aifffile.h \
        taglib/riff/aiff/aiffproperties.h \
        taglib/riff/wav/infotag.h \
        taglib/riff/wav/wavfile.h \
        taglib/riff/wav/wavproperties.h \
        taglib/riff/rifffile.h \
        taglib/s3m/s3mfile.h \
        taglib/s3m/s3mproperties.h \
        taglib/toolkit/taglib.h \
        taglib/toolkit/tbytevector.h \
        taglib/toolkit/tbytevectorlist.h \
        taglib/toolkit/tbytevectorstream.h \
        taglib/toolkit/tdebug.h \
        taglib/toolkit/tdebuglistener.h \
        taglib/toolkit/tfile.h \
        taglib/toolkit/tfilestream.h \
        taglib/toolkit/tiostream.h \
        taglib/toolkit/tlist.h \
        taglib/toolkit/tmap.h \
        taglib/toolkit/tpropertymap.h \
        taglib/toolkit/trefcounter.h \
        taglib/toolkit/tstring.h \
        taglib/toolkit/tstringlist.h \
        taglib/toolkit/tutils.h \
        taglib/toolkit/unicode.h \
        taglib/trueaudio/trueaudiofile.h \
        taglib/trueaudio/trueaudioproperties.h \
        taglib/wavpack/wavpackfile.h \
        taglib/wavpack/wavpackproperties.h \
        taglib/xm/xmfile.h \
        taglib/xm/xmproperties.h \
        taglib/audioproperties.h \
        taglib/fileref.h \
        taglib/tag.h \
        taglib/taglib_export.h \
        taglib/tagunion.h \
        taglib/config.h \
        taglib/taglib_config.h \
    utils/utils.h

#unix:!macx: LIBS += -L$$PWD/3rdparty/taglib/taglib/ -ltag

#INCLUDEPATH += $$PWD/3rdparty/taglib/taglib
#DEPENDPATH += $$PWD/3rdparty/taglib/taglib

#unix:!macx: PRE_TARGETDEPS += $$PWD/3rdparty/taglib/taglib/libtag.a
