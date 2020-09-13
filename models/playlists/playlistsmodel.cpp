#include "playlistsmodel.h"

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#else
#include <MauiKit/tagging.h>
#endif

PlaylistsModel::PlaylistsModel(QObject *parent) : MauiList(parent)
{
    connect(Tagging::getInstance(), &Tagging::tagged, [this](QString tag)
    {
        emit this->preItemAppended();
        this->list << (this->packPlaylist(tag));
        emit this->postItemAppended();
    });
}

void PlaylistsModel::componentComplete()
{
    this->setList();
}

FMH::MODEL_LIST PlaylistsModel::items() const
{
    return this->list;
}

void PlaylistsModel::setList()
{
    emit this->preListChanged();
    this->list << this->defaultPlaylists();
    this->list << this->tags();
    emit this->postListChanged();
}

FMH::MODEL PlaylistsModel::packPlaylist(const QString &playlist)
{
    return FMH::MODEL
    {
        {FMH::MODEL_KEY::PLAYLIST, playlist},
        {FMH::MODEL_KEY::COLOR, "#333"},
        {FMH::MODEL_KEY::ICON, "tag"},
        {FMH::MODEL_KEY::TYPE, "personal"},
        {FMH::MODEL_KEY::DESCRIPTION, "Personal"},
    };
}

FMH::MODEL_LIST PlaylistsModel::defaultPlaylists()
{
    return FMH::MODEL_LIST  {
        //    {
        //    {FMH::MODEL_KEY::DESCRIPTION, "Favorite tracks"},
        //    {FMH::MODEL_KEY::COLOR, "#EC407A"},
        //    {FMH::MODEL_KEY::PLAYLIST, "Favs"},
        //    {FMH::MODEL_KEY::ICON, "love"},
        //    {FMH::MODEL_KEY::ADDDATE, QDateTime::currentDateTime().toString(Qt::DateFormat::TextDate)}
        //},

        {
            {FMH::MODEL_KEY::DESCRIPTION, "Top listened tracks"},
            {FMH::MODEL_KEY::TYPE, "default"},
            {FMH::MODEL_KEY::COLOR, "#FFA000"},
            {FMH::MODEL_KEY::PLAYLIST, "Most Played"},
            {FMH::MODEL_KEY::ICON, "view-media-playcount"},
            {FMH::MODEL_KEY::ADDDATE, QDateTime::currentDateTime().toString(Qt::DateFormat::TextDate)}
        },

        {
            {FMH::MODEL_KEY::DESCRIPTION, "Highest rated tracks"},
            {FMH::MODEL_KEY::TYPE, "default"},
            {FMH::MODEL_KEY::COLOR, "#42A5F5"},
            {FMH::MODEL_KEY::PLAYLIST, "Rating"},
            {FMH::MODEL_KEY::ICON, "view-media-favorite"},
            {FMH::MODEL_KEY::ADDDATE, QDateTime::currentDateTime().toString(Qt::DateFormat::TextDate)}
        }
    };
}

FMH::MODEL_LIST PlaylistsModel::tags()
{
    FMH::MODEL_LIST res;
    const auto tags = Tagging::getInstance()->getUrlsTags(true);

    return std::accumulate(tags.constBegin(), tags.constEnd(), res, [](FMH::MODEL_LIST &list, const QVariant &item)
    {
        const auto map = item.toMap();
        auto res = packPlaylist(map.value("tag").toString());
        res[FMH::MODEL_KEY::ICON] = map.value("icon").toString();
        list << res;
        return list;
    });
}

QVariantMap PlaylistsModel::get(const int &index) const
{
    if(index >= this->list.size() || index < 0)
        return QVariantMap();
    return FMH::toMap(this->list.at(index));
}

void PlaylistsModel::insert(const QString &playlist)
{
    if(playlist.isEmpty())
        return;

    Tagging::getInstance()->tag(playlist);
}

void PlaylistsModel::addTrack(const QString &playlist, const QStringList &urls)
{
    for(const auto &url : urls)
        Tagging::getInstance()->tagUrl(url, playlist);
}

void PlaylistsModel::removeTrack(const QString &playlist, const QString &url)
{  
    qDebug()<< "trying to remove" << playlist << url;
    Tagging::getInstance()->removeUrlTag(url, playlist);
}

void PlaylistsModel::removePlaylist(const int &index) //TODO
{
    if(index >= this->list.size() || index < 0)
        return;

//    if(Tagging::getInstance()->remove(this->list.at(index)[FMH::MODEL_KEY::PLAYLIST]))
//    {
//        emit this->preItemRemoved(index);
//        this->list.removeAt(index);
//        emit this->postItemRemoved();
//    }
}

