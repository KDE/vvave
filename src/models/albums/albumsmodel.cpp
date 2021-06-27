#include "albumsmodel.h"
#include "db/collectionDB.h"

#include "vvave.h"

#include <MauiKit/FileBrowsing/downloader.h>
#include <MauiKit/FileBrowsing/fmstatic.h>

AlbumsModel::AlbumsModel(QObject *parent)
    : MauiList(parent)
    , db(CollectionDB::getInstance())
{
    qRegisterMetaType<FMH::MODEL_LIST>("FMH::MODEL_LIST");
    qRegisterMetaType<FMH::MODEL>("FMH::MODEL");
}

void AlbumsModel::componentComplete()
{
    if (query == QUERY::ALBUMS) {
        connect(vvave::instance(), &vvave::albumsAdded, this, &AlbumsModel::setList);
    } else {
        connect(vvave::instance(), &vvave::artistsAdded, this, &AlbumsModel::setList);
    }

    connect(vvave::instance(), &vvave::sourceRemoved, this, &AlbumsModel::setList);
    connect(this, &AlbumsModel::queryChanged, this, &AlbumsModel::setList);
    setList();
}

const FMH::MODEL_LIST &AlbumsModel::items() const
{
    return this->list;
}

void AlbumsModel::setQuery(const QUERY &query)
{
    if (this->query == query)
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
    if (this->query == AlbumsModel::QUERY::ALBUMS)
        m_Query = "select * from albums order by album asc";
    else if (this->query == AlbumsModel::QUERY::ARTISTS)
        m_Query = "select * from artists order by artist asc";
    else
        return;

    this->list = this->db->getDBData(m_Query);

    emit this->postListChanged();
}

void AlbumsModel::refresh()
{
    this->setList();
}

int AlbumsModel::indexOfName(const QString &query)
{
    const auto it = std::find_if(this->items().constBegin(), this->items().constEnd(), [&](const FMH::MODEL &item) -> bool {
        return item[this->query == AlbumsModel::QUERY::ALBUMS ? FMH::MODEL_KEY::ALBUM : FMH::MODEL_KEY::ARTIST].startsWith(query, Qt::CaseInsensitive);
    });

    if (it != this->items().constEnd())
        return (std::distance(this->items().constBegin(), it));
    else
        return -1;
}
