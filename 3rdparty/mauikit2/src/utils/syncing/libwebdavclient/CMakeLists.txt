cmake_minimum_required(VERSION 3.9)
enable_testing()

file(STRINGS ./VERSION PROJECT_VERSION)

project(
    webdavclient
    VERSION ${PROJECT_VERSION}
    DESCRIPTION "A WebDAV Client library to connect to WebDAV Servers built with QT"
)

# Set Flags
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_INSTALL_PREFIX /usr)
###

# Miscellaneous
include(FeatureSummary)

add_definitions(-DPROJECT_NAME="${PROJECT_NAME}")
add_definitions(-DPROJECT_VERSION="${PROJECT_VERSION}")
###

# Include SubDirectories
add_subdirectory(lib)
add_subdirectory(lib/tests)
###

# CPack Configuration
include(InstallRequiredSystemLibraries)

set(CPACK_GENERATOR "DEB")
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Anupam Basak")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A WebDAV Client library to connect to WebDAV Servers built with QT")
set(CPACK_PACKAGE_VENDOR "Anupam Basak")
set(CPACK_PACKAGE_CONTACT "Anupam Basak <anupam.basak27@gmail.com>")
#set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/ReadMe.txt")
#set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/Copyright.txt")
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
set(CPACK_PACKAGE_INSTALL_DIRECTORY "CMake ${CMake_VERSION_MAJOR}.${CMake_VERSION_MINOR}")
set(CPACK_SOURCE_STRIP_FILES "")

include(CPack)
###

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
