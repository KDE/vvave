#include "tracksmodel.h"
#include "db/collectionDB.h"

#include "vvave.h"
#include "services/local/metadataeditor.h"

#include <MauiKit4/FileBrowsing/fmstatic.h>
#include <MauiKit4/FileBrowsing/tagging.h>

#include <QTimer>

TracksModel::TracksModel(QObject *parent)
    : MauiList(parent)
{
    qRegisterMetaType<TracksModel *>("const TracksModel*");
}

void TracksModel::componentComplete()
{
    auto tracksTimer = new QTimer(this);
    tracksTimer->setSingleShot(true);
    tracksTimer->setInterval(1000);

    connect(CollectionDB::getInstance(), &CollectionDB::trackInserted, [this, tracksTimer](QVariantMap)
    {
        m_newTracks++;
        tracksTimer->start();
    });

    connect(tracksTimer, &QTimer::timeout, [this]()
    {
        if (m_newTracks > 0)
        {
            this->setList();
            m_newTracks = 0;
        }
    });

    connect(this, &TracksModel::queryChanged, this, &TracksModel::setList);
    connect(vvave::instance(), &vvave::sourceRemoved, this, &TracksModel::setList);
    setList();
}

const FMH::MODEL_LIST &TracksModel::items() const
{
    return this->list;
}

void TracksModel::setQuery(const QString &query)
{
    //    if(this->query == query)
    //        return;

    this->query = query;
    Q_EMIT this->queryChanged();
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
    if (query.isEmpty())
        return;

    Q_EMIT this->preListChanged();
    this->list.clear();

    qDebug() << "GETTIN TRACK LIST" << this->query;

    if (this->query.startsWith("#"))
    {
        auto m_query = query;
        const auto urls = Tagging::getInstance()->getTagUrls(m_query.replace("#", ""), {}, true, m_limit, "audio");
        for (const auto &url : urls) {
            this->list << CollectionDB::getInstance()->getDBData(QString("select t.* from tracks t inner join albums al on al.album = t.album "
                                                                         "and al.artist = t.artist where t.url = %1")
                                                                 .arg("\"" + url.toString() + "\""));
        }

    } else
    {
        this->list = CollectionDB::getInstance()->getDBData(this->query);
    }

    Q_EMIT this->postListChanged();
    Q_EMIT this->countChanged();
}

bool TracksModel::append(const QVariantMap &item)
{
    if (item.isEmpty())
        return false;

    Q_EMIT this->preItemAppended();
    this->list << FMH::toModel(item);
    Q_EMIT this->postItemAppended();
    Q_EMIT this->countChanged();

    return true;
}

bool TracksModel::appendUrl(const QUrl &url)
{
    if (CollectionDB::getInstance()->check_existance(BAE::TABLEMAP[BAE::TABLE::TRACKS], FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url.toString()))
    {
        const auto item = CollectionDB::getInstance()->getDBData(QStringList() << url.toString());
       return append(FMH::toMap(item.first()));
    } else
    {
       return append(FMH::toMap(vvave::trackInfo(url)));
    }
}

bool TracksModel::insertUrl(const QString &url, const int &index)
{
    if (CollectionDB::getInstance()->check_existance(BAE::TABLEMAP[BAE::TABLE::TRACKS], FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url))
    {
        const auto item = CollectionDB::getInstance()->getDBData(QStringList() << url);
        return appendAt(FMH::toMap(item.first()), index);
    } else
    {
        return appendAt(FMH::toMap(vvave::trackInfo(QUrl(url))), index);
    }
}

bool TracksModel::insertUrls(const QStringList &urls, const int &index)
{
    if(urls.isEmpty())
    {
        return false;
    }

    uint i = 0;
    for(const auto &url : urls)
    {
        qDebug() << "URLS OT INSERT" << url;

        if(this->insertUrl(url, index+i))
        {
            qDebug() << "URLS OT INSERT" << url;
            i++;
        }
    }

    return true;
}

bool TracksModel::appendUrls(const QStringList &urls)
{
    for(const auto &url : QUrl::fromStringList(urls))
    {
        this->appendUrl(url);
    }

    return true;
}

bool TracksModel::appendAt(const QVariantMap &item, const int &at)
{
    if (item.isEmpty())
        return false;

    if (at > this->list.size() || at < 0)
        return false;

    qDebug() << "trying to append at << " << 0;
    Q_EMIT this->preItemAppendedAt(at);
    this->list.insert(at, FMH::toModel(item));
    Q_EMIT this->postItemAppended();
    Q_EMIT this->countChanged();
    return true;
}

bool TracksModel::appendQuery(const QString &query)
{
    Q_EMIT this->preListChanged();
    this->list << CollectionDB::getInstance()->getDBData(query);
    Q_EMIT this->postListChanged();
    Q_EMIT this->countChanged();
    return true;
}

void TracksModel::copy(const TracksModel *list)
{
    if(!list)
    {
        return;
    }

    Q_EMIT this->preItemsAppended(list->getCount());
    this->list <<  list->items();
    Q_EMIT this->postItemAppended();
    Q_EMIT this->countChanged();
}

void TracksModel::clear()
{
    Q_EMIT this->preListChanged();
    this->list.clear();
    Q_EMIT this->postListChanged();
    Q_EMIT this->countChanged();
}

bool TracksModel::fav(const int &index, const bool &value)
{
    if (index >= this->list.size() || index < 0)
        return false;

    auto item = this->list[index];

    if (value)
        Tagging::getInstance()->fav(QUrl(item[FMH::MODEL_KEY::URL]));
    else
        Tagging::getInstance()->unFav(QUrl(item[FMH::MODEL_KEY::URL]));

    return true;
}

bool TracksModel::countUp(const int &index)
{
    if (index >= this->list.size() || index < 0)
        return false;

    qDebug() << "COUNT UP TRACK" << index;
    auto item = this->list[index];
    if (CollectionDB::getInstance()->playedTrack(item[FMH::MODEL_KEY::URL])) {
        this->list[index][FMH::MODEL_KEY::COUNT] = QString::number(item[FMH::MODEL_KEY::COUNT].toInt() + 1);
        Q_EMIT this->updateModel(index, {FMH::MODEL_KEY::COUNT});

        return true;
    }

    return false;
}

bool TracksModel::remove(const int &index)
{
    qDebug() << "REMOVE AT" << index;

    if (index >= this->list.size() || index < 0)
        return false;

    Q_EMIT this->preItemRemoved(index);
    this->list.removeAt(index);
    Q_EMIT this->postItemRemoved();

    return true;
}

bool TracksModel::erase(const int &index)
{
    qDebug() << "ERASE AT" << index;

    if (index >= this->list.size() || index < 0)
        return false;
    auto url = this->list.at(index)[FMH::MODEL_KEY::URL];

    if(this->remove(index))
    {
        return CollectionDB::getInstance()->removeTrack(url);
    }

    return false;
}

bool TracksModel::removeMissing(const int &index)
{
    return erase(index);
}

void TracksModel::refresh()
{
    this->setList();
}

bool TracksModel::update(const QVariantMap &data, const int &index)
{
    if (index >= this->list.size() || index < 0)
        return false;

    auto newData = this->list[index];
    QVector<int> roles;
    const auto keys = data.keys();
    for (const auto &key : keys)
    {
        if (newData[FMH::MODEL_NAME_KEY[key]] != data[key].toString()) {
            newData.insert(FMH::MODEL_NAME_KEY[key], data[key].toString());
            roles << FMH::MODEL_NAME_KEY[key];
        }
    }

    this->list[index] = newData;
    Q_EMIT this->updateModel(index, roles);
    return true;
}

void TracksModel::updateMetadata(const QVariantMap &data, const int &index)
{
    this->update(data, index);
    auto model = FMH::toModel(data);

    MetadataEditor editor;
    editor.setUrl(QUrl(model[FMH::MODEL_KEY::URL]));

    editor.setTitle(model[FMH::MODEL_KEY::TITLE]);
    editor.setArtist(model[FMH::MODEL_KEY::ARTIST]);
    editor.setAlbum(model[FMH::MODEL_KEY::ALBUM]);
    editor.setYear(model[FMH::MODEL_KEY::RELEASEDATE].toInt());
    editor.setGenre(model[FMH::MODEL_KEY::GENRE]);
    editor.setComment(model[FMH::MODEL_KEY::COMMENT]);
    editor.setTrack(model[FMH::MODEL_KEY::TRACK].toInt());

    auto n_model = FMH::filterModel(model, {FMH::MODEL_KEY::URL, FMH::MODEL_KEY::TITLE,FMH::MODEL_KEY::ARTIST,FMH::MODEL_KEY::ALBUM,FMH::MODEL_KEY::RELEASEDATE,FMH::MODEL_KEY::GENRE, FMH::MODEL_KEY::TRACK, FMH::MODEL_KEY::COMMENT});

    if(CollectionDB::getInstance()->updateTrack(n_model))
    {
        qDebug() << "Track data was updated correctly";
    }
}

bool TracksModel::move(const int &index, const int &to)
{
    if (index >= this->list.size() || index < 0)
        return false;

    if (to >= this->list.size() || to < 0)
        return false;

    this->list.move(index, to);
    Q_EMIT this->itemMoved(index, to);
    return true;
}

QStringList TracksModel::urls() const
{
    return FMH::modelToList(this->list, FMH::MODEL_KEY::URL);
}

void TracksModel::setLimit(int limit)
{
    if (m_limit == limit)
        return;

    m_limit = limit;
    Q_EMIT limitChanged(m_limit);
}
