#include "playlistsmodel.h"
#include "db/collectionDB.h"

PlaylistsModel::PlaylistsModel(QObject *parent) : BaseList(parent),
    db(CollectionDB::getInstance())
{
    this->setList();
}

FMH::MODEL_LIST PlaylistsModel::items() const
{
    return this->list;
}

void PlaylistsModel::setSortBy(const SORTBY &sort)
{
    if(this->sort == sort)
        return;

    this->sort = sort;

    this->preListChanged();
    this->sortList();
    this->postListChanged();
    emit this->sortByChanged();
}

PlaylistsModel::SORTBY PlaylistsModel::getSortBy() const
{
    return this->sort;
}

void PlaylistsModel::sortList()
{
    const auto key = static_cast<FMH::MODEL_KEY>(this->sort);
    qDebug()<< "SORTING LIST BY"<< this->sort;
    qSort(this->list.begin() + this->defaultPlaylists().size(), this->list.end(), [key](const FMH::MODEL &e1, const FMH::MODEL &e2) -> bool
    {
        auto role = key;

        switch(role)
        {
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

void PlaylistsModel::setList()
{
    qDebug()<< "trying to set playlists list";
    emit this->preListChanged();

    this->list << this->db->getPlaylists();
    this->list << this->defaultPlaylists();

    qDebug()<< this->list;

    //    this->sortList();
    emit this->postListChanged();
}

FMH::MODEL PlaylistsModel::packPlaylist(const QString &playlist)
{
    return FMH::MODEL
    {
        {FMH::MODEL_KEY::PLAYLIST, playlist},
        {FMH::MODEL_KEY::ADDDATE, QDateTime::currentDateTime().toString(Qt::DateFormat::TextDate)}
        //        {FMH::MODEL_KEY::ICON, "view-media-playlist"}
    };
}

FMH::MODEL_LIST PlaylistsModel::defaultPlaylists()
{
    return FMH::MODEL_LIST  {
        {
            {FMH::MODEL_KEY::PLAYLIST, "Most Played"},
            {FMH::MODEL_KEY::ICON, "view-media-playcount"},
            {FMH::MODEL_KEY::ADDDATE,QDateTime::currentDateTime().toString(Qt::DateFormat::TextDate)}
        },

        {
            {FMH::MODEL_KEY::PLAYLIST, "Rating"},
            {FMH::MODEL_KEY::ICON, "view-media-favorite"},
            {FMH::MODEL_KEY::ADDDATE,QDateTime::currentDateTime().toString(Qt::DateFormat::TextDate)}
        },

        {
            {FMH::MODEL_KEY::PLAYLIST, "Recent"},
            {FMH::MODEL_KEY::ICON, "view-media-recent"},
            {FMH::MODEL_KEY::ADDDATE,QDateTime::currentDateTime().toString(Qt::DateFormat::TextDate)}
        },

        {
            {FMH::MODEL_KEY::PLAYLIST, "Favs"},
            {FMH::MODEL_KEY::ICON, "love"},
            {FMH::MODEL_KEY::ADDDATE,QDateTime::currentDateTime().toString(Qt::DateFormat::TextDate)}
        },

        {
            {FMH::MODEL_KEY::PLAYLIST, "Online"},
            {FMH::MODEL_KEY::ICON, "internet-services"},
            {FMH::MODEL_KEY::ADDDATE,QDateTime::currentDateTime().toString(Qt::DateFormat::TextDate)}
        },

//        {
//            {FMH::MODEL_KEY::PLAYLIST, "Tags"},
//            {FMH::MODEL_KEY::ICON, "tag"},
//            {FMH::MODEL_KEY::ADDDATE,QDateTime::currentDateTime().toString(Qt::DateFormat::TextDate)}
//        },

//        {
//            {FMH::MODEL_KEY::PLAYLIST, "Relationships"},
//            {FMH::MODEL_KEY::ICON, "view-media-similarartists"},
//            {FMH::MODEL_KEY::ADDDATE,QDateTime::currentDateTime().toString(Qt::DateFormat::TextDate)}
//        },

//        {
//            {FMH::MODEL_KEY::PLAYLIST, "Popular"},
//            {FMH::MODEL_KEY::ICON, "view-media-chart"},
//            {FMH::MODEL_KEY::ADDDATE,QDateTime::currentDateTime().toString(Qt::DateFormat::TextDate)}
//        },

//        {
//            {FMH::MODEL_KEY::PLAYLIST, "Genres"},
//            {FMH::MODEL_KEY::ICON, "view-media-genre"},
//            {FMH::MODEL_KEY::ADDDATE,QDateTime::currentDateTime().toString(Qt::DateFormat::TextDate)}
//        }
    };
}

QVariantMap PlaylistsModel::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();
    return FM::toMap(this->list.at(index));
}

void PlaylistsModel::append(const QVariantMap &item)
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

void PlaylistsModel::append(const QVariantMap &item, const int &at)
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

void PlaylistsModel::insert(const QString &playlist)
{
    if(playlist.isEmpty())
        return;

    emit this->preItemAppended();

    this->list << this->packPlaylist(playlist);

    emit this->postItemAppended();
}

void PlaylistsModel::insertAt(const QString &playlist, const int &at)
{
    if(playlist.isEmpty())
        return;

    if(at > this->list.size() || at < 0)
        return;

    emit this->preItemAppendedAt(at);

    if(this->db->addPlaylist(playlist))
        this->list.insert(at, this->packPlaylist(playlist));

    emit this->postItemAppended();

}

void PlaylistsModel::addTrack(const int &index, const QStringList &urls)
{
    if(index >= this->list.size() || index < 0)
        return;

    for(auto url : urls)
        this->db->trackPlaylist(url, this->list[index][FMH::MODEL_KEY::PLAYLIST]);
}

void PlaylistsModel::removeTrack(const int &index, const QString &url)
{
    if(index >= this->list.size() || index < 0)
        return;

    this->db->removePlaylistTrack(url, this->list.at(index)[FMH::MODEL_KEY::PLAYLIST]);
}

void PlaylistsModel::removePlaylist(const int &index)
{
    if(index >= this->list.size() || index < 0)
        return;

    if(this->db->removePlaylist(this->list.at(index)[FMH::MODEL_KEY::PLAYLIST]))
    {
        emit this->preItemRemoved(index);
        this->list.removeAt(index);
        emit this->postItemRemoved();
    }
}
