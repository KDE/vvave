#include "albumsmodel.h"
#include "db/collectionDB.h"

#include "vvave.h"

#include <MauiKit/FileBrowsing/downloader.h>
#include <MauiKit/FileBrowsing/fmstatic.h>

#include <QTimer>

AlbumsModel::AlbumsModel(QObject *parent)
    : MauiList(parent)
{
    qRegisterMetaType<FMH::MODEL_LIST>("FMH::MODEL_LIST");
    qRegisterMetaType<FMH::MODEL>("FMH::MODEL");
}

void AlbumsModel::componentComplete()
{
    auto timer = new QTimer(this);
    timer->setSingleShot(true);
    timer->setInterval(1000);

    if (query == QUERY::ALBUMS) {

        connect(CollectionDB::getInstance(), &CollectionDB::albumInserted, [this, timer](QVariantMap) {
            m_newAlbums++;
            timer->start();
        });

        connect(timer, &QTimer::timeout, [this]()
        {
            if (m_newAlbums > 0) {
                this->setList();
                m_newAlbums = 0;
            }
        });

    } else {

        connect(CollectionDB::getInstance(), &CollectionDB::artistInserted, [this, timer](QVariantMap) {
            m_newAlbums++;
            timer->start();
        });

        connect(timer, &QTimer::timeout, [this]()
        {
            if (m_newAlbums > 0) {
                this->setList();
                m_newAlbums = 0;
            }
        });
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

    this->list = CollectionDB::getInstance()->getDBData(m_Query);

    emit this->postListChanged();
    emit this->countChanged();
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
