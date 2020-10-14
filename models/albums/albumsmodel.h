#ifndef ALBUMSMODEL_H
#define ALBUMSMODEL_H

#include <QObject>
#include <QThread>

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif

#include "pulpo/pulpo.h"

class ArtworkFetcher: public QObject
{
    Q_OBJECT

public:
		void fetch(FMH::MODEL_LIST data, PULPO::ONTOLOGY ontology);
	signals:
		void artworkReady(const FMH::MODEL &item, const int &index);
        void finished();
};

class CollectionDB;
class AlbumsModel : public MauiList
{
	Q_OBJECT
	Q_PROPERTY(AlbumsModel::QUERY query READ getQuery WRITE setQuery NOTIFY queryChanged())
    Q_PROPERTY(bool fetchArtwork READ fetchArtwork WRITE setFetchArtwork NOTIFY fetchArtworkChanged)

public:
	enum QUERY : uint_fast8_t
	{
		ARTISTS = FMH::MODEL_KEY::ARTIST,
		ALBUMS = FMH::MODEL_KEY::ALBUM
	};
	Q_ENUM(QUERY)

	explicit AlbumsModel(QObject *parent = nullptr);
	~AlbumsModel();

    void componentComplete() override;

	FMH::MODEL_LIST items() const override;

	void setQuery(const AlbumsModel::QUERY &query);
	AlbumsModel::QUERY getQuery() const;

    bool fetchArtwork() const;

private:
	bool stopThreads = false;
	CollectionDB *db;
	FMH::MODEL_LIST list;
	QThread m_worker;

	void setList();

	AlbumsModel::QUERY query;
	void updateArtwork(const int index, const QString &artwork);

    bool m_fetchArtwork = false;

public slots:
	QVariantMap get(const int &index) const;
	void append(const QVariantMap &item);
	void append(const QVariantMap &item, const int &at);
	void refresh();

    void fetchInformation();
    void setFetchArtwork(bool fetchArtwork);

signals:
    void queryChanged();
    void startFetchingArtwork(FMH::MODEL_LIST data, PULPO::ONTOLOGY ontology);
    void fetchArtworkChanged(bool fetchArtwork);
};

#endif // ALBUMSMODEL_H
