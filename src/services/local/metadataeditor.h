#pragma once

#include <QObject>
#include <QString>
#include <QUrl>

class TagInfo;
class MetadataEditor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QString artist READ artist WRITE setArtist NOTIFY artistChanged)
    Q_PROPERTY(QString album READ album WRITE setAlbum NOTIFY albumChanged)
    Q_PROPERTY(int track READ track WRITE setTrack NOTIFY trackChanged)
    Q_PROPERTY(QString genre READ genre WRITE setGenre NOTIFY genreChanged)
    Q_PROPERTY(QString comment READ comment WRITE setComment NOTIFY commentChanged)
    Q_PROPERTY(int year READ year WRITE setYear NOTIFY yearChanged)

public:
    explicit MetadataEditor(QObject *parent = nullptr);

    QUrl url() const;
    QString title() const;
    QString artist() const;
    QString album() const;
    QString genre() const;
    int track() const;

    QString comment() const;

    int year() const;

public Q_SLOTS:
    void setUrl(QUrl url);

    void setTitle(QString title);

    void setArtist(QString artist);

    void setAlbum(QString album);

    void setTrack(int track);

    void setGenre(QString genre);

    void setComment(QString comment);

    void setYear(int year);

private:
    TagInfo *m_tag;
    void getData();

    QUrl m_url;

    QString m_title;

    QString m_artist;

    QString m_album;

    int m_track;

    QString m_genre;

    QString m_comment;

    int m_year;

Q_SIGNALS:
    void urlChanged(QUrl url);
    void titleChanged(QString title);
    void artistChanged(QString artist);
    void albumChanged(QString album);
    void trackChanged(int track);
    void genreChanged(QString genre);
    void commentChanged(QString comment);
    void yearChanged(int year);
};
