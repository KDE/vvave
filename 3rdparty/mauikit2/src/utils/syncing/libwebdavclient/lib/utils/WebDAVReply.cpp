#include <QByteArray>
#include <QList>
#include <QNetworkReply>
#include <QSslError>

#include "WebDAVReply.hpp"

void WebDAVReply::sendListDirResponseSignal(QNetworkReply* listDirReply,
                                            QList<WebDAVItem> items) {
  emit listDirResponse(listDirReply, items);
}

void WebDAVReply::sendDownloadResponseSignal(QNetworkReply* downloadReply) {
  emit downloadResponse(downloadReply);
}

void WebDAVReply::sendDownloadProgressResponseSignal(qint64 bytesReceived,
                                                     qint64 bytesTotal) {
  emit downloadProgressResponse(bytesReceived, bytesTotal);
}

void WebDAVReply::sendUploadFinishedResponseSignal(QNetworkReply* uploadReply) {
  emit uploadFinished(uploadReply);
}

void WebDAVReply::sendDirCreatedResponseSignal(QNetworkReply* createDirReply) {
  emit createDirFinished(createDirReply);
}

void WebDAVReply::sendCopyResponseSignal(QNetworkReply* copyReply) {
  emit copyFinished(copyReply);
}

void WebDAVReply::sendMoveResponseSignal(QNetworkReply* moveReply) {
  emit moveFinished(moveReply);
}

void WebDAVReply::sendRemoveResponseSignal(QNetworkReply* removeReply) {
  emit removeFinished(removeReply);
}

void WebDAVReply::sendError(QNetworkReply::NetworkError err) {
  emit error(err);
}
