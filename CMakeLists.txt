project(vvave)
cmake_minimum_required(VERSION 3.0)

find_package(ECM 1.7.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})
set(CMAKE_CXX_STANDARD 17)

find_package(MauiKit REQUIRED)
find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Qml Quick Network WebSockets Sql QuickControls2 Xml Multimedia Widgets DBus Svg)
include(KDEInstallDirs)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDECMakeSettings)
include(ECMInstallIcons)
include(FeatureSummary)
include(ECMAddAppIcon)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTORCC ON)

add_executable(vvave
    qml.qrc
    main.cpp
#    babe.cpp
    vvave.cpp

#    pulpo/services/geniusService.cpp
#    pulpo/services/deezerService.cpp
    pulpo/services/lastfmService.cpp
#    pulpo/services/lyricwikiaService.cpp
#    pulpo/services/spotifyService.cpp
#    pulpo/services/musicbrainzService.cpp
    pulpo/pulpo.cpp
    pulpo/htmlparser.cpp
    pulpo/service.cpp
    services/local/taginfo.cpp
    services/local/player.cpp
    services/local/youtubedl.cpp
#    services/local/linking.cpp
    services/local/socket.cpp
#    services/web/babeit.cpp
    services/web/youtube.cpp
#    services/web/Spotify/spotify.cpp
    db/collectionDB.cpp
#    settings/BabeSettings.cpp
#    settings/fileloader.cpp
#    utils/brain.cpp
#    utils/babeconsole.cpp
    models/tracks/tracksmodel.cpp
    models/basemodel.cpp
    models/baselist.cpp
    models/playlists/playlistsmodel.cpp
    models/albums/albumsmodel.cpp
#    models/cloud/cloud.cpp
    )

if (ANDROID)
    find_package(Qt5 REQUIRED COMPONENTS AndroidExtras WebView Xml)
    find_package(OpenSSL REQUIRED)

    include(ExternalProject)
    externalproject_add(taglib
        URL http://taglib.org/releases/taglib-1.11.1.tar.gz
        CMAKE_ARGS -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}
        )
    set(TAGLIB_INCLUDE_DIRS ${CMAKE_INSTALL_PREFIX}/include ${CMAKE_INSTALL_PREFIX}/include/taglib)
    set(TAGLIB_LIBRARIES ${CMAKE_INSTALL_PREFIX}/${LIB_INSTALL_DIR}/libtag.a)

    target_link_libraries(vvave Qt5::AndroidExtras Qt5::WebView Qt5::Xml OpenSSL::SSL)
    add_dependencies(vvave taglib)
    kde_source_files_enable_exceptions(vvave babe.cpp)
else()
    find_package(Taglib REQUIRED)
    find_package(Qt5 REQUIRED COMPONENTS WebEngine)
    find_package(KF5 ${KF5_VERSION} REQUIRED COMPONENTS I18n Notifications Config KIO Attica)
    target_sources(vvave PRIVATE
        kde/mpris2.cpp
        kde/notify.cpp
        )
    target_link_libraries(vvave Qt5::WebEngine KF5::ConfigCore KF5::Notifications KF5::KIOCore KF5::I18n Qt5::DBus KF5::Attica)
endif()

if (TARGET create-apk-vvave)
    set_target_properties(create-apk-vvave PROPERTIES ANDROID_APK_DIR "${MAUIKIT_ANDROID_DIR}")
endif()

target_include_directories(vvave PRIVATE ${TAGLIB_INCLUDE_DIRS})
target_link_libraries(vvave MauiKit Qt5::Network Qt5::Sql Qt5::WebSockets Qt5::Qml Qt5::Xml Qt5::Multimedia Qt5::Widgets Qt5::QuickControls2 ${TAGLIB_LIBRARIES})

install(TARGETS vvave ${KDE_INSTALL_TARGETS_DEFAULT_ARGS})
install(FILES org.kde.vvave.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})

#TODO: port to ecm_install_icons()
install(FILES assets/vvave.svg DESTINATION ${KDE_INSTALL_ICONDIR}/hicolor/scalable/apps)
install(FILES org.kde.vvave.appdata.xml DESTINATION ${KDE_INSTALL_METAINFODIR})

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
