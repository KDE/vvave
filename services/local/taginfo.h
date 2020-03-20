#ifndef TAGINFO_H
#define TAGINFO_H

#include <QString>
#include <QByteArray>
#include <QObject>

#if defined Q_OS_ANDROID || defined Q_OS_IOS
#include "tag.h"
#include "fileref.h"
#elif defined Q_OS_WIN32 || defined Q_OS_MACOS || defined Q_OS_LINUX
#include <taglib/tag.h>
#include <taglib/fileref.h>
#endif

class TagInfo : public QObject
{

    Q_OBJECT
public:
    TagInfo(const QString &url, QObject *parent = nullptr);
    ~TagInfo();
    bool isNull();
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
    wchar_t * m_path;
};

#endif // TAGINFO_H
