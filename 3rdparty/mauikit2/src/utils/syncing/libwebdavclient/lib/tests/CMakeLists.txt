find_package(
  Qt5
  REQUIRED

  COMPONENTS
    Test
    Network
    Xml
)

set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(
    CPP_SOURCES

    ../WebDAVClient.cpp

    ../dto/WebDAVItem.cpp

    ../utils/NetworkHelper.cpp
    ../utils/WebDAVReply.cpp    
    ../utils/XMLHelper.cpp
    ../utils/Environment.cpp
)

set(
  TEST_SOURCES

  TestWebDAVClient.cpp
)

add_executable(
  ${PROJECT_NAME}_test

  ${TEST_SOURCES}
  ${CPP_SOURCES}
)

target_link_libraries(
    ${PROJECT_NAME}_test

    Qt5::Test
    Qt5::Network
    Qt5::Xml
)

add_test(${PROJECT_NAME}_test ${PROJECT_NAME}_test)
