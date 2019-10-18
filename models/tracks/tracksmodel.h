#ifndef TRACKSMODEL_H
#define TRACKSMODEL_H

#include <QObject>

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif

class CollectionDB;
class TracksModel : public MauiList
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
        FAV = FMH::MODEL_KEY::FAV,
        TRACK = FMH::MODEL_KEY::TRACK,
        COUNT = FMH::MODEL_KEY::COUNT,
        NONE

    }; Q_ENUM(SORTBY)

    explicit TracksModel(QObject *parent = nullptr);

    void componentComplete() override final;

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
    QVariantMap get(const int &index) const;
    QVariantList getAll();
    void append(const QVariantMap &item);
    void append(const QVariantMap &item, const int &at);
    void appendQuery(const QString &query);
//    void appendUrl(const QString &url);
    void searchQueries(const QStringList &queries);
    void clear();
    bool color(const int &index, const QString &color);
    bool fav(const int &index, const bool &value);
    bool rate(const int &index, const int &value);
    bool countUp(const int &index);
    bool remove(const int &index);
    void refresh();
    bool update(const QVariantMap &data, const int &index);
};

#endif // TRACKSMODEL_H
