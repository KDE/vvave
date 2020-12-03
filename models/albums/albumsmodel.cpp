#include "albumsmodel.h"
#include "db/collectionDB.h"

#include "vvave.h"

#ifdef STATIC_MAUIKIT
#include "fmstatic.h"
#include "downloader.h"
#else
#include <MauiKit/fmstatic.h>
#include <MauiKit/downloader.h>
#endif

AlbumsModel::AlbumsModel(QObject *parent) : MauiList(parent),
	db(CollectionDB::getInstance())
{
	qRegisterMetaType<FMH::MODEL_LIST>("FMH::MODEL_LIST");
	qRegisterMetaType<FMH::MODEL>("FMH::MODEL");
    qRegisterMetaType<PULPO::ONTOLOGY>("PULPO::ONTOLOGY");
}

void AlbumsModel::componentComplete()
{
	if(query == QUERY::ALBUMS )
	{
		connect(vvave::instance (), &vvave::albumsAdded, this, &AlbumsModel::setList);
	}else
	{
		connect(vvave::instance (), &vvave::artistsAdded, this, &AlbumsModel::setList);
	}

	connect(vvave::instance (), &vvave::sourceRemoved, this, &AlbumsModel::setList);
	connect(this, &AlbumsModel::queryChanged, this, &AlbumsModel::setList);
	setList();
}

const FMH::MODEL_LIST &AlbumsModel::items() const
{
	return this->list;
}

void AlbumsModel::setQuery(const QUERY &query)
{
	if(this->query == query)
		return;

	this->query = query;
	emit this->queryChanged();
}

AlbumsModel::QUERY AlbumsModel::getQuery() const
{
	return this->query;
}

void AlbumsModel::setList()
{
	emit this->preListChanged();

	QString m_Query;
	if(this->query == AlbumsModel::QUERY::ALBUMS)
		m_Query = "select * from albums order by album asc";
	else if(this->query == AlbumsModel::QUERY::ARTISTS)
		m_Query = "select * from artists order by artist asc";
	else return;

	qDebug() << "Album query is" << m_Query;
	//get albums data with modifier for missing images for artworks
	//    const auto checker = [&](FMH::MODEL &item) -> bool
	//    {
	//        const auto artwork = item[FMH::MODEL_KEY::ARTWORK];

	//        if(artwork.isEmpty())
	//            return true;

	//        if(QUrl(artwork).isLocalFile () && !FMH::fileExists(artwork))
	//        {
	//            this->db->removeArtwork(AlbumsModel::QUERY::ALBUMS ?  "albums" : "artists", FMH::toMap(item));
	//            item[FMH::MODEL_KEY::ARTWORK] = "";
	//        }

	//        return true;
	//    };
	this->list = this->db->getDBData(m_Query);

    emit this->postListChanged();
}

void AlbumsModel::append(const QVariantMap &item)
{
	if(item.isEmpty())
		return;

	emit this->preItemAppended();

	FMH::MODEL model;
	for(auto key : item.keys())
		model.insert(FMH::MODEL_NAME_KEY[key], item[key].toString());

	this->list << model;

	emit this->postItemAppended();
}

void AlbumsModel::append(const QVariantMap &item, const int &at)
{
	if(item.isEmpty())
		return;

	if(at > this->list.size() || at < 0)
		return;

	qDebug()<< "trying to append at" << at << item["title"];

	emit this->preItemAppendedAt(at);

	FMH::MODEL model;
	for(auto key : item.keys())
		model.insert(FMH::MODEL_NAME_KEY[key], item[key].toString());

	this->list.insert(at, model);

	emit this->postItemAppended();
}

void AlbumsModel::refresh()
{
	this->setList();
}
