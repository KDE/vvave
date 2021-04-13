#include "playlistsmodel.h"
#include "db/collectionDB.h"

#include <MauiKit/FileBrowsing/fmstatic.h>
#include <MauiKit/FileBrowsing/tagging.h>

PlaylistsModel::PlaylistsModel(QObject *parent)
    : MauiList(parent)
{
    connect(Tagging::getInstance(), &Tagging::tagged, [this](QVariantMap tag) {
        emit this->preItemAppended();
        this->list << (this->packPlaylist(tag.value("tag").toString()));
        emit this->postItemAppended();
    });

    connect(Tagging::getInstance(), &Tagging::urlTagged, [this](QUrl, QString tag) {
        const auto index = this->mappedIndex(this->indexOf(FMH::MODEL_KEY::PLAYLIST, tag));
        auto item = this->list[index];
        item[FMH::MODEL_KEY::PREVIEW] = playlistArtworkPreviews(tag);
        this->list[index] = item;
       emit this->updateModel(index, {});
    });
}

void PlaylistsModel::componentComplete()
{
    this->setList();
}

const FMH::MODEL_LIST &PlaylistsModel::items() const
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
    return FMH::MODEL{{FMH::MODEL_KEY::PLAYLIST, playlist},
                      {FMH::MODEL_KEY::COLOR, "#333"},
                      {FMH::MODEL_KEY::ICON, "tag"},
                      {FMH::MODEL_KEY::TYPE, "personal"},
                      {FMH::MODEL_KEY::DESCRIPTION, "Personal"},
                      {FMH::MODEL_KEY::PREVIEW, playlistArtworkPreviews(playlist)}};
}

QString PlaylistsModel::playlistArtworkPreviews(const QString &playlist)
{
    QStringList res;
    if (playlist == "Most Played") {
        const auto data = CollectionDB::getInstance()->getDBData(QString("select t.* from tracks t inner join albums al on t.album = al.album and t.artist = al.artist WHERE t.count > 0 ORDER BY count desc LIMIT 4"));
        for (const auto &item : data) {
            res << QString("image://artwork/album:%1:%2").arg(item[FMH::MODEL_KEY::ARTIST], item[FMH::MODEL_KEY::ALBUM]);
        }

        return res.join(",");
    }

    const auto urls = Tagging::getInstance()->getTagUrls(playlist, {}, true, 4, "audio");
    for (const auto &url : urls) {
        const auto data = CollectionDB::getInstance()->getDBData(QString("select t.* from tracks t inner join albums al on al.album = t.album and al.artist = t.artist where t.url = %1").arg("\"" + url.toString() + "\""));

        for (const auto &item : data) {
            res << QString("image://artwork/album:%1:%2").arg(item[FMH::MODEL_KEY::ARTIST], item[FMH::MODEL_KEY::ALBUM]);
        }
    }

    return res.join(",");
}

FMH::MODEL_LIST PlaylistsModel::defaultPlaylists()
{
    return FMH::MODEL_LIST{//    {
                           //    {FMH::MODEL_KEY::DESCRIPTION, "Favorite tracks"},
                           //    {FMH::MODEL_KEY::COLOR, "#EC407A"},
                           //    {FMH::MODEL_KEY::PLAYLIST, "Favs"},
                           //    {FMH::MODEL_KEY::ICON, "love"},
                           //    {FMH::MODEL_KEY::ADDDATE, QDateTime::currentDateTime().toString(Qt::DateFormat::TextDate)}
                           //},

                           {{FMH::MODEL_KEY::DESCRIPTION, "Top listened tracks"},
                            {FMH::MODEL_KEY::TYPE, "default"},
                            {FMH::MODEL_KEY::COLOR, "#FFA000"},
                            {FMH::MODEL_KEY::PLAYLIST, "Most Played"},
                            {FMH::MODEL_KEY::PREVIEW, playlistArtworkPreviews("Most Played")},
                            {FMH::MODEL_KEY::ICON, "view-media-playcount"},
                            {FMH::MODEL_KEY::ADDDATE, QDateTime::currentDateTime().toString(Qt::DateFormat::TextDate)}}};
}

FMH::MODEL_LIST PlaylistsModel::tags()
{
    FMH::MODEL_LIST res;
    const auto tags = Tagging::getInstance()->getUrlsTags(true);

    return std::accumulate(tags.constBegin(), tags.constEnd(), res, [this](FMH::MODEL_LIST &list, const QVariant &item) {
        const auto map = item.toMap();
        auto res = packPlaylist(map.value("tag").toString());
        res[FMH::MODEL_KEY::ICON] = map.value("icon").toString();
        list << res;
        return list;
    });
}

QVariantMap PlaylistsModel::get(const int &index) const
{
    if (index >= this->list.size() || index < 0)
        return QVariantMap();
    return FMH::toMap(this->list.at(index));
}

void PlaylistsModel::insert(const QString &playlist)
{
    if (playlist.isEmpty())
        return;

    Tagging::getInstance()->tag(playlist);
}

void PlaylistsModel::addTrack(const QString &playlist, const QStringList &urls)
{
    for (const auto &url : urls)
        Tagging::getInstance()->tagUrl(url, playlist);
}

void PlaylistsModel::removeTrack(const QString &playlist, const QString &url)
{
    qDebug() << "trying to remove" << playlist << url;
    Tagging::getInstance()->removeUrlTag(url, playlist);
}

void PlaylistsModel::removePlaylist(const int &index) // TODO
{
    if (index >= this->list.size() || index < 0)
        return;

    //    if(Tagging::getInstance()->remove(this->list.at(index)[FMH::MODEL_KEY::PLAYLIST]))
    //    {
    //        emit this->preItemRemoved(index);
    //        this->list.removeAt(index);
    //        emit this->postItemRemoved();
    //    }
}
