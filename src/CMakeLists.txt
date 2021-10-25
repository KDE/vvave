# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/services/web
    ${CMAKE_CURRENT_BINARY_DIR}/services/web
    )

set(vvave_SRCS
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

if(QUICK_COMPILER)
        qtquick_compiler_add_resources(vvave_QML_QRC qml.qrc)
else()
        qt5_add_resources(vvave_QML_QRC qml.qrc)
endif()

if(ANDROID)
    add_library(${PROJECT_NAME} SHARED
        ${vvave_SRCS}
        ${vvave_QML_QRC}
        )
else()
    add_executable(${PROJECT_NAME}
        ${vvave_SRCS}
        ${vvave_QML_QRC}
        )
endif()

if (ANDROID)
    find_package(OpenSSL REQUIRED)

    target_link_libraries(${PROJECT_NAME} Qt5::AndroidExtras OpenSSL::SSL)
    kde_source_files_enable_exceptions(${PROJECT_NAME})
elseif(UNIX AND NOT WIN32 AND NOT APPLE)
    target_sources(${PROJECT_NAME} PRIVATE
        kde/mpris2/mediaplayer2.cpp
        kde/mpris2/mediaplayer2player.cpp
        )
    target_link_libraries(${PROJECT_NAME} Qt5::DBus)
endif()

if(UNIX OR WIN32 OR APPLE AND NOT ANDROID)
    target_link_libraries(${PROJECT_NAME} Qt5::Widgets)
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_include_directories(${PROJECT_NAME} PRIVATE ${Taglib_INCLUDE_DIRS})

target_link_libraries(${PROJECT_NAME} MauiKit MauiKit::FileBrowsing MauiKit::Accounts Qt5::Core Qt5::Network Qt5::Sql Qt5::Qml Qt5::Xml Qt5::Multimedia Qt5::QuickControls2 KF5::CoreAddons KF5::I18n ${Taglib_LIBRARIES})

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES assets/vvave.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()

