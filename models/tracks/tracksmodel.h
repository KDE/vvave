#ifndef TRACKSMODEL_H
#define TRACKSMODEL_H

#include <QObject>
#include "models/baselist.h"

class CollectionDB;
class TracksModel : public BaseList
{
    Q_OBJECT
    Q_PROPERTY(QString query READ getQuery WRITE setQuery NOTIFY queryChanged())
    Q_PROPERTY(TracksModel::SORTBY sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)

public:

    enum SORTBY : uint_fast8_t
    {
        ADDDATE = FMH::MODEL_KEY::ADDDATE,
        RELEASEDATE = FMH::MODEL_KEY::RELEASEDATE,
        FORMAT = FMH::MODEL_KEY::FORMAT,
        ARTIST = FMH::MODEL_KEY::ARTIST,
        TITLE = FMH::MODEL_KEY::TITLE,
        ALBUM = FMH::MODEL_KEY::ALBUM,
        RATE = FMH::MODEL_KEY::RATE,
        FAV = FMH::MODEL_KEY::FAV
    }; Q_ENUM(SORTBY)

    explicit TracksModel(QObject *parent = nullptr);

    FMH::MODEL_LIST items() const override;

    void setQuery(const QString &query);
    QString getQuery() const;

    void setSortBy(const TracksModel::SORTBY &sort);
    TracksModel::SORTBY getSortBy() const;

private:
    CollectionDB *db;
    FMH::MODEL_LIST list;
    void sortList();
    void setList();

    QString query;
    TracksModel::SORTBY sort = TracksModel::SORTBY::ADDDATE;

signals:
    void queryChanged();
    void sortByChanged();

public slots:
    QVariantMap get(const int &index) const override;
    void append(const QVariantMap &item);
    void append(const QVariantMap &item, const int &at);

    bool color(const int &index, const QString &color);
    bool fav(const int &index, const bool &value);
};

#endif // TRACKSMODEL_H
