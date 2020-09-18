#include "tracksmodel.h"
#include "db/collectionDB.h"

#include "vvave.h"

#ifdef STATIC_MAUIKIT
#include "fmstatic.h"
#else
#include <MauiKit/fmstatic.h>
#endif

TracksModel::TracksModel(QObject *parent) : MauiList(parent),
	db(CollectionDB::getInstance())
{
    connect(this, &TracksModel::queryChanged, this, &TracksModel::setList);
}

void TracksModel::componentComplete()
{
    connect(vvave::instance (), &vvave::tracksAdded, this, &TracksModel::setList);
    connect(vvave::instance (), &vvave::sourceRemoved, this, &TracksModel::setList);
}

FMH::MODEL_LIST TracksModel::items() const
{
	return this->list;
}

void TracksModel::setQuery(const QString &query)
{
//    if(this->query == query)
//        return;

	this->query = query;
	emit this->queryChanged();
}

QString TracksModel::getQuery() const
{
	return this->query;
}

int TracksModel::limit() const
{
	return m_limit;
}

void TracksModel::setList()
{
	emit this->preListChanged();
	qDebug()<< "GETTIN TRACK LIST" << this->query;

	if(this->query.startsWith("#"))
	{
		const auto urls =  FMStatic::getTagUrls(query.replace("#", ""), {}, true, m_limit, "audio");
		this->list.clear();
		for(const auto &url : urls)
		{
			this->list << this->db->getDBData(QString("select t.*, al.artwork from tracks t inner join albums al on al.album = t.album "
													  "and al.artist = t.artist where t.url = %1").arg("\""+url.toString()+"\""));
		}

	}else
	{
//        const auto checker = [&](FMH::MODEL &item) {
//            const auto url = QUrl(item[FMH::MODEL_KEY::URL]);
//            if(FMH::fileExists(url))
//            {
//                return true;
//            } else
//            {
//                this->db->removeTrack(url.toString());
//                return false;
//            }
//        };
        this->list = this->db->getDBData(this->query/*, checker*/);
}

emit this->postListChanged();
emit countChanged();
}

QVariantMap TracksModel::get(const int &index) const
{
	if(index >= this->list.size() || index < 0)
		return QVariantMap();

	return FMH::toMap(this->list.at( this->mappedIndex(index)));
}

QVariantList TracksModel::getAll()
{
	QVariantList res;
	for(const auto &item : this->list)
		res << FMH::toMap(item);

	return res;
}

void TracksModel::append(const QVariantMap &item)
{
	if(item.isEmpty())
		return;

	emit this->preItemAppended();
	this->list << FMH::toModel(item);
	emit this->postItemAppended();
	emit this->countChanged();
}

void TracksModel::append(const QVariantMap &item, const int &at)
{
	if(item.isEmpty())
		return;

	if(at > this->list.size() || at < 0)
		return;

	emit this->preItemAppendedAt(at);
	this->list.insert(at, FMH::toModel(item));
	emit this->postItemAppended();
	emit this->countChanged();
}

void TracksModel::appendQuery(const QString &query)
{
	emit this->preListChanged();
	this->list << this->db->getDBData(query);
	emit this->postListChanged();
	emit this->countChanged();
}

void TracksModel::searchQueries(const QStringList &queries)
{
	emit this->preListChanged();
	this->list.clear();

	bool hasKey = false;
	for(auto searchQuery : queries)
	{
		if(searchQuery.contains(BAE::SearchTMap[BAE::SearchT::LIKE]+":") || searchQuery.startsWith("#"))
		{
			if(searchQuery.startsWith("#"))
				searchQuery = searchQuery.replace("#","").trimmed();
			else
				searchQuery = searchQuery.replace(BAE::SearchTMap[BAE::SearchT::LIKE]+":","").trimmed();


			searchQuery = searchQuery.trimmed();
			if(!searchQuery.isEmpty())
			{
				this->list << this->db->getSearchedTracks(FMH::MODEL_KEY::WIKI, searchQuery);
				this->list << this->db->getSearchedTracks(FMH::MODEL_KEY::TAG, searchQuery);
				this->list << this->db->getSearchedTracks(FMH::MODEL_KEY::LYRICS, searchQuery);
			}

		}else if(searchQuery.contains((BAE::SearchTMap[BAE::SearchT::SIMILAR]+":")))
		{
			searchQuery=searchQuery.replace(BAE::SearchTMap[BAE::SearchT::SIMILAR]+":","").trimmed();
			searchQuery=searchQuery.trimmed();
			if(!searchQuery.isEmpty())
				this->list << this->db->getSearchedTracks(FMH::MODEL_KEY::TAG, searchQuery);

		}else
		{
			FMH::MODEL_KEY key;

			QHashIterator<FMH::MODEL_KEY, QString> k(FMH::MODEL_NAME);
			while (k.hasNext())
			{
				k.next();
				if(searchQuery.contains(QString(k.value()+":")))
				{
					hasKey=true;
					key=k.key();
					searchQuery = searchQuery.replace(k.value()+":","").trimmed();
				}
			}

			searchQuery = searchQuery.trimmed();

			if(!searchQuery.isEmpty())
			{
				if(hasKey)
					this->list << this->db->getSearchedTracks(key, searchQuery);
				else
				{
					auto queryTxt = QString("SELECT t.*, al.artwork FROM tracks t INNER JOIN albums al ON t.album = al.album AND t.artist = al.artist WHERE t.title LIKE \"%"+searchQuery+"%\" OR t.artist LIKE \"%"+searchQuery+"%\" OR t.album LIKE \"%"+searchQuery+"%\"OR t.genre LIKE \"%"+searchQuery+"%\"OR t.url LIKE \"%"+searchQuery+"%\" ORDER BY strftime(\"%s\", t.addDate) desc LIMIT 1000");
					this->list << this->db->getDBData(queryTxt);
				}
			}
		}
	}

	emit this->postListChanged();
}

void TracksModel::clear()
{
	emit this->preListChanged();
	this->list.clear();
	emit this->postListChanged();
    emit this->countChanged();
}

bool TracksModel::fav(const int &index, const bool &value)
{
	if(index >= this->list.size() || index < 0)
		return false;

	const auto index_ = this->mappedIndex(index);

	auto item = this->list[index_];

	if(value)
		FMStatic::fav(item[FMH::MODEL_KEY::URL]);
	else
		FMStatic::unFav(item[FMH::MODEL_KEY::URL]);

	this->list[index_][FMH::MODEL_KEY::FAV] = value ?  "1" : "0";
	emit this->updateModel(index_, {FMH::MODEL_KEY::FAV});

	return true;
}

bool TracksModel::rate(const int &index, const int &value)
{
	if(index >= this->list.size() || index < 0)
		return false;

	const auto index_ = this->mappedIndex(index);

	auto item = this->list[index_];
	if(this->db->rateTrack(item[FMH::MODEL_KEY::URL], value))
	{
		this->list[index_][FMH::MODEL_KEY::RATE] = QString::number(value);
		emit this->updateModel(index_, {FMH::MODEL_KEY::RATE});

		return true;
	}

	return false;
}

bool TracksModel::countUp(const int &index)
{
	if(index >= this->list.size() || index < 0)
		return false;

	const auto index_ = this->mappedIndex(index);

	auto item = this->list[index_];
	if(this->db->playedTrack(item[FMH::MODEL_KEY::URL]))
	{
		this->list[index_][FMH::MODEL_KEY::COUNT] = QString::number(item[FMH::MODEL_KEY::COUNT].toInt() + 1);
		emit this->updateModel(index_, {FMH::MODEL_KEY::COUNT});

		return true;
	}

	return false;
}

bool TracksModel::remove(const int &index)
{
	if(index >= this->list.size() || index < 0)
		return false;

	const auto index_ = this->mappedIndex(index);

	emit this->preItemRemoved(index_);
	this->list.removeAt(index_);
	emit this->postItemRemoved();

	return true;
}

void TracksModel::refresh()
{
	this->setList();
}

bool TracksModel::update(const QVariantMap &data, const int &index)
{
	if(index >= this->list.size() || index < 0)
		return false;

	const auto index_ = this->mappedIndex(index);

	auto newData = this->list[index_];
	QVector<int> roles;

	for(auto key : data.keys())
		if(newData[FMH::MODEL_NAME_KEY[key]] != data[key].toString())
		{
			newData.insert(FMH::MODEL_NAME_KEY[key], data[key].toString());
			roles << FMH::MODEL_NAME_KEY[key];
		}

	this->list[index_] = newData;
	emit this->updateModel(index_, roles);
	return true;
}

void TracksModel::setLimit(int limit)
{
	if (m_limit == limit)
		return;

	m_limit = limit;
	emit limitChanged(m_limit);
}
