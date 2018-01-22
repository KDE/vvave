#ifndef BABE_H
#define BABE_H

#include <QObject>
#include <QVariantList>
#include "utils/bae.h"


#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
class Notify;
#endif

class CollectionDB;
class Pulpo;
class settings;

using namespace BAE;

class Babe : public QObject
{
    Q_OBJECT
public:
    explicit Babe(QObject *parent = nullptr);
    ~Babe();

    enum class HINT : uint
    {
        BIG_ALBUM = 200,
        MEDIUM_ALBUM = 120,
        SMALL_ALBUM = 80
    };
    Q_ENUM(HINT)

    /* DATABASE INTERFACES */

    Q_INVOKABLE QVariantList get(const QString &queryTxt);
    Q_INVOKABLE QVariantList getList(const QStringList &urls);
    Q_INVOKABLE void trackLyrics(const QString &url);
    Q_INVOKABLE bool trackBabe(const QString &path);
    Q_INVOKABLE QString artistArt(const QString &artist);
    Q_INVOKABLE QString albumArt(const QString &album, const QString &artist);
    Q_INVOKABLE QString artistWiki(const QString &artist);
    Q_INVOKABLE QString albumWiki(const QString &album, const QString &artist);

    Q_INVOKABLE bool babeTrack(const QString &path, const bool &value);
    Q_INVOKABLE bool rateTrack(const QString &path, const int &value);
    Q_INVOKABLE int trackRate(const QString &path);
    Q_INVOKABLE bool moodTrack(const QString &path, const QString &color);



    Q_INVOKABLE  void notify(const QString &title, const QString &body);
    Q_INVOKABLE  void notifySong(const QString &url);
    /* SETTINGS */

    Q_INVOKABLE void scanDir(const QString &url);


    /* STATIC METHODS */

    Q_INVOKABLE static void savePlaylist(const QStringList &list);
    Q_INVOKABLE static QStringList lastPlaylist();

    Q_INVOKABLE static void savePlaylistPos(const int &pos);
    Q_INVOKABLE static int lastPlaylistPos();

    Q_INVOKABLE static QString baseColor();
    Q_INVOKABLE static QString darkColor();
    Q_INVOKABLE static QString backgroundColor();
    Q_INVOKABLE static QString foregroundColor();
    Q_INVOKABLE static QString textColor();
    Q_INVOKABLE static QString hightlightColor();
    Q_INVOKABLE static QString midColor();
    Q_INVOKABLE static QString midLightColor();
    Q_INVOKABLE static QString shadowColor();
    Q_INVOKABLE static QString altColor();
    Q_INVOKABLE static QString babeColor();

    Q_INVOKABLE static bool isMobile();
    Q_INVOKABLE static int screenGeometry(QString &side);
    Q_INVOKABLE static int cursorPos(QString &axis);

    Q_INVOKABLE static QString moodColor(const int &pos);

    Q_INVOKABLE static QString homeDir();

    Q_INVOKABLE static QVariantList getDirs(const QString &pathUrl);
    Q_INVOKABLE static QVariantMap getParentDir(const QString &path);
    static void registerTypes();
    Q_INVOKABLE static uint sizeHint(const uint &hint);
    Q_INVOKABLE static QString icon(const QString &icon, const int &size);
    /*USEFUL*/

    Q_INVOKABLE QString loadCover(const QString &url);
    Q_INVOKABLE QVariantList searchFor(const QStringList &queries);

private:
    CollectionDB *con;
    settings *set;
#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    Notify *nof;
#endif

    QString fetchCoverArt(DB &song);
    static QVariantList transformData(const DB_LIST &dbList);

    void fetchTrackLyrics(DB &song);

signals:
    void refreshTables(QVariantMap tables);
    void trackLyricsReady(QString lyrics, QString url);
    void skipTrack();
    void babeIt();
public slots:
};

#endif // BABE_H
