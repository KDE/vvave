#ifndef VVAVE_H
#define VVAVE_H

#include <QObject>
#include "utils/bae.h"
#include <functional>

class Notify;
class CollectionDB;
class vvave : public QObject
{
    Q_OBJECT
private:
    Notify *notify;
    CollectionDB *db;
    void checkCollection(const QStringList &paths = BAE::defaultSources, std::function<void (uint)> cb = nullptr);
    void runBrain();

public:
    explicit vvave(QObject *parent = nullptr);
    ~vvave();

signals:
    void refreshTables(uint size);
    void refreshTracks();
    void refreshAlbums();
    void refreshArtists();

public slots:
    ///DB Interfaces
    /// useful functions for non modeled views and actions with not direct access to a tracksmodel or its own model
    QVariantList sourceFolders();
    static QString moodColor(const int &index);
    void scanDir(const QStringList &paths = BAE::defaultSources);

    QStringList getSourceFolders();



};

#endif // VVAVE_H
