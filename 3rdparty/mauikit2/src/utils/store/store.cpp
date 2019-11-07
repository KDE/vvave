/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2018  camilo <email>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "store.h"
#include "fmh.h"
#include <QFile>
#include <QEventLoop>

Store::Store(QObject *parent) : QObject(parent)
{	
	
}

Store::~Store()
{
}

void Store::start()
{
	qDebug()<< "Setting up Store backend";
	
	if(!FMH::fileExists(FMH::DataPath+"/Store/providers.xml"))
	{
		QDir store_dir(FMH::DataPath+"/Store/");
		if (!store_dir.exists())
			store_dir.mkpath(".");
		
		QFile providersFile(":/store/providers.xml");
		providersFile.copy(FMH::DataPath+"/Store/providers.xml");
		
	}
	connect(&m_manager, SIGNAL(defaultProvidersLoaded()), SLOT(providersChanged()));
	// 	qDebug()<< "provider local file exists?"<< FMH::fileExists(FMH::DataPath+"/Store/providers.xml");
	m_manager.addProviderFile(QUrl::fromLocalFile(FMH::DataPath+"/Store/providers.xml"));
	m_manager.addProviderFile(QUrl("https://autoconfig.kde.org/ocs/providers.xml"));
	m_manager.addProviderFile(QUrl("https://share.krita.org/ocs/providers.xml"));
	// 		m_manager.loadDefaultProviders();	
}

void Store::setProvider(const STORE::PROVIDER &provider)
{
	this->provider = provider;
}

void Store::setCategory(const STORE::CATEGORY_KEY& categoryKey)
{
	qDebug()<< "SETTING CATEGORY OFR STORE";
	this->m_category = categoryKey;
	this->listCategories();
}

void Store::searchFor(const STORE::CATEGORY_KEY& categoryKey, const QString &query, const int &limit, const int &page, const Attica::Provider::SortMode &sortBy)
{	
	this->query = query;
	this->limit = limit;	
	this->page = page;
	this->sortBy = sortBy;
	
// 	qDebug() << "CATEGORY LIST" << STORE::CATEGORIES[this->m_category];
	// 	if(this->m_category == categoryKey)
	// 	{
	// 		qDebug()<< "SEARCHIGN WITHIN SAME CATEGORY" << this->m_category;
	// 		this->perfomSearch();
	// 		return;
	// 	}
	// 	
	connect(this, &Store::categoryIDsReady, this, &Store::perfomSearch);		
	this->setCategory(categoryKey);
}

void Store::perfomSearch()
{
	Attica::Category::List categories;
	qDebug()<< "GOT THE CATEGORY IDS" << this->categoryID;
	
	for(auto key : this->categoryID.keys())
	{
		Attica::Category category;
		category.setId(this->categoryID[key]);
		category.setName(key);
		category.setDisplayName(key);
		categories << category;
		qDebug()<< category.name() << this->categoryID[key];
	}
	
	Attica::ListJob<Attica::Content> *job = this->m_provider.searchContents(categories, this->query, this->sortBy, this->page, this->limit);
	
	connect(job, SIGNAL(finished(Attica::BaseJob*)), SLOT(contentListResult(Attica::BaseJob*)));	
	job->start();
}


void Store::contentListResult(Attica::BaseJob* j)
{
	qDebug() << "Content list job returned";
	
	FMH::MODEL_LIST list;
	
	if (j->metadata().error() == Attica::Metadata::NoError) 
	{
		Attica::ListJob<Attica::Content> *listJob = static_cast<Attica::ListJob<Attica::Content> *>(j);
		
		foreach (const Attica::Content &p, listJob->itemList()) 
		{
			const auto att = p.attributes();
			list << FMH::MODEL {
				{FMH::MODEL_KEY::ID, p.id()},
				{FMH::MODEL_KEY::URL, att[STORE::ATTRIBUTE[STORE::ATTRIBUTE_KEY::DOWNLOAD_LINK]]},
				{FMH::MODEL_KEY::THUMBNAIL, att[STORE::ATTRIBUTE[STORE::ATTRIBUTE_KEY::PREVIEW_SMALL_1]]},
				{FMH::MODEL_KEY::THUMBNAIL_1, att[STORE::ATTRIBUTE[STORE::ATTRIBUTE_KEY::PREVIEW_1]]},
				{FMH::MODEL_KEY::THUMBNAIL_2, att[STORE::ATTRIBUTE[STORE::ATTRIBUTE_KEY::PREVIEW_2]]},
				{FMH::MODEL_KEY::THUMBNAIL_3, att[STORE::ATTRIBUTE[STORE::ATTRIBUTE_KEY::DOWNLOAD_LINK]]},
				{FMH::MODEL_KEY::LABEL, p.name()},
				{FMH::MODEL_KEY::OWNER, p.author()},
				{FMH::MODEL_KEY::LICENSE, p.license()},
				{FMH::MODEL_KEY::DESCRIPTION, p.description()},
				{FMH::MODEL_KEY::RATE, QString::number(p.rating())},
				{FMH::MODEL_KEY::DATE, p.created().toString()},
				{FMH::MODEL_KEY::MODIFIED, p.updated().toString()},
				{FMH::MODEL_KEY::TAG, p.tags().join(",")},	
				{FMH::MODEL_KEY::COUNT, QString::number(p.downloads())},	
				{FMH::MODEL_KEY::SOURCE, p.detailpage().toString()}	
			}; 
		}
		
		emit this->contentReady(list);
		
		if (listJob->itemList().isEmpty())
		{
			emit this->warning(QLatin1String("No Content found."));
		}
		
	} else if (j->metadata().error() == Attica::Metadata::OcsError)
	{
		emit this->warning(QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message()));
		
	} else if (j->metadata().error() == Attica::Metadata::NetworkError)
	{
		emit this->warning(QString(QLatin1String("Network Error: %1")).arg(j->metadata().message()));
	} else
	{
		emit this->warning(QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message()));
	}
}

void Store::providersChanged()
{
	if (!m_manager.providers().isEmpty())
	{
		qDebug()<< "Providers names:";
		for(auto prov : m_manager.providers())
			qDebug() << prov.name() << prov.baseUrl();
		
		this->m_provider = m_manager.providerByUrl(QUrl(this->provider));
// 				this->m_provider = m_manager.providerByUrl(QUrl(STORE::OPENDESKTOP_API));
		
		if (!this->m_provider.isValid())
		{
			qDebug() << "Could not find "<< this->provider << "provider.";
			return;
			
		}else 
		{
			qDebug()<< "Found the Store provider for" << m_provider.name();
			qDebug()<< "Has content service" << m_provider.hasContentService(); 
			emit this->storeReady();
		}
		
	}else qDebug() << "Could not find any provider.";
	
}

void Store::categoryListResult(Attica::BaseJob* j)
{
	qDebug() << "Category list job returned";
	
	if (j->metadata().error() == Attica::Metadata::NoError) 
	{
		Attica::ListJob<Attica::Category> *listJob = static_cast<Attica::ListJob<Attica::Category> *>(j);
		qDebug() << "Yay, no errors ...";
		QStringList projectIds;
		
		foreach (const Attica::Category &p, listJob->itemList()) 
		{		
			if(STORE::CATEGORIES[this->m_category].contains(p.name()))
				this->categoryID[p.name()] = p.id();				
			projectIds << p.id();   
			
			qDebug()<< p.name() << p.id();
		}
		
		if (listJob->itemList().isEmpty())
		{
			emit this->warning(QLatin1String("No Categories found."));
		}
		
	} else if (j->metadata().error() == Attica::Metadata::OcsError)
	{
		emit this->warning(QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message()));
		
	} else if (j->metadata().error() == Attica::Metadata::NetworkError)
	{
		emit this->warning(QString(QLatin1String("Network Error: %1")).arg(j->metadata().message()));
	} else
	{
		emit this->warning(QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message()));
	}
	
	qDebug()<< "CATEGORY IDS " << this->categoryID;
	emit this->categoryIDsReady();	
}

void Store::getPersonInfo(const QString& nick)
{
	Attica::ItemJob<Attica::Person>* job = m_provider.requestPerson(nick);
	// connect that job
	connect(job, &Attica::BaseJob::finished, [](Attica::BaseJob* doneJob)
	{
		Attica::ItemJob<Attica::Person> *personJob = static_cast< Attica::ItemJob<Attica::Person> * >( doneJob );
		// check if the request actually worked
		if( personJob->metadata().error() == Attica::Metadata::NoError )
		{
			// use the data to fill the labels
			Attica::Person p(personJob->result());
			qDebug() << (p.firstName() + ' ' + p.lastName());
			qDebug() << p.city();
		} else
		{
			qDebug() << ("Could not fetch information.");
		}
		
	});
	// start the job
	job->start();
}

void Store::listProjects()
{
	if(!this->m_provider.isValid())
		return;
	
	Attica::ListJob<Attica::Project> *job = m_provider.requestProjects();
	connect(job, SIGNAL(finished(Attica::BaseJob*)), SLOT(projectListResult(Attica::BaseJob*)));
	job->start();
}

void Store::listCategories()
{	
	if(!this->m_provider.isValid())
		return;
		
	Attica::ListJob<Attica::Category> *job = m_provider.requestCategories();
	connect(job, SIGNAL(finished(Attica::BaseJob*)), SLOT(categoryListResult(Attica::BaseJob*)));
	job->start(); 
		     
}

void Store::download(const QString& id)
{
	if(!this->m_provider.isValid())
		return;
	
	Attica::ItemJob<Attica::DownloadItem> *job = m_provider.downloadLink(id);
	connect(job, SIGNAL(finished(Attica::BaseJob*)), SLOT(contentDownloadReady(Attica::BaseJob*)));
	job->start();  
}

void Store::download(const FMH::MODEL &item)
{
	this->downloadLink(item[FMH::MODEL_KEY::URL], item[FMH::MODEL_KEY::LABEL]); 
}

void Store::contentDownloadReady(Attica::BaseJob* j)
{
	if (j->metadata().error() == Attica::Metadata::NoError) 
	{
		Attica::ItemJob<Attica::DownloadItem> *res = static_cast<Attica::ItemJob<Attica::DownloadItem> *>(j);
		auto job  = res->result();
		auto url = job.url().toString();
		auto fileName = job.packageName();
		
		this->downloadLink(url, fileName);
		
	} else if (j->metadata().error() == Attica::Metadata::OcsError)
	{
		emit this->warning(QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message()));
		
	} else if (j->metadata().error() == Attica::Metadata::NetworkError)
	{
		emit this->warning(QString(QLatin1String("Network Error: %1")).arg(j->metadata().message()));
	} else
	{
		emit this->warning(QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message()));
	}
}

void Store::downloadLink(const QString& url, const QString &fileName)
{	
		const auto downloader = new FMH::Downloader;
// 		QString _fileName = fileName;
		
		qDebug()<< "DOWNLOADING CONTENT FROM "<< url << fileName;
		
		
		QStringList filePathList = url.split('/');
		auto _fileName = filePathList.at(filePathList.count() - 1);
		
		
		connect(downloader, &FMH::Downloader::warning, [this](const QString &warning)
		{
			emit this->warning(warning);
		});
		
		connect(downloader, &FMH::Downloader::fileSaved, [this](const QString &fileName)
		{
			emit this->downloadReady(FMH::getFileInfoModel(fileName));
		});
		
		connect(downloader, &FMH::Downloader::done, [=]()
		{
			downloader->deleteLater();
		});
		
// 		connect(downloader, &FMH::Downloader::downloadReady, [this]()
// 		{
// 			
// 		});
// 		
		downloader->setFile(url, FMH::DownloadsPath  + "/" + _fileName);		
}

void Store::projectListResult(Attica::BaseJob *j)
{
	qDebug() << "Project list job returned";
	QString output = QLatin1String("<b>Projects:</b>");
	
	if (j->metadata().error() == Attica::Metadata::NoError) 
	{
		Attica::ListJob<Attica::Project> *listJob = static_cast<Attica::ListJob<Attica::Project> *>(j);
		qDebug() << "Yay, no errors ...";
		QStringList projectIds;
		
		foreach (const Attica::Project &p, listJob->itemList()) 
		{
			qDebug() << "New project:" << p.id() << p.name();
			output.append(QString(QLatin1String("<br />%1 (%2)")).arg(p.name(), p.id()));
			projectIds << p.id();
			// TODO: start project jobs here
		}
		if (listJob->itemList().isEmpty())
		{
			output.append(QLatin1String("No Projects found."));
		}
	} else if (j->metadata().error() == Attica::Metadata::OcsError)
	{
		output.append(QString(QLatin1String("OCS Error: %1")).arg(j->metadata().message()));
	} else if (j->metadata().error() == Attica::Metadata::NetworkError) 
	{
		output.append(QString(QLatin1String("Network Error: %1")).arg(j->metadata().message()));
	} else 
	{
		output.append(QString(QLatin1String("Unknown Error: %1")).arg(j->metadata().message()));
	}
	qDebug() << output;
}

QHash<QString, QString> Store::getCategoryIDs()
{
	return this->categoryID;
}

// #include "store.moc"
