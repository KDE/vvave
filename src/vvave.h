#ifndef VVAVE_H
#define VVAVE_H

#include <QObject>
#include <QStringList>

#include <MauiKit/Core/fmh.h>

class vvave : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList sources READ sourcesModel NOTIFY sourcesChanged FINAL)
    Q_PROPERTY(QList<QUrl> folders READ folders NOTIFY sourcesChanged FINAL)
    Q_PROPERTY(bool fetchArtwork READ fetchArtwork WRITE setFetchArtwork NOTIFY fetchArtworkChanged)
    Q_PROPERTY(bool scanning READ scanning NOTIFY scanningChanged FINAL)

public:
    static vvave *instance()
    {
        static vvave vvave;
        return &vvave;
    }

    vvave(const vvave &) = delete;
    vvave &operator=(const vvave &) = delete;
    vvave(vvave &&) = delete;
    vvave &operator=(vvave &&) = delete;

    bool fetchArtwork() const;

    QList<QUrl> folders();

    bool scanning() const;

public slots:
    void addSources(const QList<QUrl> &paths);
    bool removeSource(const QString &source);

    void scanDir(const QList<QUrl> &paths);
    void rescan();

    static QStringList sources();
    static QVariantList sourcesModel();

    void setFetchArtwork(bool fetchArtwork);
    static FMH::MODEL trackInfo(const QUrl &url);

    QString artworkUrl(const QString &artist, const QString &album);

private:
    explicit vvave(QObject *parent = nullptr);

    bool m_fetchArtwork = false;
    bool m_scanning = false;

signals:
    void sourceAdded(QUrl source);
    void sourceRemoved(QUrl source);

    void sourcesChanged();
    void fetchArtworkChanged(bool fetchArtwork);
    void scanningChanged(bool scanning);
};

#endif // VVAVE_H
