# Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
# Copyright 2018-2020 Nitrux Latinoamericana S.C.
#
# SPDX-License-Identifier: GPL-3.0-or-later

remove_definitions(-DQT_NO_CAST_FROM_ASCII -DQT_STRICT_ITERATORS -DQT_NO_CAST_FROM_BYTEARRAY)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/services/web)

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
    services/local/powermanagementinterface.cpp
    # services/web/NextCloud/nextmusic.cpp
    # services/web/abstractmusicprovider.cpp
    db/collectionDB.cpp
    models/tracks/tracksmodel.cpp
    models/playlists/playlistsmodel.cpp
    models/albums/albumsmodel.cpp
    models/folders/foldersmodel.cpp
    # models/cloud/cloud.cpp
    kde/mpris2/mpris2.cpp
    kde/server.cpp)

qt_add_resources(vvave_QML_QRC
    assets.qrc)

if(UNIX AND NOT ANDROID)
    qt_generate_dbus_interface(${CMAKE_CURRENT_SOURCE_DIR}/kde/server.h org.kde.Vvave.xml)
    qt_add_dbus_adaptor(vvave_dbus_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.Vvave.xml kde/server.h Server)
    qt_add_dbus_interface(vvave_dbus_SRCS ${CMAKE_CURRENT_BINARY_DIR}/org.kde.Vvave.xml vvaveinterface)
endif()

if(ANDROID)
    include(/home/camilo/Android/Sdk/android_openssl/android_openssl.cmake)

    qt_add_executable(${PROJECT_NAME}
        MANUAL_FINALIZATION
        ${vvave_SRCS}
        ${vvave_QML_QRC})

    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android_files)
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/android_files/version.gradle.in ${CMAKE_BINARY_DIR}/src/version.gradle)

    add_android_openssl_libraries(${PROJECT_NAME})
    # set_property(TARGET ${PROJECT_NAME} PROPERTY QT_ANDROID_EXTRA_LIBS
    #     /home/camilo/Android/Sdk/android_openssl/ libcrypto_1_1.so
    #     /home/camilo/Android/Sdk/android_openssl/libssl_1_1.so)
else()
    qt_add_executable(${PROJECT_NAME}
        ${vvave_SRCS}
        ${vvave_dbus_SRCS}
        ${vvave_QML_QRC})
endif()

set_source_files_properties(utils/Player.js PROPERTIES QT_QML_SKIP_QMLDIR_ENTRY TRUE)
set_source_files_properties(db/Queries.js PROPERTIES QT_QML_SKIP_QMLDIR_ENTRY TRUE)

qt_add_qml_module(${PROJECT_NAME} URI app.maui.vvave
    NO_PLUGIN
    QML_FILES
    main.qml
    widgets/TracksView.qml
    widgets/AlbumsView.qml
    widgets/MainPlaylist/MainPlaylist.qml
    widgets/PlaylistsView/PlaylistsView.qml
    widgets/InfoView/InfoView.qml
    widgets/InfoView/LyricsView.qml
    widgets/PlaylistsView/PlaylistsViewModel.qml
    widgets/FloatingDisk.qml
    widgets/CloudView/CloudView.qml
    widgets/SelectionBar.qml
    widgets/FocusView.qml
    widgets/SettingsView/SettingsDialog.qml
    widgets/SettingsView/ShortcutsDialog.qml
    widgets/PlaybackBar.qml
    widgets/FoldersView/FoldersView.qml
    widgets/MetadataDialog.qml
    widgets/BabeTable/TableDelegate.qml
    widgets/BabeTable/TableMenu.qml
    widgets/BabeTable/BabeTable.qml
    widgets/BabeGrid/BabeGrid.qml
    widgets/MiniMode.qml
    widgets/TracksGroup.qml
    widgets/SleepTimerDialog.qml

    utils/Player.js
    db/Queries.js)

if (ANDROID)
    find_package(OpenSSL REQUIRED)

    target_link_libraries(${PROJECT_NAME}
        PRIVATE
        OpenSSL::SSL)

    kde_source_files_enable_exceptions(${PROJECT_NAME})

    set(Taglib_LIBRARIES
        TagLib::tag)

elseif(UNIX AND NOT WIN32 AND NOT APPLE)
    target_sources(${PROJECT_NAME}
        PRIVATE
        kde/mpris2/mediaplayer2.cpp
        kde/mpris2/mediaplayer2player.cpp)

    target_link_libraries(${PROJECT_NAME}
        PRIVATE
        Qt6::DBus)

    set(Taglib_LIBRARIES
        Taglib::Taglib)
endif()

if(UNIX OR WIN32 OR APPLE AND NOT ANDROID)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE
        Qt6::Widgets)
endif()

target_compile_definitions(${PROJECT_NAME}
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

target_include_directories(${PROJECT_NAME} PRIVATE ${Taglib_INCLUDE_DIRS})

target_link_libraries(${PROJECT_NAME}
    PRIVATE
    MauiKit4
    MauiKit4::FileBrowsing
    Qt6::Core
    Qt6::Network
    Qt6::Sql
    Qt6::Qml
    Qt6::Xml
    Qt6::Multimedia
    Qt6::QuickControls2
    KF6::CoreAddons
    KF6::I18n
    ${Taglib_LIBRARIES})

if(UNIX AND NOT APPLE AND NOT ANDROID)
    install(TARGETS ${PROJECT_NAME} ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
    install(FILES assets/vvave.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
endif()

qt_finalize_target(${PROJECT_NAME})
