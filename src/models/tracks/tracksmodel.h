#pragma once

#include <QObject>

#include <MauiKit4/Core/mauilist.h>

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
    FMH::MODEL_LIST list;
    QString query;
    int m_limit = 99999;
    int m_newTracks;

    void setList();

Q_SIGNALS:
    void queryChanged();
    void limitChanged(int limit);

public Q_SLOTS:
    bool append(const QVariantMap &item);
    bool appendUrl(const QUrl &url);

    bool insertUrl(const QString &url, const int &index);
    bool insertUrls(const QStringList &urls, const int &index);

    bool appendUrls(const QStringList &urls);
    bool appendAt(const QVariantMap &item, const int &at);
    bool appendQuery(const QString &query);

    void copy(const TracksModel *list);

    void clear();
    bool fav(const int &index, const bool &value);
    bool countUp(const int &index);
    bool remove(const int &index);
    bool erase(const int &index);
    bool removeMissing(const int &index);

    void refresh();
    bool update(const QVariantMap &data, const int &index);
    
    void updateMetadata(const QVariantMap &data, const int &index);

    bool move(const int &index, const int &to);

    QStringList urls() const;
};

