#ifndef VVAVE_H
#define VVAVE_H

#include <QObject>
#include "utils/bae.h"
#include <functional>

class CollectionDB;
class vvave : public QObject
{
    Q_OBJECT
private:
    CollectionDB *db;
    void checkCollection(const QStringList &paths = BAE::defaultSources, std::function<void (uint)> cb = nullptr);

public:
    explicit vvave(QObject *parent = nullptr);

signals:
    void refreshTables(uint size);
    void refreshTracks();
    void refreshAlbums();
    void refreshArtists();
    void openFiles(QVariantList tracks);

public slots:
    ///DB Interfaces
    /// useful functions for non modeled views and actions with not direct access to a tracksmodel or its own model
    static QVariantList sourceFolders();
    bool removeSource(const QString &source);
    static QString moodColor(const int &index);
    static QStringList moodColors();
    void scanDir(const QStringList &paths = BAE::defaultSources);

    static QStringList getSourceFolders();
    void openUrls(const QStringList &urls);
};

#endif // VVAVE_H
