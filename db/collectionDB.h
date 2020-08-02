#ifndef COLLECTIONDB_H
#define COLLECTIONDB_H

#include <QList>
#include <QString>
#include <QStringList>

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QSqlDriver>

#include <QDebug>

#include <QFileInfo>
#include <QDir>

#include <QVariantMap>
#include <functional>

#include "../utils/bae.h"

enum sourceTypes
{
	LOCAL, ONLINE, DEVICE
};

class CollectionDB : public QObject
{
	Q_OBJECT

public:
	static CollectionDB *getInstance();
	bool insert(const QString &tableName, const QVariantMap &insertData);
	bool update(const QString &tableName, const FMH::MODEL &updateData, const QVariantMap &where);
	bool update(const QString &table, const QString &column, const QVariant &newValue, const QVariant &op, const QString &id);
	bool remove(const QString &table, const QString &column, const QVariantMap &where);

	bool execQuery(QSqlQuery &query) const;
	bool execQuery(const QString &queryTxt);

	/*basic public actions*/
	void prepareCollectionDB();
	bool check_existance(const QString &tableName, const QString &searchId, const QString &search);

	/* usefull actions */
	void insertArtwork(const FMH::MODEL &track);

	bool addTrack(const FMH::MODEL &track);
	bool updateTrack(const FMH::MODEL &track);
	Q_INVOKABLE bool rateTrack(const QString &path, const int &value);

	bool lyricsTrack(const FMH::MODEL &track, const QString &value);
	Q_INVOKABLE bool playedTrack(const QString &url, const int &increment = 1);

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
	FMH::MODEL_LIST getOnlineTracks(const FMH::MODEL_KEY &orderBy = FMH::MODEL_KEY::ADDDATE, const BAE::W &order = BAE::W::DESC);

    Q_INVOKABLE int getTrackStars(const QString &path);
    QStringList getArtistAlbums(const QString &artist);

	Q_INVOKABLE void removeMissingTracks();

	bool removeArtwork(const QString &table, const QVariantMap &item);
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
	static CollectionDB* instance;
    explicit CollectionDB( QObject *parent = nullptr);

	QString name;
	QSqlDatabase m_db;

signals:
	void trackInserted();
    void albumInserted();
    void artistInserted();
    void sourceInserted();

	void artworkInserted(const FMH::MODEL &albumMap);

	void albumsCleaned(const int &amount);
	void artistsCleaned(const int &amount);
};

#endif // COLLECTION_H
