#ifndef WEBDAVCLIENT_HPP
#define WEBDAVCLIENT_HPP

#include <QIODevice>
#include <QList>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QSslError>
#include <QString>

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

#include "utils/NetworkHelper.hpp"
#include "utils/WebDAVReply.hpp"
#include "utils/XMLHelper.hpp"

enum ListDepthEnum { Zero, One, Two, Infinity };

#ifdef STATIC_MAUIKIT
class WebDAVClient : public QObject
#else
class MAUIKIT_EXPORT WebDAVClient : public QObject
#endif 
{
  Q_OBJECT

 public:
  WebDAVClient(QString host, QString username, QString password);

  WebDAVReply* listDir(QString path = "/");
  WebDAVReply* listDir(QString path, ListDepthEnum depth);

  WebDAVReply* downloadFrom(QString path);
  WebDAVReply* downloadFrom(QString path, qint64 startByte, qint64 endByte);

  WebDAVReply* uploadTo(QString path, QString filename, QIODevice* file);

  WebDAVReply* createDir(QString path, QString dirName);

  WebDAVReply* copy(QString source, QString destination);

  WebDAVReply* move(QString source, QString destination,
                    bool overwrite = false);

  WebDAVReply* remove(QString path);

  ~WebDAVClient();

 private:
  NetworkHelper* networkHelper;
  XMLHelper* xmlHelper;

  void errorReplyHandler(WebDAVReply* reply, QNetworkReply::NetworkError err);
};

#endif
