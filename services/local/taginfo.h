#ifndef TAGINFO_H
#define TAGINFO_H

#include <QString>
#include <QByteArray>
#include <QObject>

#if defined Q_OS_ANDROID || defined Q_OS_WIN32
#include "taglib/tag.h"
#include "taglib/fileref.h"
#else
#include <taglib/tag.h>
#include <taglib/fileref.h>
#endif

class TagInfo : public QObject
{

    Q_OBJECT
public:
    TagInfo(QObject *parent = nullptr);
    ~TagInfo();
    bool feed(const QString &url);
    QString getAlbum() const;
    QString getTitle() const;
    QString getArtist() const;
    int getTrack() const;
    QString getGenre() const;
    QString fileName() const;
    QString getComment() const;
    QByteArray getCover() const;
    int getDuration() const;
    uint getYear() const;

    void setAlbum(const QString &album) ;
    void setTitle(const QString &title);
    void setTrack(const int &track);
    void setArtist(const QString &artist);
    void setGenre(const QString &genre);
    void setComment(const QString &comment);
    void setCover(const QByteArray &array);

private:
    TagLib::FileRef *file;
    QString path;
};

#endif // TAGINFO_H
