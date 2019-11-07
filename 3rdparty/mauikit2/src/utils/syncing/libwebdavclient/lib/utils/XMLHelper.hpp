#ifndef UTILS_XMLHELPER_HPP
#define UTILS_XMLHELPER_HPP

#include <QByteArray>
#include <QList>

#include "../dto/WebDAVItem.hpp"

class WebDAVClient;

class XMLHelper {
 public:
  QList<WebDAVItem> parseListDirResponse(WebDAVClient *webdavClient,
                                         QByteArray xml);
};

#endif
