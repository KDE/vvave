# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/services/web
    ${CMAKE_CURRENT_BINARY_DIR}/services/web
    )

set(vvave_SRCS
    qml.qrc
    main.cpp
    vvave.cpp
#    pulpo/services/geniusService.cpp
#    pulpo/services/deezerService.cpp
    pulpo/services/lastfmService.cpp
#    pulpo/services/lyricwikiaService.cpp
    pulpo/services/spotifyService.cpp
#    pulpo/services/musicbrainzService.cpp
    pulpo/pulpo.cpp
    pulpo/service.cpp
    services/local/taginfo.cpp
    services/local/artworkprovider.cpp
    services/local/player.cpp
    services/local/playlist.cpp
    services/local/trackinfo.cpp
    services/local/metadataeditor.cpp
    services/web/NextCloud/nextmusic.cpp
    services/web/abstractmusicprovider.cpp
    db/collectionDB.cpp
    models/tracks/tracksmodel.cpp
    models/playlists/playlistsmodel.cpp
    models/albums/albumsmodel.cpp
    models/folders/foldersmodel.cpp
    models/cloud/cloud.cpp
    kde/mpris2/mpris2.cpp
    )

if(ANDROID)
    add_library(vvave SHARED
        ${vvave_SRCS}
        )
else()
    add_executable(vvave
        ${vvave_SRCS}
        )
endif()

if (ANDROID)
    find_package(OpenSSL REQUIRED)
#    include(ExternalProject)
#    externalproject_add(taglib
#        URL http://taglib.org/releases/taglib-1.11.1.tar.gz
#        CMAKE_ARGS -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
#        )

    set(LOCAL_TAGLIB_DIR "/home/camilo/Qt5152/5.15.2/android")
    set(TAGLIB_INCLUDE_DIRS ${LOCAL_TAGLIB_DIR}/include ${LOCAL_TAGLIB_DIR}/include/taglib)
    set(TAGLIB_LIBRARIES ${LOCAL_TAGLIB_DIR}/lib/libtag.so ${LOCAL_TAGLIB_DIR}/lib/libtag_c.so)

    target_link_libraries(vvave Qt5::AndroidExtras OpenSSL::SSL)
#    add_dependencies(vvave taglib)
    kde_source_files_enable_exceptions(vvave)
else()

    find_package(Taglib 1.4 REQUIRED)

    if(Taglib_FOUND)
        message(STATUS "FOUDN TAG LIB" ${Taglib_VERSION}  ${Taglib_INCLUDE_DIRS})
        include_directories( ${Taglib_INCLUDE_DIRS} )
    endif()

    target_sources(vvave PRIVATE
        kde/mpris2/mediaplayer2.cpp
        kde/mpris2/mediaplayer2player.cpp
        )

    target_link_libraries(vvave KF5::ConfigCore KF5::KIOCore Qt5::DBus)
endif()

target_compile_definitions(vvave
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_include_directories(vvave PRIVATE ${Taglib_INCLUDE_DIRS})

target_link_libraries(vvave MauiKit Qt5::Network Qt5::Sql Qt5::Qml Qt5::Xml Qt5::Multimedia Qt5::QuickControls2 KF5::CoreAddons KF5::I18n ${Taglib_LIBRARIES})

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS vvave ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES assets/vvave.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()

