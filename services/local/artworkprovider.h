#ifndef ARTWORKPROVIDER_H
#define ARTWORKPROVIDER_H

#include <QObject>
#include <QImage>
#include <QQuickImageProvider>
#include "pulpo/pulpo.h"
#include <QThread>

class ArtworkFetcher: public QObject
{
    Q_OBJECT

public:
    void fetch(FMH::MODEL data, PULPO::ONTOLOGY ontology);
signals:
    void artworkReady(const QUrl &url);
    void finished();
};


class AsyncImageResponse : public QQuickImageResponse
{
public:
    AsyncImageResponse(const QString &id, const QSize &requestedSize);
    QQuickTextureFactory *textureFactory() const override;

private:
    QString m_id;
    QSize m_requestedSize;
    QImage m_image;
    QThread m_worker;
};

class ArtworkProvider : public QQuickAsyncImageProvider
{
public:
    QQuickImageResponse *requestImageResponse(const QString &id, const QSize &requestedSize) override;


//    void updateArtwork(const int index, const QString &artwork);
//    void startFetchingArtwork(FMH::MODEL_LIST data, PULPO::ONTOLOGY ontology);


signals:

};

#endif // ARTWORKPROVIDER_H
