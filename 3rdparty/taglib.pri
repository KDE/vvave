    DEPENDPATH += $$PWD/taglib
    DEPENDPATH += $$PWD/taglib/ape
    DEPENDPATH += $$PWD/taglib/asf
    DEPENDPATH += $$PWD/taglib/flac
    DEPENDPATH += $$PWD/taglib/it
    DEPENDPATH += $$PWD/taglib/mod
    DEPENDPATH += $$PWD/taglib/mp4
    DEPENDPATH += $$PWD/taglib/mpc
    DEPENDPATH += $$PWD/taglib/mpeg
    DEPENDPATH += $$PWD/taglib/mpeg/id3v1
    DEPENDPATH += $$PWD/taglib/mpeg/id3v2
    DEPENDPATH += $$PWD/taglib/mpeg/id3v2/frames
    DEPENDPATH += $$PWD/taglib/ogg
    DEPENDPATH += $$PWD/taglib/ogg/flac
    DEPENDPATH += $$PWD/taglib/ogg/opus
    DEPENDPATH += $$PWD/taglib/ogg/speex
    DEPENDPATH += $$PWD/taglib/ogg/vorbis
    DEPENDPATH += $$PWD/taglib/riff
    DEPENDPATH += $$PWD/taglib/riff/aiff
    DEPENDPATH += $$PWD/taglib/riff/wav
    DEPENDPATH += $$PWD/taglib/s3m
    DEPENDPATH += $$PWD/taglib/toolkit
    DEPENDPATH += $$PWD/taglib/trueaudio
    DEPENDPATH += $$PWD/taglib/wavpack
    DEPENDPATH += $$PWD/taglib/xm


    INCLUDEPATH += $$PWD/taglib
    INCLUDEPATH += $$PWD/taglib/ape
    INCLUDEPATH += $$PWD/taglib/asf
    INCLUDEPATH += $$PWD/taglib/flac
    INCLUDEPATH += $$PWD/taglib/it
    INCLUDEPATH += $$PWD/taglib/mod
    INCLUDEPATH += $$PWD/taglib/mp4
    INCLUDEPATH += $$PWD/taglib/mpc
    INCLUDEPATH += $$PWD/taglib/mpeg
    INCLUDEPATH += $$PWD/taglib/mpeg/id3v1
    INCLUDEPATH += $$PWD/taglib/mpeg/id3v2
    INCLUDEPATH += $$PWD/taglib/mpeg/id3v2/frames
    INCLUDEPATH += $$PWD/taglib/ogg
    INCLUDEPATH += $$PWD/taglib/ogg/flac
    INCLUDEPATH += $$PWD/taglib/ogg/opus
    INCLUDEPATH += $$PWD/taglib/ogg/speex
    INCLUDEPATH += $$PWD/taglib/ogg/vorbis
    INCLUDEPATH += $$PWD/taglib/riff
    INCLUDEPATH += $$PWD/taglib/riff/aiff
    INCLUDEPATH += $$PWD/taglib/riff/wav
    INCLUDEPATH += $$PWD/taglib/s3m
    INCLUDEPATH += $$PWD/taglib/toolkit
    INCLUDEPATH += $$PWD/taglib/trueaudio
    INCLUDEPATH += $$PWD/taglib/wavpack
    INCLUDEPATH += $$PWD/taglib/xm

SOURCES +=    \
    $$PWD/taglib/ape/apefile.cpp \
    $$PWD/taglib/ape/apefooter.cpp \
    $$PWD/taglib/ape/apeitem.cpp \
    $$PWD/taglib/ape/apeproperties.cpp \
    $$PWD/taglib/ape/apetag.cpp \
    $$PWD/taglib/asf/asfattribute.cpp \
    $$PWD/taglib/asf/asffile.cpp \
    $$PWD/taglib/asf/asfpicture.cpp \
    $$PWD/taglib/asf/asfproperties.cpp \
    $$PWD/taglib/asf/asftag.cpp \
    $$PWD/taglib/flac/flacfile.cpp \
    $$PWD/taglib/flac/flacmetadatablock.cpp \
    $$PWD/taglib/flac/flacpicture.cpp \
    $$PWD/taglib/flac/flacproperties.cpp \
    $$PWD/taglib/flac/flacunknownmetadatablock.cpp \
    $$PWD/taglib/it/itfile.cpp \
    $$PWD/taglib/it/itproperties.cpp \
    $$PWD/taglib/mod/modfile.cpp \
    $$PWD/taglib/mod/modfilebase.cpp \
    $$PWD/taglib/mod/modproperties.cpp \
    $$PWD/taglib/mod/modtag.cpp \
    $$PWD/taglib/mp4/mp4atom.cpp \
    $$PWD/taglib/mp4/mp4coverart.cpp \
    $$PWD/taglib/mp4/mp4file.cpp \
    $$PWD/taglib/mp4/mp4item.cpp \
    $$PWD/taglib/mp4/mp4properties.cpp \
    $$PWD/taglib/mp4/mp4tag.cpp \
    $$PWD/taglib/mpc/mpcfile.cpp \
    $$PWD/taglib/mpc/mpcproperties.cpp \
    $$PWD/taglib/mpeg/id3v1/id3v1genres.cpp \
    $$PWD/taglib/mpeg/id3v1/id3v1tag.cpp \
    $$PWD/taglib/mpeg/id3v2/frames/attachedpictureframe.cpp \
    $$PWD/taglib/mpeg/id3v2/frames/commentsframe.cpp \
    $$PWD/taglib/mpeg/id3v2/frames/generalencapsulatedobjectframe.cpp \
    $$PWD/taglib/mpeg/id3v2/frames/ownershipframe.cpp \
    $$PWD/taglib/mpeg/id3v2/frames/popularimeterframe.cpp \
    $$PWD/taglib/mpeg/id3v2/frames/privateframe.cpp \
    $$PWD/taglib/mpeg/id3v2/frames/relativevolumeframe.cpp \
    $$PWD/taglib/mpeg/id3v2/frames/textidentificationframe.cpp \
    $$PWD/taglib/mpeg/id3v2/frames/uniquefileidentifierframe.cpp \
    $$PWD/taglib/mpeg/id3v2/frames/unknownframe.cpp \
    $$PWD/taglib/mpeg/id3v2/frames/unsynchronizedlyricsframe.cpp \
    $$PWD/taglib/mpeg/id3v2/frames/urllinkframe.cpp \
    $$PWD/taglib/mpeg/id3v2/id3v2extendedheader.cpp \
    $$PWD/taglib/mpeg/id3v2/id3v2footer.cpp \
    $$PWD/taglib/mpeg/id3v2/id3v2frame.cpp \
    $$PWD/taglib/mpeg/id3v2/id3v2framefactory.cpp \
    $$PWD/taglib/mpeg/id3v2/id3v2header.cpp \
    $$PWD/taglib/mpeg/id3v2/id3v2synchdata.cpp \
    $$PWD/taglib/mpeg/id3v2/id3v2tag.cpp \
    $$PWD/taglib/mpeg/mpegfile.cpp \
    $$PWD/taglib/mpeg/mpegheader.cpp \
    $$PWD/taglib/mpeg/mpegproperties.cpp \
    $$PWD/taglib/mpeg/xingheader.cpp \
    $$PWD/taglib/ogg/flac/oggflacfile.cpp \
    $$PWD/taglib/ogg/opus/opusfile.cpp \
    $$PWD/taglib/ogg/opus/opusproperties.cpp \
    $$PWD/taglib/ogg/speex/speexfile.cpp \
    $$PWD/taglib/ogg/speex/speexproperties.cpp \
    $$PWD/taglib/ogg/vorbis/vorbisfile.cpp \
    $$PWD/taglib/ogg/vorbis/vorbisproperties.cpp \
    $$PWD/taglib/ogg/oggfile.cpp \
    $$PWD/taglib/ogg/oggpage.cpp \
    $$PWD/taglib/ogg/oggpageheader.cpp \
    $$PWD/taglib/ogg/xiphcomment.cpp \
    $$PWD/taglib/riff/aiff/aifffile.cpp \
    $$PWD/taglib/riff/aiff/aiffproperties.cpp \
    $$PWD/taglib/riff/wav/infotag.cpp \
    $$PWD/taglib/riff/wav/wavfile.cpp \
    $$PWD/taglib/riff/wav/wavproperties.cpp \
    $$PWD/taglib/riff/rifffile.cpp \
    $$PWD/taglib/s3m/s3mfile.cpp \
    $$PWD/taglib/s3m/s3mproperties.cpp \
    $$PWD/taglib/toolkit/tbytevector.cpp \
    $$PWD/taglib/toolkit/tbytevectorlist.cpp \
    $$PWD/taglib/toolkit/tbytevectorstream.cpp \
    $$PWD/taglib/toolkit/tdebug.cpp \
    $$PWD/taglib/toolkit/tdebuglistener.cpp \
    $$PWD/taglib/toolkit/tfile.cpp \
    $$PWD/taglib/toolkit/tfilestream.cpp \
    $$PWD/taglib/toolkit/tiostream.cpp \
    $$PWD/taglib/toolkit/tpropertymap.cpp \
    $$PWD/taglib/toolkit/trefcounter.cpp \
    $$PWD/taglib/toolkit/tstring.cpp \
    $$PWD/taglib/toolkit/tstringlist.cpp \
    $$PWD/taglib/toolkit/unicode.cpp \
    $$PWD/taglib/trueaudio/trueaudiofile.cpp \
    $$PWD/taglib/trueaudio/trueaudioproperties.cpp \
    $$PWD/taglib/wavpack/wavpackfile.cpp \
    $$PWD/taglib/wavpack/wavpackproperties.cpp \
    $$PWD/taglib/xm/xmfile.cpp \
    $$PWD/taglib/xm/xmproperties.cpp \
    $$PWD/taglib/audioproperties.cpp \
    $$PWD/taglib/fileref.cpp \
    $$PWD/taglib/tag.cpp \
    $$PWD/taglib/tagunion.cpp \

HEADERS += \
    $$PWD/taglib/ape/apefile.h \
    $$PWD/taglib/ape/apefooter.h \
    $$PWD/taglib/ape/apeitem.h \
    $$PWD/taglib/ape/apeproperties.h \
    $$PWD/taglib/ape/apetag.h \
    $$PWD/taglib/asf/asfattribute.h \
    $$PWD/taglib/asf/asffile.h \
    $$PWD/taglib/asf/asfpicture.h \
    $$PWD/taglib/asf/asfproperties.h \
    $$PWD/taglib/asf/asftag.h \
    $$PWD/taglib/flac/flacfile.h \
    $$PWD/taglib/flac/flacmetadatablock.h \
    $$PWD/taglib/flac/flacpicture.h \
    $$PWD/taglib/flac/flacproperties.h \
    $$PWD/taglib/flac/flacunknownmetadatablock.h \
    $$PWD/taglib/it/itfile.h \
    $$PWD/taglib/it/itproperties.h \
    $$PWD/taglib/mod/modfile.h \
    $$PWD/taglib/mod/modfilebase.h \
    $$PWD/taglib/mod/modfileprivate.h \
    $$PWD/taglib/mod/modproperties.h \
    $$PWD/taglib/mod/modtag.h \
    $$PWD/taglib/mp4/mp4atom.h \
    $$PWD/taglib/mp4/mp4coverart.h \
    $$PWD/taglib/mp4/mp4file.h \
    $$PWD/taglib/mp4/mp4item.h \
    $$PWD/taglib/mp4/mp4properties.h \
    $$PWD/taglib/mp4/mp4tag.h \
    $$PWD/taglib/mpc/mpcfile.h \
    $$PWD/taglib/mpc/mpcproperties.h \
    $$PWD/taglib/mpeg/id3v1/id3v1genres.h \
    $$PWD/taglib/mpeg/id3v1/id3v1tag.h \
    $$PWD/taglib/mpeg/id3v2/frames/attachedpictureframe.h \
    $$PWD/taglib/mpeg/id3v2/frames/commentsframe.h \
    $$PWD/taglib/mpeg/id3v2/frames/generalencapsulatedobjectframe.h \
    $$PWD/taglib/mpeg/id3v2/frames/ownershipframe.h \
    $$PWD/taglib/mpeg/id3v2/frames/popularimeterframe.h \
    $$PWD/taglib/mpeg/id3v2/frames/privateframe.h \
    $$PWD/taglib/mpeg/id3v2/frames/relativevolumeframe.h \
    $$PWD/taglib/mpeg/id3v2/frames/textidentificationframe.h \
    $$PWD/taglib/mpeg/id3v2/frames/uniquefileidentifierframe.h \
    $$PWD/taglib/mpeg/id3v2/frames/unknownframe.h \
    $$PWD/taglib/mpeg/id3v2/frames/unsynchronizedlyricsframe.h \
    $$PWD/taglib/mpeg/id3v2/frames/urllinkframe.h \
    $$PWD/taglib/mpeg/id3v2/id3v2extendedheader.h \
    $$PWD/taglib/mpeg/id3v2/id3v2footer.h \
    $$PWD/taglib/mpeg/id3v2/id3v2frame.h \
    $$PWD/taglib/mpeg/id3v2/id3v2framefactory.h \
    $$PWD/taglib/mpeg/id3v2/id3v2header.h \
    $$PWD/taglib/mpeg/id3v2/id3v2synchdata.h \
    $$PWD/taglib/mpeg/id3v2/id3v2tag.h \
    $$PWD/taglib/mpeg/mpegfile.h \
    $$PWD/taglib/mpeg/mpegheader.h \
    $$PWD/taglib/mpeg/mpegproperties.h \
    $$PWD/taglib/mpeg/xingheader.h \
    $$PWD/taglib/ogg/flac/oggflacfile.h \
    $$PWD/taglib/ogg/opus/opusfile.h \
    $$PWD/taglib/ogg/opus/opusproperties.h \
    $$PWD/taglib/ogg/speex/speexfile.h \
    $$PWD/taglib/ogg/speex/speexproperties.h \
    $$PWD/taglib/ogg/vorbis/vorbisfile.h \
    $$PWD/taglib/ogg/vorbis/vorbisproperties.h \
    $$PWD/taglib/ogg/oggfile.h \
    $$PWD/taglib/ogg/oggpage.h \
    $$PWD/taglib/ogg/oggpageheader.h \
    $$PWD/taglib/ogg/xiphcomment.h \
    $$PWD/taglib/riff/aiff/aifffile.h \
    $$PWD/taglib/riff/aiff/aiffproperties.h \
    $$PWD/taglib/riff/wav/infotag.h \
    $$PWD/taglib/riff/wav/wavfile.h \
    $$PWD/taglib/riff/wav/wavproperties.h \
    $$PWD/taglib/riff/rifffile.h \
    $$PWD/taglib/s3m/s3mfile.h \
    $$PWD/taglib/s3m/s3mproperties.h \
    $$PWD/taglib/toolkit/taglib.h \
    $$PWD/taglib/toolkit/tbytevector.h \
    $$PWD/taglib/toolkit/tbytevectorlist.h \
    $$PWD/taglib/toolkit/tbytevectorstream.h \
    $$PWD/taglib/toolkit/tdebug.h \
    $$PWD/taglib/toolkit/tdebuglistener.h \
    $$PWD/taglib/toolkit/tfile.h \
    $$PWD/taglib/toolkit/tfilestream.h \
    $$PWD/taglib/toolkit/tiostream.h \
    $$PWD/taglib/toolkit/tlist.h \
    $$PWD/taglib/toolkit/tmap.h \
    $$PWD/taglib/toolkit/tpropertymap.h \
    $$PWD/taglib/toolkit/trefcounter.h \
    $$PWD/taglib/toolkit/tstring.h \
    $$PWD/taglib/toolkit/tstringlist.h \
    $$PWD/taglib/toolkit/tutils.h \
    $$PWD/taglib/toolkit/unicode.h \
    $$PWD/taglib/trueaudio/trueaudiofile.h \
    $$PWD/taglib/trueaudio/trueaudioproperties.h \
    $$PWD/taglib/wavpack/wavpackfile.h \
    $$PWD/taglib/wavpack/wavpackproperties.h \
    $$PWD/taglib/xm/xmfile.h \
    $$PWD/taglib/xm/xmproperties.h \
    $$PWD/taglib/audioproperties.h \
    $$PWD/taglib/fileref.h \
    $$PWD/taglib/tag.h \
    $$PWD/taglib/taglib_export.h \
    $$PWD/taglib/tagunion.h \
    $$PWD/taglib/config.h \
    $$PWD/taglib/taglib_config.h \
