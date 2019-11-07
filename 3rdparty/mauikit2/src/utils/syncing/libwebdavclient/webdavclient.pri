VERSION = $$cat($$PWD/VERSION)

QT *= \
  core \ 
  xml \
  network \
  testlib

CONFIG += c++11

HEADERS += \
  $$PWD/lib/WebDAVClient.hpp \
  $$PWD/lib/utils/XMLHelper.hpp \
  $$PWD/lib/utils/WebDAVReply.hpp \
  $$PWD/lib/utils/NetworkHelper.hpp \
  $$PWD/lib/utils/Environment.hpp \
  $$PWD/lib/dto/WebDAVItem.hpp

SOURCES += \
  $$PWD/lib/WebDAVClient.cpp \  
  $$PWD/lib/utils/NetworkHelper.cpp \
  $$PWD/lib/utils/Environment.cpp \
  $$PWD/lib/utils/XMLHelper.cpp \
  $$PWD/lib/utils/WebDAVReply.cpp \  
  $$PWD/lib/dto/WebDAVItem.cpp 
  
INCLUDEPATH += \
  $$PWD/lib \
  $$PWD/lib/utils \
  $$PWD/lib/dto
