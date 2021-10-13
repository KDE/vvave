#ifndef ALBUMSMODEL_H
#define ALBUMSMODEL_H

#include <QObject>
#include <QThread>

#include <MauiKit/Core/mauilist.h>

class AlbumsModel : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(AlbumsModel::QUERY query READ getQuery WRITE setQuery NOTIFY queryChanged())

public:
    enum QUERY : uint_fast8_t { ARTISTS = FMH::MODEL_KEY::ARTIST, ALBUMS = FMH::MODEL_KEY::ALBUM };
    Q_ENUM(QUERY)

    explicit AlbumsModel(QObject *parent = nullptr);

    void componentComplete() override;

    const FMH::MODEL_LIST &items() const override;

    void setQuery(const AlbumsModel::QUERY &query);
    AlbumsModel::QUERY getQuery() const;

private:
    FMH::MODEL_LIST list;

    void setList();

    AlbumsModel::QUERY query;

    int m_newAlbums;

public slots:
    void refresh();
    int indexOfName(const QString &query);

signals:
    void queryChanged();
};

#endif // ALBUMSMODEL_H
