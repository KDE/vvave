#include <QDateTime>
#include <QDebug>
#include <QIODevice>
#include <QString>
#include <QTextStream>

#include "../WebDAVClient.hpp"
#include "../utils/WebDAVReply.hpp"
#include "WebDAVItem.hpp"

WebDAVItem::WebDAVItem(WebDAVClient* webdavClient, QString href,
                       QString creationDate, QString lastModified,
                       QString displayName, QString contentType,
                       QString contentLength, bool isCollection) {
  this->webdavClient = webdavClient;
  this->href = href;
  this->creationDate =
      QDateTime::fromString(creationDate, Qt::DateFormat::ISODate);
  this->lastModified = lastModified;
  this->displayName = displayName;
  this->contentType = contentType;
  this->contentLength = contentLength.toInt();
  this->flagIsCollection = isCollection;
}

bool WebDAVItem::isCollection() { return this->flagIsCollection; }

bool WebDAVItem::isFile() { return !this->flagIsCollection; }

WebDAVReply* WebDAVItem::download() {
  return this->webdavClient->downloadFrom(this->href);
}

WebDAVReply* WebDAVItem::upload(QString filename, QIODevice* file) {
  return this->webdavClient->uploadTo(this->href, filename, file);
}

WebDAVReply* WebDAVItem::createDir(QString dirName) {
  return this->webdavClient->createDir(this->href, dirName);
}

WebDAVReply* WebDAVItem::copy(QString destination) {
  return this->webdavClient->copy(this->href, destination);
}

WebDAVReply* WebDAVItem::move(QString destination, bool overwrite) {
  return this->webdavClient->move(this->href, destination, overwrite);
}

WebDAVReply* WebDAVItem::remove() {
  return this->webdavClient->remove(this->href);
}

WebDAVReply* WebDAVItem::listDir() {
  return this->webdavClient->listDir(this->href);
}

QString WebDAVItem::toString() {
  QString s;
  QTextStream out(&s);

  out << "HREF            : " << this->href << "," << endl
      << "CREATION_DATE   : " << this->creationDate.toString() << "," << endl
      << "LAST_MODIFIED   : " << this->lastModified << "," << endl
      << "DISPLAY_NAME    : " << this->displayName << "," << endl
      << "CONTENT_TYPE    : " << this->contentType << "," << endl
      << "CONTENT_LENGTH  : " << this->contentLength << "," << endl
      << "IS_COLLECTION   : " << this->flagIsCollection;

  return s;
}

QString WebDAVItem::getHref() { return this->href; }

QDateTime WebDAVItem::getCreationDate() { return this->creationDate; }

QString WebDAVItem::getLastModified() { return this->lastModified; }

QString WebDAVItem::getDisplayName() { return this->displayName; }

QString WebDAVItem::getContentType() { return this->contentType; }

int WebDAVItem::getContentLength() { return this->contentLength; }
