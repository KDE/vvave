#ifndef NEXTMUSIC_H
#define NEXTMUSIC_H

#include <QObject>
#include "abstractmusicprovider.h"

class NextMusic : public AbstractMusicProvider
{
    Q_OBJECT
public:
    explicit NextMusic(QObject *parent = nullptr);    

private:
    const static QString API;
    static const QString formatUrl(const QString &user, const QString &password, const QString &provider);

    FMH::MODEL_LIST parseCollection(const QByteArray &array);

signals:

public slots:

    // AbstractMusicProvider interface
public:
    void getTrackPath(const QString &id);

    void getCollection(const std::initializer_list<QString> &parameters = {}) override final;
    void getTracks() override final;
    void getTrack(const QString &id) override final;
    void getArtists() override final;
    void getArtist(const QString &id) override final;
    void getAlbums() override final;
    void getAlbum(const QString &id) override final;
    void getPlaylists() override final;
    void getPlaylist(const QString &id) override final;
    void getFolders() override final;
    void getFolder(const QString &id) override final;
};

#endif // NEXTMUSIC_H
