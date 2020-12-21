# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

cmake_minimum_required(VERSION 3.14)

set(VVAVE_VERSION 1.2.1)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

project(vvave VERSION ${VVAVE_VERSION})

set(REQUIRED_QT_VERSION 5.10.0)
set(REQUIRED_KF5_VERSION 5.60)

find_package(ECM ${REQUIRED_KF5_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

find_package(MauiKit REQUIRED)

find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS Qml Quick Network Sql QuickControls2 Xml Multimedia Svg Concurrent)

find_package(KF5 ${REQUIRED_KF5_VERSION} REQUIRED COMPONENTS I18n CoreAddons)

if(ANDROID)
    find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS AndroidExtras)
    set(ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android_files)
    set(ANDROID_ABIS "armeabi-v7a")
elseif(UNIX)
    find_package(Qt5 ${REQUIRED_QT_VERSION} REQUIRED NO_MODULE COMPONENTS DBus)
    find_package(KF5 ${REQUIRED_KF5_VERSION} REQUIRED COMPONENTS Config KIO)
endif()

if(UNIX AND NOT APPLE AND NOT ANDROID)
    include(KDEInstallDirs)
    include(KDECMakeSettings)
    include(ECMInstallIcons)
    include(ECMAddAppIcon)
endif()

include(KDECompilerSettings NO_POLICY_SCOPE)
include(ECMSetupVersion)
include(FeatureSummary)

ecm_setup_version(${VVAVE_VERSION}
    VARIABLE_PREFIX VVAVE
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/vvave_version.h"
    )

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)

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
    services/web/NextCloud/nextmusic.cpp
    services/web/abstractmusicprovider.cpp
    db/collectionDB.cpp
    models/tracks/tracksmodel.cpp
    models/playlists/playlistsmodel.cpp
    models/albums/albumsmodel.cpp
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
    find_package(Taglib REQUIRED)
    target_sources(vvave PRIVATE
        kde/mpris2/mediaplayer2.cpp
        kde/mpris2/mediaplayer2player.cpp
        )

    target_link_libraries(vvave KF5::ConfigCore KF5::KIOCore Qt5::DBus)
endif()

target_compile_definitions(vvave
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_include_directories(vvave PRIVATE ${TAGLIB_INCLUDE_DIRS})
target_link_libraries(vvave MauiKit Qt5::Network Qt5::Sql Qt5::Qml Qt5::Xml Qt5::Multimedia Qt5::QuickControls2 KF5::CoreAddons KF5::I18n ${TAGLIB_LIBRARIES})

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS vvave ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES org.kde.vvave.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

    #TODO: port to ecm_install_icons()
    install(FILES assets/vvave.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
    install(FILES org.kde.vvave.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

    feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
endif()
