#ifndef SETTINGS_H
#define SETTINGS_H

#include <QWidget>
#include <QString>
#include <QStringList>
#include <QDebug>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileDialog>
#include <QFileSystemWatcher>
#include <QLabel>
#include <QMovie>
#include <QFileSystemWatcher>
#include <QTimer>
#include "fileloader.h"

#include "../utils/bae.h"
class CollectionDB;
class youtubedl;
class Socket;
class Brain;

using namespace BAE;

class BabeSettings : public QObject
{
    Q_OBJECT

public:
    explicit BabeSettings(QObject *parent = nullptr);
    ~BabeSettings();
    void checkCollectionBrainz(const bool &state);
    void refreshCollection();
    void fetchYoutubeTrack(const QString &message);

public slots:
    void startBrainz(const bool &on, const uint &speed = BAE::SEG::THREE);
    void populateDB(const QStringList &paths);

private:
    FileLoader fileLoader;
    CollectionDB *connection;
    Brain *brainDeamon;
    youtubedl *ytFetch;
    Socket *babeSocket;

signals:
    void collectionPathChanged(QStringList newPaths);
    void refreshATable(BAE::TABLE table);
    void refreshTables(int size);
    void albumArtReady(const DB &album);
    void brainFinished();

};

#endif // SETTINGS_H
