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

#include "storelist.h"
#include "fm.h"

StoreList::StoreList(QObject *parent) : QObject(parent)
{
	this->store = new Store(this);
	this->store->setProvider(STORE::KDELOOK_API);
	this->store->start();
	
	connect(this->store, &Store::contentReady, [this](const FMH::MODEL_LIST &list)
	{
		emit this->preListChanged();
		this->list = list; 
		this->sortList();
		qDebug()<< "STORE LIST READY" << list;
		emit this->postListChanged();
		
		this->contentReady = true;
		emit this->contentReadyChanged();
		
		this->contentEmpty = this->list.isEmpty();
		emit this->contentEmptyChanged();
	});
	
	connect(this->store, &Store::warning, [this](const QString warning)
	{
		emit this->warning(warning); 
	});
	
	connect(this->store, &Store::downloadReady, [this] (const FMH::MODEL &item)
	{
		emit this->downloadReady(FMH::toMap(item));
	});
	
	connect(this->store, &Store::storeReady, this, &StoreList::setList);
}

QVariantMap StoreList::get(const int& index) const
{	
	if(index >= this->list.size() || index < 0)
		return QVariantMap();
	
	QVariantMap res;
	const auto model = this->list.at(index);
	
	for(auto key : model.keys())
		res.insert(FMH::MODEL_NAME[key], model[key]);
	
	return res;
}

void StoreList::download(const int& index)
{
	if(index >= this->list.size() || index < 0)
		return;
	
	// 	this->store->download(this->list[index][FMH::MODEL_KEY::ID]);
	this->store->download(this->list[index]);
}

FMH::MODEL_LIST StoreList::items() const
{
	return this->list;
}

void StoreList::getPersonInfo(const QString& nick)
{
	this->store->getPersonInfo(nick);
}

void StoreList::setList()
{
	emit this->preListChanged();
	this->list.clear();
	emit this->postListChanged();
	
	this->contentEmpty = this->list.isEmpty();
	emit this->contentEmptyChanged();
	
	this->contentReady = false;
	emit this->contentReadyChanged();
	
	this->store->searchFor(static_cast<STORE::CATEGORY_KEY>(this->category), this->query, this->limit, this->page, static_cast<Attica::Provider::SortMode>(this->sortBy));	
}

StoreList::CATEGORY StoreList::getCategory() const
{
	return this->category;
}

void StoreList::setCategory(const StoreList::CATEGORY& value) 
{
	if(this->category == value)
		return;
	
	this->category = value;
	emit this->categoryChanged();
	this->setList();
}

int StoreList::getLimit() const
{
	return this->limit;
}

void StoreList::setLimit(const int& value) 
{
	if(this->limit == value)
		return;
	
	this->limit = value;
	emit this->limitChanged();
	this->setList();
}

int StoreList::getPage() const
{
	return this->page;
}

void StoreList::setPage(const int& value) 
{
	if(this->page == value)
		return;
	
	this->page = value;
	emit this->pageChanged();
	this->setList();
}

StoreList::ORDER StoreList::getOrder() const
{
	return this->order;
}

void StoreList::setOrder(const StoreList::ORDER& value) 
{
	if(this->order == value)
		return;
	
	this->order = value;
	emit this->orderChanged();
}

QString StoreList::getQuery() const
{
	return this->query;
}

void StoreList::setQuery(const QString& value) 
{
	if(this->query == value)
		return;
	
	this->query = value;
	emit this->queryChanged();
	
	this->page = 0;
	emit this->pageChanged();
	
	this->setList();
}

QVariantList StoreList::getCategoryList()
{
	QVariantList res;
	auto data = STORE::CATEGORIES[static_cast<STORE::CATEGORY_KEY>(this->category)];
	
	for(auto category : data)
		res << QVariantMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::LABEL], category}};
	
	return res;		
}

bool StoreList::getContentReady() const
{
	return this->contentReady;
}

bool StoreList::getContentEmpty() const
{
	return this->contentEmpty;
}

StoreList::SORTBY StoreList::getSortBy() const
{
	return this->sortBy;
}

void StoreList::setSortBy(const StoreList::SORTBY& key)
{	
	if(this->sortBy == key)
		return;
	
	this->sortBy = key;
	
	emit this->sortByChanged();	
	this->setList();
}

void StoreList::sortList()
{
	qDebug()<< "TRYING TO SORT LIST" << this->list.size();
	qSort(this->list.begin(), this->list.begin(), [this](const FMH::MODEL& e1, const FMH::MODEL& e2) -> bool
	{
		qDebug()<< "TRYIT LIST";
		
		auto role = static_cast<FMH::MODEL_KEY>(this->sortBy);;
		
		switch(role)
		{				
			case FMH::MODEL_KEY::RATE:
			case FMH::MODEL_KEY::COUNT:
			{				
				if(e1[role].toDouble() > e2[role].toDouble())
					return true;
				break;
			}
			
			case FMH::MODEL_KEY::MODIFIED:
			case FMH::MODEL_KEY::DATE:
			{
				auto currentTime = QDateTime::currentDateTime();
				
				auto date1 = QDateTime::fromString(e1[role], Qt::TextDate);
				auto date2 = QDateTime::fromString(e2[role], Qt::TextDate);
				
				if(date1.secsTo(currentTime) <  date2.secsTo(currentTime))
					return true;
				
				break;
			}
			
			case FMH::MODEL_KEY::LABEL:
			case FMH::MODEL_KEY::USER:
			case FMH::MODEL_KEY::OWNER:
			{
				const auto str1 = QString(e1[role]).toLower();
				const auto str2 = QString(e2[role]).toLower();
				
				if(str1 < str2)
					return true;				
				break;
			}
			
			default:
				if(e1[role] < e2[role])
					return true;
		}
		
		return false;
	});
}

StoreList::PROVIDER StoreList::getProvider() const
{
	return this->provider;
}

void StoreList::setProvider(const StoreList::PROVIDER &key)
{
	if(this->provider == key)
		return;
	
	this->provider = key;
	STORE::PROVIDER value;
	
	switch(this->provider)
	{
		case StoreList::PROVIDER::KDELOOK:
			value = STORE::KDELOOK_API;
			break;
		case StoreList::PROVIDER::OPENDESKTOP:
			value = STORE::OPENDESKTOP_API;
			break;
		case StoreList::PROVIDER::OPENDESKTOPCC:
			value = STORE::OPENDESKTOPCC_API;
			break;
		case StoreList::PROVIDER::KRITA:
			value = STORE::KRITA_API;
			break;
	}
	
	this->store->setProvider(value);
	emit this->providerChanged();	
}

bool StoreList::fileExists(const int &index)
{
	if(index >= this->list.size() || index < 0)
		return false;
	
	const auto url = this->list[index][FMH::MODEL_KEY::URL];
	
	const QStringList filePathList = url.split('/');
	const auto fileName = filePathList.at(filePathList.count() - 1);
	
	qDebug() << "Check if file exists" << FMH::DownloadsPath+"/"+fileName;
	
	return FMH::fileExists(FMH::DownloadsPath+"/"+fileName);
		
}

QString StoreList::itemLocalPath(const int &index)
{
	if(!this->fileExists(index))
		return QString();
	
	const auto url = this->list[index][FMH::MODEL_KEY::URL];
	
	const QStringList filePathList = url.split('/');
	const auto fileName = filePathList.at(filePathList.count() - 1);
	
	return FMH::DownloadsPath+"/"+fileName;
}

