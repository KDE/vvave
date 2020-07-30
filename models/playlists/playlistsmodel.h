#ifndef PLAYLISTSMODEL_H
#define PLAYLISTSMODEL_H

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif

class CollectionDB;
class PlaylistsModel : public MauiList
{
    Q_OBJECT

public:
    explicit PlaylistsModel(QObject *parent = nullptr);

    FMH::MODEL_LIST items() const override;
    void componentComplete() override;

private:
    CollectionDB *db;
    FMH::MODEL_LIST list;
    void setList();

    FMH::MODEL_LIST defaultPlaylists();
    FMH::MODEL_LIST tags();
    static FMH::MODEL packPlaylist(const QString &playlist);

signals:
    void sortByChanged();

public slots:

    QVariantMap get(const int &index) const;
    void insert(const QString &playlist);

    void addTrack(const QString &playlist, const QStringList &urls);
    void removeTrack(const QString &playlist, const QString &url);
    void removePlaylist(const int &index);

};

#endif // PLAYLISTSMODEL_H
