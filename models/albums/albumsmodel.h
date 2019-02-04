#ifndef ALBUMSMODEL_H
#define ALBUMSMODEL_H

#include <QObject>
#include "models/baselist.h"

class CollectionDB;
class AlbumsModel : public BaseList
{
    Q_OBJECT
    Q_PROPERTY(QString query READ getQuery WRITE setQuery NOTIFY queryChanged())
    Q_PROPERTY(AlbumsModel::SORTBY sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)

public:

    enum SORTBY : uint_fast8_t
    {
        ADDDATE = FMH::MODEL_KEY::ADDDATE,
        RELEASEDATE = FMH::MODEL_KEY::RELEASEDATE,       
        ARTIST = FMH::MODEL_KEY::ARTIST,
        ALBUM = FMH::MODEL_KEY::ALBUM
    }; Q_ENUM(SORTBY)

    explicit AlbumsModel(QObject *parent = nullptr);

    FMH::MODEL_LIST items() const override;

    void setQuery(const QString &query);
    QString getQuery() const;

    void setSortBy(const AlbumsModel::SORTBY &sort);
    AlbumsModel::SORTBY getSortBy() const;

private:
    CollectionDB *db;
    FMH::MODEL_LIST list;
    void sortList();
    void setList();

    QString query;
    AlbumsModel::SORTBY sort = AlbumsModel::SORTBY::ADDDATE;

signals:
    void queryChanged();
    void sortByChanged();

public slots:
    QVariantMap get(const int &index) const override;
    void append(const QVariantMap &item);
    void append(const QVariantMap &item, const int &at);
};

#endif // ALBUMSMODEL_H
