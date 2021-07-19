#ifndef TRACKSMODEL_H
#define TRACKSMODEL_H

#include <QObject>

#include <MauiKit/Core/fmh.h>
#include <MauiKit/Core/mauilist.h>

class CollectionDB;
class TracksModel : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(QString query READ getQuery WRITE setQuery NOTIFY queryChanged)
    Q_PROPERTY(int limit READ limit WRITE setLimit NOTIFY limitChanged)

public:
    explicit TracksModel(QObject *parent = nullptr);

    void componentComplete() override final;
    const FMH::MODEL_LIST &items() const override final;

    void setQuery(const QString &query);
    QString getQuery() const;

    int limit() const;
    void setLimit(int limit);

private:
    CollectionDB *db;

    FMH::MODEL_LIST list;
    QString query;
    int m_limit = 99999;

    void setList();

signals:
    void queryChanged();
    void limitChanged(int limit);
    void missingFiles(QStringList urls);

public slots:
    void append(const QVariantMap &item);
    void appendAt(const QVariantMap &item, const int &at);
    void appendQuery(const QString &query);
    void copy(const TracksModel *list);

    void clear();
    bool fav(const int &index, const bool &value);
    bool countUp(const int &index);
    bool remove(const int &index);

    void removeMissingFiles(const QStringList &urls);

    void refresh();
    bool update(const QVariantMap &data, const int &index);
    
    void updateMetadata(const QVariantMap &data, const int &index);
};

#endif // TRACKSMODEL_H
