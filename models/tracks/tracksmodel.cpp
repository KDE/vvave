#include "tracksmodel.h"
#include "db/collectionDB.h"


<<<<<<< Updated upstream
TracksModel::TracksModel(QObject *parent) : MauiList(parent),
    db(CollectionDB::getInstance())
=======
<<<<<<< Updated upstream
TracksModel::TracksModel(QObject *parent) : BaseList(parent)
=======
TracksModel::TracksModel(QObject *parent) : MauiList(parent),
    db(CollectionDB::getInstance()) {}

void TracksModel::componentComplete()
>>>>>>> Stashed changes
>>>>>>> Stashed changes
{
    connect(this, &TracksModel::queryChanged, this, &TracksModel::setList);
}

FMH::MODEL_LIST TracksModel::items() const
{
    return this->list;
}

void TracksModel::setQuery(const QString &query)
{
    if(this->query == query)
        return;

    this->query = query;
    emit this->queryChanged();
}

QString TracksModel::getQuery() const
{
    return this->query;
}

void TracksModel::setSortBy(const SORTBY &sort)
{
    if(this->sort == sort)
        return;

    this->sort = sort;

    emit this->preListChanged();
    this->sortList();
    emit this->postListChanged();
    emit this->sortByChanged();
}

TracksModel::SORTBY TracksModel::getSortBy() const
{
    return this->sort;
}

void TracksModel::sortList()
{
    if(this->sort == TracksModel::SORTBY::NONE)
        return;

    const auto key = static_cast<FMH::MODEL_KEY>(this->sort);
    qSort(this->list.begin(), this->list.end(), [key](const FMH::MODEL &e1, const FMH::MODEL &e2) -> bool
    {
        switch(key)
        {
        case FMH::MODEL_KEY::RELEASEDATE:
        case FMH::MODEL_KEY::RATE:
        case FMH::MODEL_KEY::FAV:
        case FMH::MODEL_KEY::COUNT:
        {
            if(e1[key].toInt() > e2[key].toInt())
                return true;
            break;
        }

        case FMH::MODEL_KEY::TRACK:
        {
            if(e1[key].toInt() < e2[key].toInt())
                return true;
            break;
        }

        case FMH::MODEL_KEY::ADDDATE:
        {
            auto currentTime = QDateTime::currentDateTime();

            auto date1 = QDateTime::fromString(e1[key], Qt::TextDate);
            auto date2 = QDateTime::fromString(e2[key], Qt::TextDate);

            if(date1.secsTo(currentTime) <  date2.secsTo(currentTime))
                return true;

            break;
        }

        case FMH::MODEL_KEY::TITLE:
        case FMH::MODEL_KEY::ARTIST:
        case FMH::MODEL_KEY::ALBUM:
        case FMH::MODEL_KEY::FORMAT:
        {
            const auto str1 = QString(e1[key]).toLower();
            const auto str2 = QString(e2[key]).toLower();

            if(str1 < str2)
                return true;
            break;
        }

        default:
            if(e1[key] < e2[key])
                return true;
        }

        return false;
    });
}

void TracksModel::setList()
{
    emit this->preListChanged();
    this->list = this->db->getDBData(this->query);
    this->sortList();
    emit this->postListChanged();
}

QVariantMap TracksModel::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();
    return FMH::toMap(this->list.at(index));
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
}

void TracksModel::appendQuery(const QString &query)
{
    emit this->preListChanged();
    this->list << this->db->getDBData(query);
    emit this->postListChanged();
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
}

bool TracksModel::color(const int &index, const QString &color)
{
    if(index >= this->list.size() || index < 0)
        return false;

    auto item = this->list[index];
    if(this->db->colorTagTrack(item[FMH::MODEL_KEY::URL], color))
    {
        this->list[index][FMH::MODEL_KEY::COLOR] = color;
        emit this->updateModel(index, {FMH::MODEL_KEY::COLOR});
        return true;
    }

    return false;
}

bool TracksModel::fav(const int &index, const bool &value)
{
    if(index >= this->list.size() || index < 0)
        return false;

    auto item = this->list[index];
    if(this->db->favTrack(item[FMH::MODEL_KEY::URL], value))
    {
        this->list[index][FMH::MODEL_KEY::FAV] = value ?  "1" : "0";
        emit this->updateModel(index, {FMH::MODEL_KEY::FAV});
        qDebug()<< "FAVVING TRACKS"<< item;
        return true;
    }

    return false;
}

bool TracksModel::rate(const int &index, const int &value)
{
    if(index >= this->list.size() || index < 0)
        return false;

    auto item = this->list[index];
    if(this->db->rateTrack(item[FMH::MODEL_KEY::URL], value))
    {
        this->list[index][FMH::MODEL_KEY::RATE] = QString::number(value);
        emit this->updateModel(index, {FMH::MODEL_KEY::RATE});

        return true;
    }

    return false;
}

bool TracksModel::countUp(const int &index)
{
    if(index >= this->list.size() || index < 0)
        return false;

    auto item = this->list[index];
    if(this->db->playedTrack(item[FMH::MODEL_KEY::URL]))
    {
        this->list[index][FMH::MODEL_KEY::COUNT] = QString::number(item[FMH::MODEL_KEY::COUNT].toInt() + 1);
        emit this->updateModel(index, {FMH::MODEL_KEY::COUNT});

        return true;
    }

    return false;
}

bool TracksModel::remove(const int &index)
{
    if(index >= this->list.size() || index < 0)
        return false;

    emit this->preItemRemoved(index);
    this->list.removeAt(index);
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

    auto newData = this->list[index];
    QVector<int> roles;

    for(auto key : data.keys())
        if(newData[FMH::MODEL_NAME_KEY[key]] != data[key].toString())
        {
            newData.insert(FMH::MODEL_NAME_KEY[key], data[key].toString());
            roles << FMH::MODEL_NAME_KEY[key];
        }

    this->list[index] = newData;
    emit this->updateModel(index, roles);
    return true;

}
