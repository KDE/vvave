#pragma once

#include <QObject>
#include <QStringList>

#include <MauiKit4/Core/fmh.h>

class vvave : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList sources READ sourcesModel NOTIFY sourcesChanged FINAL)
    Q_PROPERTY(QList<QUrl> folders READ folders NOTIFY sourcesChanged FINAL)
    Q_PROPERTY(bool fetchArtwork READ fetchArtwork WRITE setFetchArtwork NOTIFY fetchArtworkChanged)
    Q_PROPERTY(bool scanning READ scanning NOTIFY scanningChanged FINAL)

public:
    explicit vvave(QObject *parent = nullptr);
    static vvave *instance();

    bool fetchArtwork() const;

    QList<QUrl> folders();

    bool scanning() const;

public Q_SLOTS:
    void addSources(const QList<QUrl> &paths);
    bool removeSource(const QString &source);

    void scanDir(const QList<QUrl> &paths);
    void rescan();

    static QStringList sources();
    static QVariantList sourcesModel();

    void setFetchArtwork(bool fetchArtwork);
    static FMH::MODEL trackInfo(const QUrl &url);

    QString artworkUrl(const QString &artist, const QString &album);

    /**
     * @brief Get the tracks resulting from looking up the DB with a given query
     * @param query The querystring
     * @return A list of tracks
     */
    QVariantList getTracks(const QString &query);

private:
    bool m_fetchArtwork = false;
    bool m_scanning = false;

Q_SIGNALS:
    void sourceAdded(QUrl source);
    void sourceRemoved(QUrl source);

    void sourcesChanged();
    void fetchArtworkChanged(bool fetchArtwork);
    void scanningChanged(bool scanning);
};
