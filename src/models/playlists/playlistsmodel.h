#pragma once
#include <MauiKit3/Core/mauilist.h>

class PlaylistsModel : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(int limit READ limit WRITE setLimit NOTIFY limitChanged)

public:
    explicit PlaylistsModel(QObject *parent = nullptr);
    const FMH::MODEL_LIST &items() const override;

    int limit() const;
    void setLimit(int newLimit);

private:
    FMH::MODEL_LIST list;
    void setList();

    FMH::MODEL_LIST defaultPlaylists();
    FMH::MODEL_LIST tags();
    FMH::MODEL packPlaylist(const QString &playlist);
    QString playlistArtworkPreviews(const QString &playlist);

    int m_limit = 9999;

signals:
    void sortByChanged();
    void fileTagged(QUrl url, QString playlist);

    void limitChanged();

public slots:
    void insert(const QString &playlist);

    void addTrack(const QString &playlist, const QStringList &urls);
    void removeTrack(const QString &playlist, const QString &url);
    void removePlaylist(const int &index);

    // QQmlParserStatus interface
public:
    void componentComplete() override;
};

