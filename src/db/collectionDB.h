#pragma once

#include <QList>
#include <QString>
#include <QStringList>

#include <QSqlDatabase>
#include <QSqlDriver>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>

#include <QDebug>

#include <QVariantMap>
#include <functional>

#include "../utils/bae.h"

enum sourceTypes { LOCAL, ONLINE, DEVICE };

class CollectionDB : public QObject
{
    Q_OBJECT

public:
    explicit CollectionDB(QObject *parent = nullptr);
    static CollectionDB *getInstance();

    bool insert(const QString &tableName, const QVariantMap &insertData);
    bool update(const QString &tableName, const FMH::MODEL &updateData, const QVariantMap &where);
    bool update(const QString &table, const QString &column, const QVariant &newValue, const QVariant &op, const QString &id);
    bool remove(const QString &table, const QString &column, const QVariantMap &where);

    bool execQuery(QSqlQuery &query) const;
    bool execQuery(const QString &queryTxt);

    /*basic public actions*/
    bool check_existance(const QString &tableName, const QString &searchId, const QString &search);

    /* usefull actions */
    bool addTrack(const FMH::MODEL &track);
    bool updateTrack(const FMH::MODEL &track);
    Q_INVOKABLE bool rateTrack(const QString &path, const int &value);

    bool lyricsTrack(const FMH::MODEL &track, const QString &value);
    Q_INVOKABLE bool playedTrack(const QString &url);

    bool albumTrack(const FMH::MODEL &track, const QString &value);
    bool trackTrack(const FMH::MODEL &track, const QString &value);

    FMH::MODEL_LIST getDBData(const QStringList &urls);
    FMH::MODEL_LIST getDBData(const QString &queryTxt, std::function<bool(FMH::MODEL &item)> modifier = nullptr);
    QVariantList getDBDataQML(const QString &queryTxt);
    static QStringList dataToList(const FMH::MODEL_LIST &list, const FMH::MODEL_KEY &key);

    FMH::MODEL_LIST getAlbumTracks(const QString &album, const QString &artist, const FMH::MODEL_KEY &orderBy = FMH::MODEL_KEY::TRACK, const BAE::W &order = BAE::W::ASC);
    FMH::MODEL_LIST getArtistTracks(const QString &artist, const FMH::MODEL_KEY &orderBy = FMH::MODEL_KEY::ALBUM, const BAE::W &order = BAE::W::ASC);
    FMH::MODEL_LIST getSearchedTracks(const FMH::MODEL_KEY &where, const QString &search);
    FMH::MODEL_LIST getMostPlayedTracks(const int &greaterThan = 1, const int &limit = 50, const FMH::MODEL_KEY &orderBy = FMH::MODEL_KEY::COUNT, const BAE::W &order = BAE::W::DESC);
    FMH::MODEL_LIST getRecentTracks(const int &limit = 50, const FMH::MODEL_KEY &orderBy = FMH::MODEL_KEY::ADDDATE, const BAE::W &order = BAE::W::DESC);

    int getTrackStars(const QString &path);
    QStringList getArtistAlbums(const QString &artist);

    void removeMissingTracks();

    bool removeArtist(const QString &artist);
    bool cleanArtists();
    bool removeAlbum(const QString &album, const QString &artist);
    bool cleanAlbums();

    bool removeSource(const QString &url);
    bool removeTrack(const QString &path);
    QSqlQuery getQuery(const QString &queryTxt) const;
    QSqlQuery getQuery() const;

    /*useful tools*/
    sourceTypes sourceType(const QString &url);
    void openDB(const QString &name);

private:
    void prepareCollectionDB();

    QString name;
    QSqlDatabase m_db;

Q_SIGNALS:
    void trackInserted(QVariantMap item);

    void albumInserted(QVariantMap item);
    void albumsInserted(QVariantList items);

    void artistInserted(QVariantMap item);
    void artistsInserted(QVariantList items);

    void sourceInserted(QVariantMap item);
    void sourcesInserted(QVariantList items);

    void albumsCleaned(const int &amount);
    void artistsCleaned(const int &amount);
};
