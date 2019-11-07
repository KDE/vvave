#ifndef SYNCING_H
#define SYNCING_H

#include <QObject>
#include <QNetworkReply>
#include "fmh.h"

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

class WebDAVClient;
class WebDAVReply;

#ifdef STATIC_MAUIKIT
class Syncing : public QObject
#else
class MAUIKIT_EXPORT Syncing : public QObject
#endif
{
    Q_OBJECT
	
public:	
	enum SIGNAL_TYPE : uint_fast8_t
	{
		OPEN,
		DOWNLOAD,
		COPY,
		SAVE,
		CUT,
		DELETE,
		RENAME,
		MOVE,
		UPLOAD
	};
	
	QStringList uploadQueue;
	
	
    explicit Syncing(QObject *parent = nullptr);
    void listContent(const QUrl &path, const QStringList &filters, const int &depth = 1);
    void setCredentials(const QString &server, const QString &user, const QString &password);
    void download(const QUrl &path);
    void upload(const QUrl &path, const QUrl &filePath);
    void createDir(const QUrl &path, const QString &name);
	void resolveFile(const FMH::MODEL &item, const Syncing::SIGNAL_TYPE &signalType);
    void setCopyTo(const QUrl &path);
    QUrl getCopyTo() const;
	
	QString getUser() const;

	void setUploadQueue(const QStringList &list); 
	
	QString localToAbstractCloudPath(const QString &url);

private:
    WebDAVClient *client;
    QString host = "https://cloud.opendesktop.cc/remote.php/webdav/";
    QString user = "mauitest";
    QString password = "mauitest";
	void listDirOutputHandler(WebDAVReply *reply, const QStringList &filters = QStringList());
	
    void saveTo(const QByteArray &array, const QUrl& path);
    QString saveToCache(const QString& file, const QUrl &where);
    QUrl getCacheFile(const QUrl &path);

    QUrl currentPath;
    QUrl copyTo;
	
	void emitError(const QNetworkReply::NetworkError &err);
	
	SIGNAL_TYPE signalType;
	
	QFile mFile;
	
	
signals:
    void listReady(FMH::MODEL_LIST data, QUrl url);
    void itemReady(FMH::MODEL item, QUrl url, Syncing::SIGNAL_TYPE &signalType);
    void dirCreated(FMH::MODEL item, QUrl url);
    void uploadReady(FMH::MODEL item, QUrl url);
	void error(QString message);
	void progress(int percent);
	
public slots:
};

#endif // SYNCING_H
