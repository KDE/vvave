#ifndef BABE_H
#define BABE_H

#include <QObject>
#include <QVariantList>
#include "utils/bae.h"
#include "db/collectionDB.h"

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
class Notify;
#elif defined (Q_OS_ANDROID)
class NotificationClient;
#endif

class CollectionDB;
class Pulpo;
class BabeSettings;
class ConThread;
using namespace BAE;

class Babe : public CollectionDB
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

    //    Q_INVOKABLE void runPy();

    /* DATABASE INTERFACES */

    Q_INVOKABLE QVariantList get(const QString &queryTxt);
    Q_INVOKABLE QVariantList getList(const QStringList &urls);

    Q_INVOKABLE void set(const QString &table, const QVariantList &wheres);

    Q_INVOKABLE void trackPlaylist(const QStringList &urls, const QString &playlist);
    Q_INVOKABLE void trackLyrics(const QString &url);
    Q_INVOKABLE bool trackBabe(const QString &path);
    Q_INVOKABLE QString artistArt(const QString &artist);
    Q_INVOKABLE QString albumArt(const QString &album, const QString &artist);
    Q_INVOKABLE QString artistWiki(const QString &artist);
    Q_INVOKABLE QString albumWiki(const QString &album, const QString &artist);

    Q_INVOKABLE bool babeTrack(const QString &path, const bool &value);


    /* SETTINGS */

    Q_INVOKABLE void scanDir(const QString &url);
    Q_INVOKABLE void brainz(const bool &on);
    Q_INVOKABLE bool brainzState();
    Q_INVOKABLE void refreshCollection();

    /* STATIC METHODS */

    Q_INVOKABLE static void saveSetting(const QString &key, const QVariant &value, const QString &group);
    Q_INVOKABLE static QVariant loadSetting(const QString &key, const QString &group, const QVariant &defaultValue);

    Q_INVOKABLE static void savePlaylist(const QStringList &list);
    Q_INVOKABLE static QStringList lastPlaylist();

    Q_INVOKABLE static void savePlaylistPos(const int &pos);
    Q_INVOKABLE static int lastPlaylistPos();

    Q_INVOKABLE static bool fileExists(const QString &url);
    Q_INVOKABLE static void showFolder(const QString &url);

    /*COLORS*/
    Q_INVOKABLE static QString baseColor();
    Q_INVOKABLE static QString darkColor();
    Q_INVOKABLE static QString backgroundColor();
    Q_INVOKABLE static QString foregroundColor();
    Q_INVOKABLE static QString textColor();
    Q_INVOKABLE static QString highlightColor();
    Q_INVOKABLE static QString highlightTextColor();
    Q_INVOKABLE static QString midColor();
    Q_INVOKABLE static QString midLightColor();
    Q_INVOKABLE static QString shadowColor();
    Q_INVOKABLE static QString altColor();
    Q_INVOKABLE static QString babeColor();
    Q_INVOKABLE static QString babeAltColor();


    /*UTILS*/
    Q_INVOKABLE static bool isMobile();
    Q_INVOKABLE static int screenGeometry(QString side);
    Q_INVOKABLE static int cursorPos(QString axis);

    Q_INVOKABLE static QString moodColor(const int &pos);

    Q_INVOKABLE static QString homeDir();
    Q_INVOKABLE static QString musicDir();
    Q_INVOKABLE static QString sdDir();

    Q_INVOKABLE static QVariantList getDirs(const QString &pathUrl);
    Q_INVOKABLE static QVariantMap getParentDir(const QString &path);

    Q_INVOKABLE static QStringList defaultSources();

    static void registerTypes();

    /*USEFUL*/
    Q_INVOKABLE QString loadCover(const QString &url);
    Q_INVOKABLE QVariantList searchFor(const QStringList &queries);

    /*KDE*/
    Q_INVOKABLE static QVariantList getDevices();
    Q_INVOKABLE static bool sendToDevice(const QString &name, const QString &id, const QString &url);

    Q_INVOKABLE void notify(const QString &title, const QString &body);
    Q_INVOKABLE void notifySong(const QString &url);

    /*ANDROID*/
    Q_INVOKABLE static void sendText(const QString &text);
    Q_INVOKABLE static void sendTrack(const QString &url);
    Q_INVOKABLE static void openFile(const QString &url);
    Q_INVOKABLE static void androidStatusBarColor(const QString &color);


public slots:
    void debug(const QString &msg);

private:
    BabeSettings *settings;
    ConThread *thread;

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    Notify *nof;
#elif defined (Q_OS_ANDROID)
    NotificationClient *nof;
#endif

    QString fetchCoverArt(DB &song);
    static QVariantList transformData(const DB_LIST &dbList);

    void fetchTrackLyrics(DB &song);

signals:
    void refreshTables(int size);
    void refreshTracks();
    void refreshAlbums();
    void refreshArtists();
    void trackLyricsReady(QString lyrics, QString url);
    void skipTrack();
    void babeIt();
    void message(QString msg);
};


#endif // BABE_H
