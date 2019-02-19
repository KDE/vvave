#include "tracksmodel.h"
#include "db/collectionDB.h"


TracksModel::TracksModel(QObject *parent) : BaseList(parent)
{
    this->db = CollectionDB::getInstance();
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
    qDebug()<< "setting query"<< this->query;

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

    this->preListChanged();
    this->sortList();
    this->postListChanged();
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
    qDebug()<< "SORTING LIST BY"<< this->sort;
    qSort(this->list.begin(), this->list.end(), [key](const FMH::MODEL &e1, const FMH::MODEL &e2) -> bool
    {
        auto role = key;

        switch(role)
        {
        case FMH::MODEL_KEY::RELEASEDATE:
        case FMH::MODEL_KEY::RATE:
        case FMH::MODEL_KEY::FAV:
        case FMH::MODEL_KEY::COUNT:
        {
            if(e1[role].toInt() > e2[role].toInt())
                return true;
            break;
        }

        case FMH::MODEL_KEY::TRACK:
        {
            if(e1[role].toInt() < e2[role].toInt())
                return true;
            break;
        }

        case FMH::MODEL_KEY::ADDDATE:
        {
            auto currentTime = QDateTime::currentDateTime();

            auto date1 = QDateTime::fromString(e1[role], Qt::TextDate);
            auto date2 = QDateTime::fromString(e2[role], Qt::TextDate);

            if(date1.secsTo(currentTime) <  date2.secsTo(currentTime))
                return true;

            break;
        }

        case FMH::MODEL_KEY::TITLE:
        case FMH::MODEL_KEY::ARTIST:
        case FMH::MODEL_KEY::ALBUM:
        case FMH::MODEL_KEY::FORMAT:
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

void TracksModel::setList()
{
    emit this->preListChanged();

    this->list = this->db->getDBData(this->query);

    qDebug()<< "my LIST" ;
    this->sortList();
    emit this->postListChanged();
}

QVariantMap TracksModel::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();

    QVariantMap res;
    const auto item = this->list.at(index);

    for(auto key : item.keys())
        res.insert(FMH::MODEL_NAME[key], item[key]);

    return res;
}

void TracksModel::append(const QVariantMap &item)
{
    if(item.isEmpty())
        return;

    emit this->preItemAppended();

    FMH::MODEL model;
    for(auto key : item.keys())
        model.insert(FMH::MODEL_NAME_KEY[key], item[key].toString());

    qDebug() << "Appending item to list" << item;
    this->list << model;

    qDebug()<< this->list;

    emit this->postItemAppended();
}

void TracksModel::append(const QVariantMap &item, const int &at)
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

void TracksModel::appendQuery(const QString &query)
{
    if(query.isEmpty() || query == this->query)
        return;

    this->query = query;

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
