#ifndef COLLECTIONDB_H
#define COLLECTIONDB_H
#include <QString>
#include <QStringList>
#include <QList>
#include <QSqlDatabase>
#include <QDebug>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QSqlDriver>
#include <QFileInfo>
#include <QDir>
#include <QVariantMap>

#include "../utils/bae.h"

enum sourceTypes
    {
    LOCAL, ONLINE, DEVICE
    };

class CollectionDB : public QObject
{
        Q_OBJECT

    public:
        explicit CollectionDB( QObject *parent = nullptr);
        ~CollectionDB() override;

        bool insert(const QString &tableName, const QVariantMap &insertData);
        bool update(const QString &tableName, const BAE::DB &updateData, const QVariantMap &where);
        bool update(const QString &table, const QString &column, const QVariant &newValue, const QVariant &op, const QString &id);
        bool remove();

        bool execQuery(QSqlQuery &query) const;
        bool execQuery(const QString &queryTxt);

        /*basic public actions*/
        void prepareCollectionDB() const;
        bool check_existance(const QString &tableName, const QString &searchId, const QString &search);

        /* usefull actions */

        void insertArtwork(const BAE::DB &track);

        void addTrack(const BAE::DB &track);
        bool updateTrack(const BAE::DB &track);
        Q_INVOKABLE bool rateTrack(const QString &path, const int &value);
        Q_INVOKABLE bool colorTagTrack(const QString &path, const QString &value);
        Q_INVOKABLE QString trackColorTag(const QString &path);

        bool lyricsTrack(const BAE::DB &track, const QString &value);
        Q_INVOKABLE bool playedTrack(const QString &url, const int &increment = 1);

        bool wikiTrack(const BAE::DB &track, const QString &value);
        bool tagsTrack(const BAE::DB &track, const QString &value, const QString &context);
        bool albumTrack(const BAE::DB &track, const QString &value);
        bool trackTrack(const BAE::DB &track, const QString &value);
        bool wikiArtist(const BAE::DB &track, const QString &value);
        bool tagsArtist(const BAE::DB &track, const QString &value, const QString &context = "");

        bool wikiAlbum(const BAE::DB &track, QString value);
        bool tagsAlbum(const BAE::DB &track, const QString &value, const QString &context = "");

        Q_INVOKABLE bool addPlaylist(const QString &title);

        bool addFolder(const QString &url);
        bool removeFolder(const QString &url);

        BAE::DB_LIST getDBData(const QStringList &urls);
        BAE::DB_LIST getDBData(const QString &queryTxt);
        QVariantList getDBDataQML(const QString &queryTxt);
        QStringList dataToList(const BAE::DB_LIST &list, const BAE::KEY &key);

        BAE::DB_LIST getAlbumTracks(const QString &album, const QString &artist, const BAE::KEY &orderBy = BAE::KEY::TRACK, const BAE::W &order = BAE::W::ASC);
        BAE::DB_LIST getArtistTracks(const QString &artist, const BAE::KEY &orderBy = BAE::KEY::ALBUM, const BAE::W &order = BAE::W::ASC);
        BAE::DB_LIST getBabedTracks(const BAE::KEY &orderBy = BAE::KEY::PLAYED, const BAE::W &order = BAE::W::DESC);
        QVariantList getSearchedTracks(const BAE::KEY &where, const QString &search);
        BAE::DB_LIST getPlaylistTracks(const QString &playlist, const BAE::KEY &orderBy = BAE::KEY::ADD_DATE, const BAE::W &order = BAE::W::DESC);
        BAE::DB_LIST getMostPlayedTracks(const int &greaterThan = 1,const int &limit = 50, const BAE::KEY &orderBy = BAE::KEY::PLAYED, const BAE::W &order = BAE::W::DESC);
        BAE::DB_LIST getFavTracks(const int &stars = 1,const int &limit = 50, const BAE::KEY &orderBy = BAE::KEY::STARS, const BAE::W &order = BAE::W::DESC);
        BAE::DB_LIST getRecentTracks(const int &limit = 50, const BAE::KEY &orderBy = BAE::KEY::ADD_DATE, const BAE::W &order = BAE::W::DESC);
        BAE::DB_LIST getOnlineTracks(const BAE::KEY &orderBy = BAE::KEY::ADD_DATE, const BAE::W &order = BAE::W::DESC);

        Q_INVOKABLE QStringList getSourcesFolders();

        QStringList getTrackTags(const QString &path);
        Q_INVOKABLE int getTrackStars(const QString &path);
        //    QStringList getArtistTags(const QString &artist);
        //    QStringList getAlbumTags(const QString &album, const QString &artist);
        QStringList getArtistAlbums(const QString &artist);

        Q_INVOKABLE QStringList getPlaylists();

        Q_INVOKABLE bool removePlaylistTrack(const QString &url, const QString &playlist);
        Q_INVOKABLE bool removePlaylist(const QString &playlist);
        Q_INVOKABLE void removeMissingTracks();
        bool removeArtist(const QString &artist);
        bool cleanArtists();
        bool removeAlbum(const QString &album, const QString &artist);
        bool cleanAlbums();
        Q_INVOKABLE bool removeSource(const QString &url);
        Q_INVOKABLE bool removeTrack(const QString &path);
        QSqlQuery getQuery(const QString &queryTxt);
        /*useful tools*/
        sourceTypes sourceType(const QString &url);
        void openDB(const QString &name);

    private:
        QString name;
        QSqlDatabase m_db;


        /*basic actions*/


    public slots:
        void closeConnection();
        void test();

    signals:
        void trackInserted();
        void artworkInserted(const BAE::DB &albumMap);
        void DBactionFinished();
        void albumsCleaned(const int &amount);
        void artistsCleaned(const int &amount);

};

#endif // COLLECTION_H
