#ifndef TRACKSMODEL_H
#define TRACKSMODEL_H

#include <QObject>
#include "models/baselist.h"
#include "db/collectionDB.h"

class TracksModel : public BaseList
{
    Q_OBJECT
    Q_PROPERTY(QString query READ getQuery WRITE setQuery NOTIFY queryChanged())
    Q_PROPERTY(uint sortBy READ getSortBy WRITE setSortBy NOTIFY sortByChanged)

public:
    explicit TracksModel(QObject *parent = nullptr);

    FMH::MODEL_LIST items() const override;

    void setQuery(const QString &query);
    QString getQuery() const;

    void setSortBy(const uint &sort);
    uint getSortBy() const;

private:
    CollectionDB *db;
    FMH::MODEL_LIST list;
    void sortList();
    void setList();

    QString query;
    uint sort = FMH::MODEL_KEY::DATE;

    bool addDoc(const FMH::MODEL &doc);
    void refreshCollection();

signals:
    void queryChanged();
    void sortByChanged();
};

#endif // TRACKSMODEL_H
