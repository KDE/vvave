#include <QByteArray>
#include <QDebug>
#include <QList>
#include <QtXml/QDomDocument>

#include "../dto/WebDAVItem.hpp"
#include "XMLHelper.hpp"

QList<WebDAVItem> XMLHelper::parseListDirResponse(WebDAVClient *webdavClient,
                                                  QByteArray xml) {
  QList<WebDAVItem> items;
  QString webdavNS = "DAV:";
  QDomDocument doc;
  doc.setContent(xml, true);

  QDomNodeList responses = doc.elementsByTagNameNS(webdavNS, "response");

  for (int i = 0; i < responses.length(); i++) {
    QDomElement response = responses.at(i).toElement();

    QString href =
        response.elementsByTagNameNS(webdavNS, "href").at(0).toElement().text();
    QString creationDate =
        response.elementsByTagNameNS(webdavNS, "creationdate")
            .at(0)
            .toElement()
            .text();
    QString lastModified =
        response.elementsByTagNameNS(webdavNS, "getlastmodified")
            .at(0)
            .toElement()
            .text();
    QString displayName = response.elementsByTagNameNS(webdavNS, "displayname")
                              .at(0)
                              .toElement()
                              .text();
    QString contentType =
        response.elementsByTagNameNS(webdavNS, "getcontenttype")
            .at(0)
            .toElement()
            .text();
    QString contentLength =
        response.elementsByTagNameNS(webdavNS, "getcontentlength")
            .at(0)
            .toElement()
            .text();
    bool isCollection;

    if (response.elementsByTagNameNS(webdavNS, "resourcetype")
            .at(0)
            .toElement()
            .elementsByTagNameNS(webdavNS, "collection")
            .size() == 1) {
      isCollection = true;
    } else {
      isCollection = false;
    }

    items.append(WebDAVItem(webdavClient, href, creationDate, lastModified,
                            displayName, contentType, contentLength,
                            isCollection));
  }

  return items;
}
