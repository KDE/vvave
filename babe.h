#ifndef BABE_H
#define BABE_H

#include <QObject>
#include <QVariantList>
#include "utils/bae.h"

class CollectionDB;
class Pulpo;
class settings;


using namespace BAE;

class Babe : public QObject
{
    Q_OBJECT
public:
    explicit Babe(QObject *parent = nullptr);


    /* DATABASE INTERFACES */

    Q_INVOKABLE QVariantList get(const QString &queryTxt);
    Q_INVOKABLE void trackLyrics(const QString &url);
    Q_INVOKABLE bool trackBabe(const QString &path);
    Q_INVOKABLE QString artistArt(const QString &artist);
    Q_INVOKABLE QString albumArt(const QString &album, const QString &artist);
    Q_INVOKABLE QString artistWiki(const QString &artist);
    Q_INVOKABLE QString albumWiki(const QString &album, const QString &artist);

    Q_INVOKABLE bool babeTrack(const QString &path, const bool &value);


    /* SETTINGS */

    Q_INVOKABLE void scanDir(const QString &url);


    /* STATIC METHODS */

    Q_INVOKABLE static void savePlaylist(const QStringList &list);
    Q_INVOKABLE static QStringList lastPlaylist();

    Q_INVOKABLE static void savePlaylistPos(const int &pos);
    Q_INVOKABLE static int lastPlaylistPos();

    Q_INVOKABLE static QString backgroundColor();
    Q_INVOKABLE static QString foregroundColor();
    Q_INVOKABLE static QString hightlightColor();
    Q_INVOKABLE static QString midColor();
    Q_INVOKABLE static QString altColor();
    Q_INVOKABLE static QString babeColor();

    /*USEFUL*/

    Q_INVOKABLE QString loadCover(const QString &url);


private:
    CollectionDB *con;
    settings *set;

    QString fetchCoverArt(DB &song);


    void fetchTrackLyrics(DB &song);

signals:
    void refreshTables(QVariantMap tables);
    void trackLyricsReady(QString lyrics, QString url);

public slots:
};

#endif // BABE_H
