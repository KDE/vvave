#include "tagslist.h"
#include "tagging.h"

TagsList::TagsList(QObject *parent) : QObject(parent)
{
	this->tag = Tagging::getInstance();
	this->setList();
}

TAG::DB_LIST TagsList::toModel(const QVariantList& data)
{
	TAG::DB_LIST res;
	for(auto item : data)
	{
		const auto map = item.toMap();
		TAG::DB model;
		for(auto key : map.keys())
			model.insert(TAG::MAPKEY[key], map[key].toString());
		
		res << model;
	}
	
	return res;
}

void TagsList::setList()
{
	emit this->preListChanged();	
	
	if(this->abstract)
	{
		if(this->lot.isEmpty() || this->key.isEmpty())			
			this->list = this->toModel(this->tag->getAbstractsTags(this->strict));
		else  
			this->list = this->toModel(this->tag->getAbstractTags(this->key, this->lot, this->strict));
		
	}else
	{
		if(this->urls.isEmpty())
			this->list = this->toModel(this->tag->getAllTags(this->strict));
		else
		{
			this->list.clear();
			for(const auto &url : this->urls)
				this->list << this->toModel(this->tag->getUrlTags(url, this->strict));
		}
	}
	
	this->sortList();
	emit this->postListChanged();
}

void TagsList::sortList()
{
    const auto key = static_cast<TAG::KEYS>(this->sortBy);
	qSort(this->list.begin(), this->list.end(), [key](const TAG::DB & e1, const TAG::DB & e2) -> bool
	{
		auto role = key;
		
		switch(role)
		{
			case TAG::KEYS::ADD_DATE:
			{
				auto currentTime = QDateTime::currentDateTime();
				
				auto date1 = QDateTime::fromString(e1[role], Qt::TextDate);
				auto date2 = QDateTime::fromString(e2[role], Qt::TextDate);
				
				if(date1.secsTo(currentTime) <  date2.secsTo(currentTime))
					return true;
				
				break;
			}
			
			case TAG::KEYS::TAG:
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

QVariantMap TagsList::get(const int &index) const
{
	if(index >= this->list.size() || index < 0)
		return QVariantMap();
	
	const auto folder = this->list.at(index);
	
	QVariantMap res;
	for(auto key : folder.keys())
		res.insert(TAG::KEYMAP[key], folder[key]);
	
	return res;
}

void TagsList::refresh()
{
	this->setList();
}

bool TagsList::contains(const QString& tag)
{		
	return this->indexOf(tag) >= 0;
}

int TagsList::indexOf(const QString& tag)
{
	int i = 0;
	for(const auto &item : this->list)
	{
		if(item.value(TAG::KEYS::TAG) == tag)
			return i;		
		i++;
	}
	
	return -1;
}

bool TagsList::insert(const QString &tag)
{	
	auto _tag = tag.trimmed();
	
	if(this->tag->tag(_tag))
	{
		emit this->preItemAppended();		
		this->list << TAG::DB {{TAG::KEYS::TAG, _tag}};
// 		this->sortList();		
		emit this->postItemAppended();
		return true;
	}
	
	return false;
}

void TagsList::insertToUrls(const QString& tag)
{	
	if(this->urls.isEmpty())
		return;
	
	for(const auto &url : this->urls)	
		this->tag->tagUrl(url, tag);	
	
	this->refresh();
}

void TagsList::insertToAbstract(const QString& tag)
{
	if(this->key.isEmpty() || this->lot.isEmpty())
		return;
	
	if(this->tag->tagAbstract(tag, this->key, this->lot))
		this->refresh();
}

void TagsList::updateToUrls(const QStringList& tags)
{
	if(this->urls.isEmpty())
		return;
	
	for(auto url : this->urls)
		this->tag->updateUrlTags(url, tags);
	
	this->refresh();
}

void TagsList::updateToAbstract(const QStringList& tags)
{
	if(this->key.isEmpty() || this->lot.isEmpty())
		return;
	
	this->tag->updateAbstractTags(this->key, this->lot, tags);
	
	this->refresh();
}

void TagsList::removeFromAbstract(const int& index)
{
	if(index >= this->list.size() || index < 0)
		return;
	
	if(this->key.isEmpty() || this->lot.isEmpty())
		return;

	const auto tag =  this->list[index][TAG::KEYS::TAG];	
	if(this->tag->removeAbstractTag(this->key, this->lot, tag))
	{	
		emit this->preItemRemoved(index);
		this->list.removeAt(index);
		emit this->postItemRemoved();
	}
}

void TagsList::removeFromUrls(const int& index)
{
	if(index >= this->list.size() || index < 0)
		return;
	
	if(this->urls.isEmpty())
		return;
	
	const auto tag =  this->list[index][TAG::KEYS::TAG];
	for(const auto &url : this->urls)
		this->tag->removeUrlTag(url, tag);
	
	emit this->preItemRemoved(index);
	this->list.removeAt(index);
	emit this->postItemRemoved();	
}

void TagsList::removeFromUrls(const QString &tag)
{	
	const auto index = indexOf(tag);
	removeFromUrls(index);
}

bool TagsList::remove(const int& index)
{	
	if(index >= this->list.size() || index < 0)
		return false;
	
	emit this->preItemRemoved(index);
	this->list.removeAt(index);
	emit this->postItemRemoved();
	
	return true;
}

void TagsList::removeFrom(const int& index, const QString& key, const QString& lot)
{
	if(index >= this->list.size() || index < 0)
		return;	
	
	if(this->tag->removeAbstractTag(key, lot, this->list[index][TAG::KEYS::TAG]))
	{
		emit this->preItemRemoved(index);
		this->list.removeAt(index);
		emit this->postItemRemoved();	 
	}
}

void TagsList::removeFrom(const int& index, const QString& url)
{
	if(index >= this->list.size() || index < 0)
			return;
	
	if(this->tag->removeUrlTag(url, this->list[index][TAG::KEYS::TAG]))
	{
		emit this->preItemRemoved(index);
		this->list.removeAt(index);
		emit this->postItemRemoved();
	}
}

void TagsList::erase(const int& index)
{
}

TAG::DB_LIST TagsList::items() const
{
	return this->list;
}

TagsList::KEYS TagsList::getSortBy() const
{
	return this->sortBy;
}

void TagsList::setSortBy(const TagsList::KEYS &key)
{
	if(this->sortBy == key)
		return;
	
	this->sortBy = key;
	
	emit this->preListChanged();
	this->sortList();
	emit this->sortByChanged();
	emit this->postListChanged();
}


bool TagsList::getAbstract() const
{
	return this->abstract;
}

void TagsList::setAbstract(const bool& value)
{
	if(this->abstract == value)
		return;
	
	this->abstract = value;
	this->setList();
	emit this->abstractChanged();
}

bool TagsList::getStrict() const
{
	return this->strict;
}

void TagsList::setStrict(const bool& value)
{
	if(this->strict == value)
		return;
	
	this->strict = value;
	this->setList();
	emit this->strictChanged();
}

QString TagsList::getKey() const
{
	return this->key;
}

void TagsList::setKey(const QString& value)
{
	if(this->key == value)
		return;
	
	this->urls.clear();	
	this->key = value;
	this->setList();
	emit this->keyChanged();
}

QString TagsList::getLot() const
{
	return this->lot;
}

void TagsList::setLot(const QString& value)
{
	if(this->lot == value)
		return;
	
	this->urls.clear();
	this->lot = value;
	this->setList();
	emit this->lotChanged();
}

QStringList TagsList::getUrls() const
{
	return this->urls;
}

void TagsList::setUrls(const QStringList& value)
{
	if(this->urls == value)
		return;
	
	this->key.clear();
	this->lot.clear();
	
	this->urls = value;
	this->setList();
	emit this->urlsChanged();
}

void TagsList::append(const QString &tag)
{
	
	if(this->contains(tag))	
		return;	
	
	if(!this->insert(tag))
	{
		emit this->preItemAppended();
		this->list << TAG::DB {{TAG::KEYS::TAG, tag}};
// 		this->sortList();
		emit this->postItemAppended();
	}
}
