#pragma once

#include <QObject>
#include <QVariantMap>
#include <QString>

class TrackInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString albumWiki READ albumWiki NOTIFY albumWikiChanged)
    Q_PROPERTY(QString artistWiki READ artistWiki NOTIFY artistWikiChanged)
    Q_PROPERTY(QString trackWiki READ trackWiki NOTIFY trackWikiChanged)
    Q_PROPERTY(QString lyrics READ lyrics NOTIFY lyricsChanged)

    Q_PROPERTY(QVariantMap track READ track WRITE setTrack NOTIFY trackChanged)

public:
    explicit TrackInfo(QObject *parent = nullptr);

    QString albumWiki() const;

    QString artistWiki() const;

    QString trackWiki() const;

    QString lyrics() const;

    QVariantMap track() const;

public Q_SLOTS:
    void setTrack(QVariantMap track);

private:
    QString m_albumWiki;

    QString m_artistWiki;

    QString m_trackWiki;

    QString m_lyrics;

    QVariantMap m_track;

    void getInfo();

    void getAlbumInfo();
    void getArtistInfo();
    void getTrackInfo();

    QString m_artist;
    QString m_album;
    QString m_title;

Q_SIGNALS:
    void albumWikiChanged(QString albumWiki);
    void artistWikiChanged(QString artistWiki);
    void trackWikiChanged(QString trackWiki);
    void lyricsChanged(QString lyrics);
    void trackChanged(QVariantMap track);
};
