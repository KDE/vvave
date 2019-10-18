#ifndef ALBUMSMODEL_H
#define ALBUMSMODEL_H

#include <QObject>
#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif

class CollectionDB;
class AlbumsModel : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(AlbumsModel::QUERY query READ getQuery WRITE setQuery NOTIFY queryChanged())
    Q_PROPERTY(AlbumsModel::SORTBY sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)

public:
    enum SORTBY : uint_fast8_t
    {
        ADDDATE = FMH::MODEL_KEY::ADDDATE,
        RELEASEDATE = FMH::MODEL_KEY::RELEASEDATE,
        ARTIST = FMH::MODEL_KEY::ARTIST,
        ALBUM = FMH::MODEL_KEY::ALBUM
    };
    Q_ENUM(SORTBY)

    enum QUERY : uint_fast8_t
    {
        ARTISTS = FMH::MODEL_KEY::ARTIST,
        ALBUMS = FMH::MODEL_KEY::ALBUM
    };
    Q_ENUM(QUERY)

    explicit AlbumsModel(QObject *parent = nullptr);
<<<<<<< Updated upstream
    ~AlbumsModel();
=======
<<<<<<< Updated upstream
=======
    void componentComplete() override final;
>>>>>>> Stashed changes
>>>>>>> Stashed changes

    FMH::MODEL_LIST items() const override;

    void setQuery(const AlbumsModel::QUERY &query);
    AlbumsModel::QUERY getQuery() const;

    void setSortBy(const AlbumsModel::SORTBY &sort);
    AlbumsModel::SORTBY getSortBy() const;

private:
    bool stopThreads = false;
    CollectionDB *db;
    FMH::MODEL_LIST list;
    void sortList();
    void setList();

    AlbumsModel::QUERY query;
    AlbumsModel::SORTBY sort = AlbumsModel::SORTBY::ADDDATE;

    void updateArtwork(const int index, const QString &artwork);

signals:
    void queryChanged();
    void sortByChanged();

public slots:
    QVariantMap get(const int &index) const;
    void append(const QVariantMap &item);
    void append(const QVariantMap &item, const int &at);
    void refresh();

    void fetchInformation();
};

#endif // ALBUMSMODEL_H
