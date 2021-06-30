#include "tracksmodel.h"
#include "db/collectionDB.h"

#include "vvave.h"
#include "services/local/metadataeditor.h"

#include <MauiKit/FileBrowsing/fmstatic.h>
#include <MauiKit/FileBrowsing/tagging.h>

TracksModel::TracksModel(QObject *parent)
    : MauiList(parent)
    , db(CollectionDB::getInstance())
{
    qRegisterMetaType<TracksModel *>("const TracksModel*");
}

void TracksModel::componentComplete()
{
    connect(this, &TracksModel::queryChanged, this, &TracksModel::setList);
    connect(vvave::instance(), &vvave::tracksAdded, this, &TracksModel::setList);
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
    if (query.isEmpty())
        return;

    emit this->preListChanged();
    this->list.clear();

    QStringList missingFiles;
    qDebug() << "GETTIN TRACK LIST" << this->query;

    if (this->query.startsWith("#")) {
        auto m_query = query;
        const auto urls = Tagging::getInstance()->getTagUrls(m_query.replace("#", ""), {}, true, m_limit, "audio");
        for (const auto &url : urls) {
            this->list << this->db->getDBData(QString("select t.* from tracks t inner join albums al on al.album = t.album "
                                                      "and al.artist = t.artist where t.url = %1")
                                                  .arg("\"" + url.toString() + "\""));
        }

    } else {
                const auto checker = [&](FMH::MODEL &item) {
                    const auto url = QUrl(item[FMH::MODEL_KEY::URL]);
                    if(FMH::fileExists(url))
                    {
                        return true;
                    } else
                    {
                        missingFiles << url.toString();
                        return false;
                    }
                };
        this->list = this->db->getDBData(this->query ,checker);
    }

    qDebug() << "missing files" << missingFiles;

    emit this->postListChanged();
    emit this->countChanged();

    if(missingFiles.size() > 0)
    {
        this->removeMissingFiles(missingFiles);
        emit this->missingFiles(missingFiles);
    }
}

void TracksModel::append(const QVariantMap &item)
{
    if (item.isEmpty())
        return;

    emit this->preItemAppended();
    this->list << FMH::toModel(item);
    emit this->postItemAppended();
    emit this->countChanged();
}

void TracksModel::appendAt(const QVariantMap &item, const int &at)
{
    if (item.isEmpty())
        return;

    if (at > this->list.size() || at < 0)
        return;

    qDebug() << "trying to append at << " << 0;
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

void TracksModel::clear()
{
    emit this->preListChanged();
    this->list.clear();
    emit this->postListChanged();
    emit this->countChanged();
}

bool TracksModel::fav(const int &index, const bool &value)
{
    if (index >= this->list.size() || index < 0)
        return false;

    auto item = this->list[index];

    if (value)
        Tagging::getInstance()->fav(item[FMH::MODEL_KEY::URL]);
    else
        Tagging::getInstance()->unFav(item[FMH::MODEL_KEY::URL]);

    this->list[index][FMH::MODEL_KEY::FAV] = value ? "1" : "0";
    emit this->updateModel(index, {FMH::MODEL_KEY::FAV});

    return true;
}

bool TracksModel::countUp(const int &index)
{
    if (index >= this->list.size() || index < 0)
        return false;

    auto item = this->list[index];
    if (this->db->playedTrack(item[FMH::MODEL_KEY::URL])) {
        this->list[index][FMH::MODEL_KEY::COUNT] = QString::number(item[FMH::MODEL_KEY::COUNT].toInt() + 1);
        emit this->updateModel(index, {FMH::MODEL_KEY::COUNT});

        return true;
    }

    return false;
}

bool TracksModel::remove(const int &index)
{
    qDebug() << "REMOVE AT" << index;

    if (index >= this->list.size() || index < 0)
        return false;

    emit this->preItemRemoved(index);
    this->list.removeAt(index);
    emit this->postItemRemoved();

    return true;
}

void TracksModel::removeMissingFiles(const QStringList &urls)
{
    for(const auto &url : urls)
    {
        this->db->removeTrack(url);
    }
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
    emit this->updateModel(index, roles);
    return true;
}

void TracksModel::updateMetadata(const QVariantMap &data, const int &index)
{
    this->update(data, index);
    auto model = FMH::toModel(data);

    MetadataEditor editor;
    editor.setUrl(model[FMH::MODEL_KEY::URL]);

    editor.setTitle(model[FMH::MODEL_KEY::TITLE]);
    editor.setArtist(model[FMH::MODEL_KEY::ARTIST]);
    editor.setAlbum(model[FMH::MODEL_KEY::ALBUM]);
    editor.setYear(model[FMH::MODEL_KEY::RELEASEDATE].toInt());
    editor.setGenre(model[FMH::MODEL_KEY::GENRE]);
    editor.setComment(model[FMH::MODEL_KEY::COMMENT]);
    editor.setTrack(model[FMH::MODEL_KEY::TRACK].toInt());

    auto n_model = FMH::filterModel(model, {FMH::MODEL_KEY::URL, FMH::MODEL_KEY::TITLE,FMH::MODEL_KEY::ARTIST,FMH::MODEL_KEY::ALBUM,FMH::MODEL_KEY::RELEASEDATE,FMH::MODEL_KEY::GENRE, FMH::MODEL_KEY::TRACK, FMH::MODEL_KEY::COMMENT});

    if(this->db->updateTrack(n_model))
    {
        qDebug() << "Track data was updated correctly";
    }
}

void TracksModel::setLimit(int limit)
{
    if (m_limit == limit)
        return;

    m_limit = limit;
    emit limitChanged(m_limit);
}
