#ifndef BABE_H
#define BABE_H

#include <QObject>
#include <QVariantList>
#include "utils/bae.h"
#include "db/collectionDB.h"
//#include "services/local/linking.h"

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
class Notify;
#elif defined (Q_OS_ANDROID)
//class NotificationClient;
#endif

class CollectionDB;
class Pulpo;
class BabeSettings;
class ConThread;

using namespace BAE;

class Babe : public QObject
{
    Q_OBJECT

public:
    explicit Babe(QObject *parent = nullptr);
    ~Babe();

    BabeSettings *settings;
//    Linking link;

    //    Q_INVOKABLE void runPy();

    /* DATABASE INTERFACES */
    Q_INVOKABLE QVariantList get(const QString &queryTxt);
    Q_INVOKABLE QVariantList getList(const QStringList &urls);

//    Q_INVOKABLE void set(const QString &table, const QVariantList &wheres);
//    Q_INVOKABLE void trackPlaylist(const QStringList &urls, const QString &playlist);

    /***MOVE ALL THIS TO A INFO MODEL ***/
    Q_INVOKABLE void trackLyrics(const QString &url);
    Q_INVOKABLE QString artistArt(const QString &artist);
    Q_INVOKABLE QString albumArt(const QString &album, const QString &artist);
    Q_INVOKABLE QString artistWiki(const QString &artist);
    Q_INVOKABLE QString albumWiki(const QString &album, const QString &artist);
    Q_INVOKABLE void loadCover(const QString &url);
/**************************************/

    Q_INVOKABLE QVariantList getFolders();
    Q_INVOKABLE QStringList getSourceFolders();

    /* SETTINGS */
    Q_INVOKABLE void scanDir(const QString &url);
    Q_INVOKABLE void brainz(const bool &on);
    Q_INVOKABLE bool brainzState();
    Q_INVOKABLE void refreshCollection();
    Q_INVOKABLE void getYoutubeTrack(const QString &message);

    /* STATIC METHODS */
    Q_INVOKABLE static void savePlaylist(const QStringList &list);
    Q_INVOKABLE static QStringList lastPlaylist();

    Q_INVOKABLE static void savePlaylistPos(const int &pos);
    Q_INVOKABLE static int lastPlaylistPos();

    Q_INVOKABLE static void showFolder(const QStringList &urls);

    /*COLORS*/
    Q_INVOKABLE static QString babeColor();

    /*UTILS*/
    Q_INVOKABLE void openUrls(const QStringList &urls);

    Q_INVOKABLE static QString moodColor(const int &pos);
    Q_INVOKABLE static QStringList defaultSources();

    /*KDE*/
    Q_INVOKABLE void notify(const QString &title, const QString &body);
    Q_INVOKABLE void notifySong(const QString &url);

public slots:

private:
    Pulpo *pulpo;
//    ConThread *thread;
    CollectionDB *db;

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
    Notify *nof;
#elif defined (Q_OS_ANDROID)
//    NotificationClient *nof;
#endif
    void fetchCoverArt(FMH::MODEL &song);
    static QVariantList transformData(const FMH::MODEL_LIST &dbList);

    void fetchTrackLyrics(FMH::MODEL &song);
//    void linkDecoder(QString json);

signals:
    void refreshTables(int size);
    void refreshTracks();
    void refreshAlbums();
    void refreshArtists();
    void trackLyricsReady(QString lyrics, QString url);
    void skipTrack();
    void babeIt();
    void message(QString msg);
    void openFiles(QVariantList tracks);
    void coverReady(const QString &path);
};


#endif // BABE_H
