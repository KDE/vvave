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

#include "../utils/bae.h"
class FileLoader;
class CollectionDB;

using namespace BAE;

class settings : public QObject
{
    Q_OBJECT

public:
    explicit settings(QObject *parent = nullptr);
    ~settings();
    void checkCollection();
    void collectionWatcher();

private slots:
    void handleDirectoryChanged(const QString &dir);
    void on_remove_clicked();

public slots:
    void populateDB(const QString &path);

private:
    FileLoader *fileLoader;
    CollectionDB *connection;
    const QString notifyDir = BAE::NotifyDir;

    QString pathToRemove;

    QStringList dirs;
    QFileSystemWatcher *watcher;

    void refreshCollectionPaths();
    void addToWatcher(QStringList paths);

signals:
    void collectionPathChanged(QString newPath);
    void refreshTables(const QMap<BAE::TABLE,bool> &reset);
    void albumArtReady(const DB &album);

};

#endif // SETTINGS_H
