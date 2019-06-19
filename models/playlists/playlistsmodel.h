#ifndef PLAYLISTSMODEL_H
#define PLAYLISTSMODEL_H

#include "models/baselist.h"

class CollectionDB;
class PlaylistsModel : public BaseList
{
    Q_OBJECT
    Q_PROPERTY(PlaylistsModel::SORTBY sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)

public:

    enum SORTBY : uint_fast8_t
    {
        ADDDATE = FMH::MODEL_KEY::ADDDATE,
        TITLE = FMH::MODEL_KEY::TITLE
    }; Q_ENUM(SORTBY)

    explicit PlaylistsModel(QObject *parent = nullptr);

    FMH::MODEL_LIST items() const override;

    void setSortBy(const PlaylistsModel::SORTBY &sort);
    PlaylistsModel::SORTBY getSortBy() const;

private:
    CollectionDB *db;
    FMH::MODEL_LIST list;
    void sortList();
    void setList();

    FMH::MODEL packPlaylist(const QString &playlist);

    FMH::MODEL_LIST defaultPlaylists();

    PlaylistsModel::SORTBY sort = PlaylistsModel::SORTBY::ADDDATE;

signals:
    void sortByChanged();

public slots:
    QVariantMap get(const int &index) const override;
    void append(const QVariantMap &item);
    void append(const QVariantMap &item, const int &at);
    void insert(const QString &playlist);
    void insertAt(const QString &playlist, const int &at);
    void addTrack(const int &index, const QStringList &urls);
    void removeTrack(const int &index, const QString &url);
    void removePlaylist(const int &index);
};

#endif // PLAYLISTSMODEL_H
