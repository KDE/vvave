#ifndef PLAYLISTSMODEL_H
#define PLAYLISTSMODEL_H

#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>

class PlaylistsModel : public MauiList
{
    Q_OBJECT

public:
    explicit PlaylistsModel(QObject *parent = nullptr);
    const FMH::MODEL_LIST &items() const override;
    void componentComplete() override;

private:
    FMH::MODEL_LIST list;
    void setList();

    FMH::MODEL_LIST defaultPlaylists();
    FMH::MODEL_LIST tags();
    FMH::MODEL packPlaylist(const QString &playlist);
    QString playlistArtworkPreviews(const QString &playlist);

signals:
    void sortByChanged();
    void fileTagged(QUrl url, QString playlist);

public slots:
    QVariantMap get(const int &index) const;
    void insert(const QString &playlist);

    void addTrack(const QString &playlist, const QStringList &urls);
    void removeTrack(const QString &playlist, const QString &url);
    void removePlaylist(const int &index);

};

#endif // PLAYLISTSMODEL_H
