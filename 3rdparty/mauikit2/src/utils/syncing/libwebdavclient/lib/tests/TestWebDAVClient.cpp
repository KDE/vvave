#ifndef TEST_TESTWEBDAVCLIENT
#define TEST_TESTWEBDAVCLIENT

#include <QCoreApplication>
#include <QList>
#include <QObject>
#include <QTest>

#include "../WebDAVClient.hpp"
#include "../dto/WebDAVItem.hpp"
#include "../utils/Environment.hpp"
#include "../utils/WebDAVReply.hpp"

class TestWebDAVClient : public QObject {
  Q_OBJECT

 private:
  QCoreApplication *app;
  WebDAVClient *client;

  void listDirOutputHandler(WebDAVReply *reply) {
    connect(reply, &WebDAVReply::listDirResponse,
            [=](QNetworkReply *listDirReply, QList<WebDAVItem> items) {
              qDebug() << "URL :" << listDirReply->url();
              qDebug() << "Received List of" << items.length() << "items";
              qDebug() << endl << "---------------------------------------";

              for (WebDAVItem item : items) {
                qDebug().noquote() << endl << item.toString();
                qDebug() << endl << "---------------------------------------";
              }

              QCoreApplication::exit(0);
            });
    connect(reply, &WebDAVReply::error, [=](QNetworkReply::NetworkError err) {
      qDebug() << err;
      QCoreApplication::exit(1);
    });
  }

 private slots:
  void initTestCase() {
    int argc = 1;
    char *argv[] = {"test"};

    this->app = new QCoreApplication(argc, argv);
    this->client =
        new WebDAVClient(Environment::get("LIBWEBDAV_TEST_HOST"),
                         Environment::get("LIBWEBDAV_TEST_USER"),
                         Environment::get("LIBWEBDAV_TEST_PASSWORD"));
  }

  void testListDir() {
    this->listDirOutputHandler(
        this->client->listDir(Environment::get("LIBWEBDAV_TEST_PATH")));
    this->app->exec();
  }

  void testListDirWithDepth() {
    this->listDirOutputHandler(this->client->listDir(
        Environment::get("LIBWEBDAV_TEST_PATH"), ListDepthEnum::One));

    this->app->exec();
  }

  void testDownload() {
    QString url = "/remote.php/webdav/Nextcloud%20Manual.pdf";

    WebDAVReply *reply = this->client->downloadFrom(url);

    connect(reply, &WebDAVReply::downloadResponse, [=](QNetworkReply *reply) {
      if (!reply->error()) {
        qDebug() << "\nDownload Success"
                 << "\nURL  :" << reply->url() << "\nSize :" << reply->size();
      } else {
        qDebug() << "ERROR(DOWNLOAD)" << reply->error();
      }
      QCoreApplication::exit(0);
    });
    connect(reply, &WebDAVReply::downloadProgressResponse,
            [=](qint64 bytesReceived, qint64 bytesTotal) {
              int percent = ((float)bytesReceived / bytesTotal) * 100;

              qDebug() << "\nReceived : " << bytesReceived
                       << "\nTotal    : " << bytesTotal
                       << "\nPercent  : " << percent;
            });
    connect(reply, &WebDAVReply::error, [=](QNetworkReply::NetworkError err) {
      qDebug() << "ERROR" << err;
      QCoreApplication::exit(1);
    });

    this->app->exec();
  }

  void testUpload() {
    QString url = Environment::get("LIBWEBDAV_TEST_PATH");
    QFile file("/home/anupam/libwebdav/lib/WebDAVClient.cpp");
    file.open(QIODevice::ReadOnly);

    WebDAVReply *reply = this->client->uploadTo(url, "tttt.cpp", &file);

    connect(reply, &WebDAVReply::uploadFinished, [=](QNetworkReply *reply) {
      if (!reply->error()) {
        qDebug() << "\nUpload Success"
                 << "\nURL  :" << reply->url() << "\nSize :" << reply->size();
      } else {
        qDebug() << "ERROR(UPLOAD)" << reply->error();
      }
      QCoreApplication::exit(0);
    });

    connect(reply, &WebDAVReply::error, [=](QNetworkReply::NetworkError err) {
      qDebug() << "ERROR" << err;
      QCoreApplication::exit(1);
    });

    this->app->exec();
  }

  void testCreateDir() {
    QString dirName = QDate::currentDate().toString(Qt::DateFormat::ISODate);
    WebDAVReply *reply = this->client->createDir(
        Environment::get("LIBWEBDAV_TEST_PATH"), dirName);

    connect(reply, &WebDAVReply::createDirFinished, [=](QNetworkReply *reply) {
      if (!reply->error()) {
        qDebug() << "\nDir Created"
                 << "\nURL  :" << reply->url();
      } else {
        qDebug() << "ERROR(CREATE DIR)" << reply->error();
      }
      QCoreApplication::exit(0);
    });

    connect(reply, &WebDAVReply::error, [=](QNetworkReply::NetworkError err) {
      qDebug() << "ERROR" << err;
      QCoreApplication::exit(1);
    });

    this->app->exec();
  }

  void testCopyDir() {
    QString dirName = QDate::currentDate().toString(Qt::DateFormat::ISODate);
    WebDAVReply *reply = this->client->copy(
        Environment::get("LIBWEBDAV_TEST_PATH") + "/tttt.cpp",
        Environment::get("LIBWEBDAV_TEST_PATH") + "/" + dirName +
            "/tttt-copy.cpp");

    connect(reply, &WebDAVReply::copyFinished, [=](QNetworkReply *reply) {
      if (!reply->error()) {
        qDebug() << "\nItem Copied"
                 << "\nURL  :" << reply->url();
      } else {
        qDebug() << "ERROR(COPY)" << reply->error();
      }
      QCoreApplication::exit(0);
    });

    connect(reply, &WebDAVReply::error, [=](QNetworkReply::NetworkError err) {
      qDebug() << "ERROR" << err;
      QCoreApplication::exit(1);
    });

    this->app->exec();
  }

  void testMoveDir() {
    QString dirName = QDate::currentDate().toString(Qt::DateFormat::ISODate);
    WebDAVReply *reply = this->client->move(
        Environment::get("LIBWEBDAV_TEST_PATH") + "/tttt.cpp",
        Environment::get("LIBWEBDAV_TEST_PATH") + "/" + dirName + "/tttt.cpp",
        true);

    connect(reply, &WebDAVReply::moveFinished, [=](QNetworkReply *reply) {
      if (!reply->error()) {
        qDebug() << "\nItem Moved"
                 << "\nURL  :" << reply->url();
      } else {
        qDebug() << "ERROR(MOVE DIR)" << reply->error();
      }
      QCoreApplication::exit(0);
    });

    connect(reply, &WebDAVReply::error, [=](QNetworkReply::NetworkError err) {
      qDebug() << "ERROR" << err;
      QCoreApplication::exit(1);
    });

    this->app->exec();
  }

  void testRemove() {
    QString dirName = QDate::currentDate().toString(Qt::DateFormat::ISODate);

    WebDAVReply *reply = this->client->remove(
        Environment::get("LIBWEBDAV_TEST_PATH") + "/" + dirName + "/tttt.cpp");

    connect(reply, &WebDAVReply::removeFinished, [=](QNetworkReply *reply) {
      if (!reply->error()) {
        qDebug() << "\nItem Removed"
                 << "\nURL  :" << reply->url();
      } else {
        qDebug() << "ERROR(REMOVE File)" << reply->error();
      }
      QCoreApplication::exit(0);
    });

    connect(reply, &WebDAVReply::error, [=](QNetworkReply::NetworkError err) {
      qDebug() << "ERROR" << err;
      QCoreApplication::exit(1);
    });

    this->app->exec();
  }

  void testRemoveDir() {
    QString dirName = QDate::currentDate().toString(Qt::DateFormat::ISODate);
    WebDAVReply *reply = this->client->remove(
        Environment::get("LIBWEBDAV_TEST_PATH") + "/" + dirName);

    connect(reply, &WebDAVReply::removeFinished, [=](QNetworkReply *reply) {
      if (!reply->error()) {
        qDebug() << "\nItem Removed"
                 << "\nURL  :" << reply->url();
      } else {
        qDebug() << "ERROR(REMOVE Dir)" << reply->error();
      }
      QCoreApplication::exit(0);
    });

    connect(reply, &WebDAVReply::error, [=](QNetworkReply::NetworkError err) {
      qDebug() << "ERROR" << err;
      QCoreApplication::exit(1);
    });

    this->app->exec();
  }

  void cleanupTestCase() { delete this->app; }
};

QTEST_MAIN(TestWebDAVClient)
#include "TestWebDAVClient.moc"

#endif
