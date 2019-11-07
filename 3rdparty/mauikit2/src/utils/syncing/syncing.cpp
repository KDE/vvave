#include "syncing.h"
#include "fm.h"

#include <QFile>
#include <QTimer>
#include <QEventLoop>

#include "WebDAVClient.hpp"
#include "WebDAVItem.hpp"
#include "WebDAVReply.hpp"

Syncing::Syncing(QObject *parent) : QObject(parent)
{
	this->setCredentials(this->host, this->user, this->password);
}

void Syncing::listContent(const QUrl &path, const QStringList &filters, const int &depth)
{
	this->currentPath = path;
	
	auto url = QUrl(path).path().replace(user, "");
	this->listDirOutputHandler(this->client->listDir(url, static_cast<ListDepthEnum>(depth)), filters);
}

void Syncing::setCredentials(const QString &server, const QString &user, const QString &password)
{
	this->host = server;
	this->user = user;
	this->password = password;
	
	this->client = new WebDAVClient(this->host, this->user, this->password);
}

void Syncing::listDirOutputHandler(WebDAVReply *reply, const QStringList &filters)
{
	connect(reply, &WebDAVReply::listDirResponse, [=](QNetworkReply *listDirReply, QList<WebDAVItem> items) 
	{
// 		qDebug() << "URL :" << listDirReply->url();
// 		qDebug() << "Received List of" << items.length() << "items";
// 		qDebug() << endl << "---------------------------------------";
		FMH::MODEL_LIST list;
		for (WebDAVItem item : items)
		{			
			const auto url = QUrl(item.getHref()).toString();
			
			auto path =  QString(FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::CLOUD_PATH]+this->user+"/")+QString(url).replace("/remote.php/webdav/", "");
			
			auto displayName =  item.getContentType().isEmpty() ? QString(url).replace("/remote.php/webdav/", "").replace("/", "") :  QString(path).right(path.length()-path.lastIndexOf("/")-1);
			
			// 			qDebug()<< "PATHS:" << path << this->currentPath;
			
            if(QString(url).replace("/remote.php/webdav/", "").isEmpty() || path == this->currentPath.toString())
				continue;
			
			// 			qDebug()<< "FILTERING "<< filters << QString(displayName).right(displayName.length() - displayName.lastIndexOf("."));
			if(!filters.isEmpty() && !filters.contains("*"+QString(displayName).right(displayName.length() -  displayName.lastIndexOf("."))))
				continue;
			
			list << FMH::MODEL { {FMH::MODEL_KEY::LABEL, displayName},
		 {FMH::MODEL_KEY::NAME, item.getDisplayName()},
			{FMH::MODEL_KEY::DATE, item.getCreationDate().toString(Qt::TextDate)},
			{FMH::MODEL_KEY::MODIFIED, item.getLastModified()},
			{FMH::MODEL_KEY::MIME, item.getContentType().isEmpty() ? "inode/directory" : item.getContentType()},
			{FMH::MODEL_KEY::ICON, FMH::getIconName(url)},
			{FMH::MODEL_KEY::SIZE, QString::number(item.getContentLength())},
			{FMH::MODEL_KEY::PATH, path},
         {FMH::MODEL_KEY::URL, url},
         {FMH::MODEL_KEY::THUMBNAIL, item.getContentType().isEmpty() ? url : this->getCacheFile(url).toString()}
        };
		}
		emit this->listReady(list, this->currentPath);
		
	});
	connect(reply, &WebDAVReply::error, [=](QNetworkReply::NetworkError err) {
// 		qDebug() << "ERROR" << err;
		this->emitError(err);
	});
}

QUrl Syncing::getCacheFile(const QUrl &path)
{	
    const auto directory = FM::resolveUserCloudCachePath(this->host, this->user);
    const auto file = directory + path.toString().replace("remote.php/webdav/", "");
	
	qDebug()<< "resolving file"<< file;
	
	if(FMH::fileExists(file))
		return file;
	else return path;
}

void Syncing::download(const QUrl &path)
{
    QString url = QString(path.toString()).replace("remote.php/webdav/", "");
	
	WebDAVReply *reply = this->client->downloadFrom(url);
	qDebug()<< "CURRENT CREDENTIALS"<< this->host << this->user;
	connect(reply, &WebDAVReply::downloadResponse, [=](QNetworkReply *reply) 
	{
		if (!reply->error())
		{
			qDebug() << "\nDownload Success"
			<< "\nURL  :" << reply->url() << "\nSize :" << reply->size();
			auto file = reply->readAll();
			const auto directory = FMH::CloudCachePath+"opendesktop/"+this->user;
			
			QDir dir(directory);
			
			if (!dir.exists())
				dir.mkpath(".");
			
			this->saveTo(file, directory+url);
		} else 
		{
			qDebug() << "ERROR(DOWNLOAD)" << reply->error() << reply->url() <<url;
			emit this->error(reply->errorString());
		}
	});
	
	connect(reply, &WebDAVReply::downloadProgressResponse, [=](qint64 bytesReceived, qint64 bytesTotal)
	{
		int percent = ((float)bytesReceived / bytesTotal) * 100;
		
		qDebug() << "\nReceived : " << bytesReceived
		<< "\nTotal    : " << bytesTotal
		<< "\nPercent  : " << percent;
		
		emit this->progress(percent);
	});
	
	connect(reply, &WebDAVReply::error, [=](QNetworkReply::NetworkError err) {
		qDebug() << "ERROR" << err;
	});
}

void Syncing::upload(const QUrl &path, const QUrl &filePath)
{
	
	if(!FMH::fileExists(filePath))
		return;
		
	qDebug()<< "Copy to cloud. File exists" << path << filePath;
	
    this->mFile.setFileName(filePath.toString());

	if(this->mFile.open(QIODevice::ReadOnly))
	{		
		qDebug()<< "Copy to cloud. File could be opened";
		
        WebDAVReply *reply = this->client->uploadTo(path.toString(), QFileInfo(filePath.toString()).fileName(), &this->mFile);
	
		connect(reply, &WebDAVReply::uploadFinished, [=](QNetworkReply *reply)
	{
		if (!reply->error())
		{
			qDebug() << "\nUpload Success"
			<< "\nURL  :" << reply->url() << "\nSize :" << reply->size();
			
            auto cachePath = this->saveToCache(filePath.toString(), path);
			
			auto item = FMH::getFileInfoModel(cachePath);
// 			item[FMH::MODEL_KEY::PATH] =  this->currentPath+"/"+QFileInfo(filePath).fileName()+"/";
			
			emit this->uploadReady(item, this->currentPath);
		} else
		{
			qDebug() << "ERROR(UPLOAD)" << reply->error();
			emit this->error(reply->errorString());
		}
		
		if(!this->uploadQueue.isEmpty())
		{			
			qDebug()<<"UPLOAD QUEUE" << this->uploadQueue;
			this->upload(path, this->uploadQueue.takeLast());
		}
	});
	
	connect(reply, &WebDAVReply::error, [=](QNetworkReply::NetworkError err)
	{
		qDebug() << "ERROR" << err;
		this->emitError(err);
	});}
}

void Syncing::createDir(const QUrl &path, const QString &name)
{
    WebDAVReply *reply = this->client->createDir(path.toString(), name);
	
	connect(reply, &WebDAVReply::createDirFinished, [=](QNetworkReply *reply) 
	{
		if (!reply->error())
		{
			qDebug() << "\nDir Created"
			<< "\nURL  :" << reply->url();
			FMH::MODEL dir = {
				{FMH::MODEL_KEY::LABEL, name},
		 {FMH::MODEL_KEY::DATE, QDateTime::currentDateTime().toString(Qt::TextDate)},
			{FMH::MODEL_KEY::MIME, "inode/directory"},
		 {FMH::MODEL_KEY::ICON, "folder"},
         {FMH::MODEL_KEY::PATH, this->currentPath.toString()+"/"+name+"/"}
			};
			emit this->dirCreated(dir, this->currentPath);
		} else 
		{
			qDebug() << "ERROR(CREATE DIR)" << reply->error();
			emit this->error(reply->errorString());
		}
	});
	
	connect(reply, &WebDAVReply::error, [=](QNetworkReply::NetworkError err) 
	{
		qDebug() << "ERROR" << err;
		this->emitError(err);
	});
}

void Syncing::emitError(const QNetworkReply::NetworkError &err)
{
	
	switch(err)
	{
		case QNetworkReply::AuthenticationRequiredError: 
			emit this->error("The remote server requires authentication to serve the content but the credentials provided were not accepted (if any)");
			break;
			
		case QNetworkReply::ConnectionRefusedError: 
			emit this->error("the remote server refused the connection (the server is not accepting requests)");
			break;
			
		case QNetworkReply::RemoteHostClosedError: 
			emit this->error("the remote server closed the connection prematurely, before the entire reply was received and processed");
			break;
			
		case QNetworkReply::HostNotFoundError: 
			emit this->error("the remote host name was not found (invalid hostname)");
			break;
			
		case QNetworkReply::TimeoutError: 
			emit this->error("the connection to the remote server timed out");
			break;
			
		case QNetworkReply::OperationCanceledError: 
			emit this->error("the operation was canceled via calls to abort() or close() before it was finished.");
			break;
			
		case QNetworkReply::SslHandshakeFailedError: 
			emit this->error("the SSL/TLS handshake failed and the encrypted channel could not be established. The sslErrors() signal should have been emitted.");
			break;
			
		case QNetworkReply::TemporaryNetworkFailureError: 
			emit this->error("the connection was broken due to disconnection from the network, however the system has initiated roaming to another access point. The request should be resubmitted and will be processed as soon as the connection is re-established.");
			break;
			
		case QNetworkReply::NetworkSessionFailedError: 
			emit this->error("the connection was broken due to disconnection from the network or failure to start the network.");
			break;				
			
		case QNetworkReply::BackgroundRequestNotAllowedError: 
			emit this->error("the background request is not currently allowed due to platform policy.");
			break;
			
		case QNetworkReply::TooManyRedirectsError: 
			emit this->error("while following redirects, the maximum limit was reached. The limit is by default set to 50 or as set by QNetworkRequest::setMaxRedirectsAllowed(). (This value was introduced in 5.6.)");
			break;
			
		case QNetworkReply::InsecureRedirectError: 
			emit this->error("while following redirects, the network access API detected a redirect from a encrypted protocol (https) to an unencrypted one (http).");
			break;
			
		case QNetworkReply::ProxyConnectionRefusedError: 
			emit this->error("the connection to the proxy server was refused (the proxy server is not accepting requests)");
			break;
			
		case QNetworkReply::ProxyConnectionClosedError: 
			emit this->error("the proxy server closed the connection prematurely, before the entire reply was received and processed");
			break;
			
		case QNetworkReply::ProxyNotFoundError: 
			emit this->error("the proxy host name was not found (invalid proxy hostname)");
			break;
			
		case QNetworkReply::ProxyTimeoutError: 
			emit this->error("the connection to the proxy timed out or the proxy did not reply in time to the request sent");
			break;
			
		case QNetworkReply::ProxyAuthenticationRequiredError: 
			emit this->error("the proxy requires authentication in order to honour the request but did not accept any credentials offered (if any)");
			break;
			
		case QNetworkReply::ContentAccessDenied: 
			emit this->error("the access to the remote content was denied (similar to HTTP error 403)");
			break;
			
		case QNetworkReply::ContentOperationNotPermittedError: 
			emit this->error("the operation requested on the remote content is not permitted");
			break;
			
		case QNetworkReply::ContentNotFoundError:
			emit this->error("the remote content was not found at the server (similar to HTTP error 404)");
			break;
			
		case QNetworkReply::ContentReSendError: 
			emit this->error("the request needed to be sent again, but this failed for example because the upload data could not be read a second time.");
			break;
			
		case QNetworkReply::ServiceUnavailableError: 
			emit this->error("the server is unable to handle the request at this time.");
			break;
			
		default: emit this->error("There was an unknown error with the remote server or your internet connection.");
	}
}


void Syncing::saveTo(const QByteArray &array, const QUrl &path)
{
    QFile file(path.toLocalFile());
	
	if(!file.exists())
	{
		QDir dir;
        uint cut = path.toString().length()- path.toString().lastIndexOf("/") -1;
        auto newPath = path.toString().right(cut);
        dir.mkdir(path.toString().replace(newPath, ""));
		qDebug()<< newPath << cut;
		
	}else file.remove();	
	
	file.open(QIODevice::WriteOnly);
	file.write(array);
	file.close();
	
	emit this->itemReady(FMH::getFileInfoModel(path), this->currentPath, this->signalType);
	// 	emit this->itemReady(FMH::getFileInfoModel(path));
}

QString Syncing::saveToCache(const QString& file, const QUrl &where)
{
    const auto directory = FMH::CloudCachePath+"opendesktop/"+this->user+"/"+where.toString();
	
	QDir dir(directory);
	
	if (!dir.exists())
		dir.mkpath(".");
	
	const auto newPath = directory+"/"+QFileInfo(file).fileName();
	
	if(QFile::copy(file, newPath))
		return newPath;
	
	return QString();
}

void Syncing::resolveFile(const FMH::MODEL& item, const Syncing::SIGNAL_TYPE &signalType)
{	
	this->signalType = signalType;
	
	const auto url = item[FMH::MODEL_KEY::URL];
	const auto file = this->getCacheFile(url);	
	
	if(FMH::fileExists(file))
	{			
		const auto cacheFile = FMH::getFileInfoModel(file);
		
		const auto dateCacheFile = QDateTime::fromString(cacheFile[FMH::MODEL_KEY::DATE], Qt::TextDate);		
		const auto dateCloudFile = QDateTime::fromString(QString(item[FMH::MODEL_KEY::MODIFIED]).replace("GMT", "").simplified(), "ddd, dd MMM yyyy hh:mm:ss");
		
		qDebug()<<"FILE EXISTS ON CACHE" << dateCacheFile << dateCloudFile<< QString(item[FMH::MODEL_KEY::MODIFIED]).replace("GMT", "").simplified()<< file;
		
		if(dateCloudFile >  dateCacheFile)
			this->download(url);
		else
			emit this->itemReady(cacheFile, this->currentPath, this->signalType);
		
	} else
		this->download(url);
}

void Syncing::setCopyTo(const QUrl &path)
{
	if(this->copyTo == path)
		return;
	
	this->copyTo = path;
}

QUrl Syncing::getCopyTo() const
{
	return this->copyTo;
}

QString Syncing::getUser() const
{
	return this->user;
}

void Syncing::setUploadQueue(const QStringList& list)
{
	this->uploadQueue = list;
}

QString Syncing::localToAbstractCloudPath(const QString& url)
{
	return QString(url).replace(FMH::CloudCachePath+"opendesktop", FMH::PATHTYPE_URI[FMH::PATHTYPE_KEY::CLOUD_PATH]);
}

