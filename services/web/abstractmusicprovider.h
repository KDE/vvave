#ifndef ABSTRACTMUSICPROVIDER_H
#define ABSTRACTMUSICPROVIDER_H

#include <QObject>
#ifdef STATIC_MAUIKIT
#include "fmh.h"
#else
#include <MauiKit/fmh.h>
#endif
/**
 * @brief The AbstractMusicSyncer class
 * is an abstraction for different services backend to stream music.
 * Different services to be added to VVave are expected to derived from this.
 */

class AbstractMusicProvider : public QObject
{
    Q_OBJECT
public:
    explicit AbstractMusicProvider(QObject *parent = nullptr);
    virtual ~AbstractMusicProvider() {}

    virtual void getCollection(const std::initializer_list<QString> &parameters = {}) = 0;

    virtual void getTracks() = 0;
    virtual void getTrack(const QString &id) = 0;

    virtual void getArtists() = 0;
    virtual void getArtist(const QString &id) = 0;

    virtual void getAlbums() = 0;
    virtual void getAlbum(const QString &id) = 0;

    virtual void getPlaylists() = 0;
    virtual void getPlaylist(const QString &id) = 0;

    virtual void getFolders() = 0;
    virtual void getFolder(const QString &id) = 0;

    virtual QVariantList getAlbumsList() const {return QVariantList();}
    virtual QVariantList getArtistsList() const {return QVariantList();}
    /**
     * @brief setCredentials
     * sets the credential to authenticate to the provider server
     * @param account
     * the account data is represented by FMH::MODEL
     */
    virtual void setCredentials(const FMH::MODEL &account) final
    {
        this->m_user = account[FMH::MODEL_KEY::USER];
        this->m_password = account[FMH::MODEL_KEY::PASSWORD];
        this->m_provider = account[FMH::MODEL_KEY::SERVER];
    }

    virtual QString user() final { return this->m_user; }
    virtual QString provider() final { return this->m_provider; }
protected:
    QString m_user = "";
    QString m_password = "";
    QString m_provider = "";

signals:
    void collectionReady(FMH::MODEL_LIST data);
    void tracksReady(FMH::MODEL_LIST data);
    void trackReady(FMH::MODEL data);
    void artistsRedy(FMH::MODEL_LIST data);
    void artistReady(FMH::MODEL data);
    void albumsReady(FMH::MODEL_LIST data);
    void albumReady(FMH::MODEL data);
    void playlistsReady(FMH::MODEL_LIST data);
    void playlistReady(FMH::MODEL data);

    void trackPathReady(QString id, QString path);

public slots:
};

#endif // ABSTRACTMUSICPROVIDER_H
