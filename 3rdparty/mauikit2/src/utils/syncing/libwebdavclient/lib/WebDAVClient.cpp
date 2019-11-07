#include <QAuthenticator>
#include <QByteArray>
#include <QDebug>
#include <QHttpMultiPart>
#include <QList>
#include <QMap>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QRegularExpression>
#include <QSslError>
#include <string>

#include "WebDAVClient.hpp"
#include "utils/NetworkHelper.hpp"
#include "utils/WebDAVReply.hpp"

WebDAVClient::WebDAVClient(QString host, QString username, QString password) {
  this->networkHelper = new NetworkHelper(host, username, password);
  this->xmlHelper = new XMLHelper();

  // TODO: Check for Timeout error in case of wrong host
}

WebDAVReply* WebDAVClient::listDir(QString path) {
  return this->listDir(path, ListDepthEnum::Infinity);
}

WebDAVReply* WebDAVClient::listDir(QString path, ListDepthEnum depth) {
  WebDAVReply* reply = new WebDAVReply();
  QString depthVal;
  QMap<QString, QString> headers;
  QNetworkReply* listDirReply;

  switch (depth) {
    case ListDepthEnum::Zero:
      depthVal = "0";
      break;

    case ListDepthEnum::One:
      depthVal = "1";
      break;

    case ListDepthEnum::Two:
      depthVal = "2";
      break;

    case ListDepthEnum::Infinity:
      depthVal = "infinity";
      break;

    default:
      break;
  }

  headers.insert("Depth", depthVal);

  listDirReply =
      this->networkHelper->makeRequest(QString("PROPFIND"), path, headers);

  connect(listDirReply, &QNetworkReply::finished, [=]() {
    reply->sendListDirResponseSignal(
        listDirReply,
        this->xmlHelper->parseListDirResponse(this, listDirReply->readAll()));
  });
  connect(listDirReply,
          QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
          [=](QNetworkReply::NetworkError err) {
            this->errorReplyHandler(reply, err);
          });

  return reply;
}

WebDAVReply* WebDAVClient::downloadFrom(QString path) {
  return this->downloadFrom(path, 0, -1);
}

WebDAVReply* WebDAVClient::downloadFrom(QString path, qint64 startByte,
                                        qint64 endByte) {
  WebDAVReply* reply = new WebDAVReply();
  QString rangeVal;
  QTextStream stream(&rangeVal);
  QMap<QString, QString> headers;
  QNetworkReply* downloadReply;

  stream << "bytes=" << startByte << "-" << endByte;

  headers.insert("Range", rangeVal);

  downloadReply = this->networkHelper->makeRequest("GET", path, headers);

  connect(downloadReply, &QNetworkReply::finished,
          [=]() { reply->sendDownloadResponseSignal(downloadReply); });
  connect(
      downloadReply, &QNetworkReply::downloadProgress,
      [=](qint64 bytesReceived, qint64 bytesTotal) {
        if (bytesTotal == -1) {
          QString contentRange = QString(downloadReply->rawHeader(
              QByteArray::fromStdString("Content-Range")));
          QRegularExpression re("bytes (\\d*)-(\\d*)/(\\d*)");
          QRegularExpressionMatch match = re.match(contentRange);
          qint64 contentSize =
              match.captured(2).toInt() - match.captured(1).toInt();

          reply->sendDownloadProgressResponseSignal(bytesReceived, contentSize);
        } else {
          reply->sendDownloadProgressResponseSignal(bytesReceived, bytesTotal);
        }
      });
  connect(downloadReply,
          QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
          [=](QNetworkReply::NetworkError err) {
            this->errorReplyHandler(reply, err);
          });

  return reply;
}

WebDAVReply* WebDAVClient::uploadTo(QString path, QString filename,
                                    QIODevice* file) {
  WebDAVReply* reply = new WebDAVReply();
  QMap<QString, QString> headers;
  QNetworkReply* uploadReply;

  uploadReply =
      this->networkHelper->makePutRequest(path + "/" + filename, headers, file);

  connect(uploadReply, &QNetworkReply::finished,
          [=]() { reply->sendUploadFinishedResponseSignal(uploadReply); });

  connect(uploadReply,
          QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
          [=](QNetworkReply::NetworkError err) {
            this->errorReplyHandler(reply, err);
          });

  return reply;
}

WebDAVReply* WebDAVClient::createDir(QString path, QString dirName) {
  WebDAVReply* reply = new WebDAVReply();
  QMap<QString, QString> headers;
  QNetworkReply* createDirReply;

  createDirReply =
      this->networkHelper->makeRequest("MKCOL", path + "/" + dirName, headers);

  connect(createDirReply, &QNetworkReply::finished,
          [=]() { reply->sendDirCreatedResponseSignal(createDirReply); });

  connect(createDirReply,
          QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
          [=](QNetworkReply::NetworkError err) {
            this->errorReplyHandler(reply, err);
          });

  return reply;
}

WebDAVReply* WebDAVClient::copy(QString source, QString destination) {
  WebDAVReply* reply = new WebDAVReply();
  QMap<QString, QString> headers;
  QNetworkReply* copyReply;

  headers.insert("Destination", destination);

  copyReply = this->networkHelper->makeRequest("COPY", source, headers);

  connect(copyReply, &QNetworkReply::finished,
          [=]() { reply->sendCopyResponseSignal(copyReply); });

  connect(copyReply,
          QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
          [=](QNetworkReply::NetworkError err) {
            this->errorReplyHandler(reply, err);
          });

  return reply;
}

WebDAVReply* WebDAVClient::move(QString source, QString destination,
                                bool overwrite) {
  WebDAVReply* reply = new WebDAVReply();
  QMap<QString, QString> headers;
  QNetworkReply* moveReply;
  QString overwriteVal = overwrite ? "T" : "F";

  headers.insert("Destination", destination);
  headers.insert("Overwrite", overwriteVal);

  moveReply = this->networkHelper->makeRequest("MOVE", source, headers);

  connect(moveReply, &QNetworkReply::finished,
          [=]() { reply->sendMoveResponseSignal(moveReply); });

  connect(moveReply,
          QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
          [=](QNetworkReply::NetworkError err) {
            this->errorReplyHandler(reply, err);
          });

  return reply;
}

WebDAVReply* WebDAVClient::remove(QString path) {
  WebDAVReply* reply = new WebDAVReply();
  QMap<QString, QString> headers;
  QNetworkReply* removeReply;

  removeReply = this->networkHelper->makeRequest("DELETE", path, headers);

  connect(removeReply, &QNetworkReply::finished,
          [=]() { reply->sendRemoveResponseSignal(removeReply); });

  connect(removeReply,
          QOverload<QNetworkReply::NetworkError>::of(&QNetworkReply::error),
          [=](QNetworkReply::NetworkError err) {
            this->errorReplyHandler(reply, err);
          });

  return reply;
}

void WebDAVClient::errorReplyHandler(WebDAVReply* reply,
                                     QNetworkReply::NetworkError err) {
  reply->sendError(err);
}

WebDAVClient::~WebDAVClient() {
  this->networkHelper->deleteLater();
  delete this->xmlHelper;
}
