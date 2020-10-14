#ifndef VVAVE_H
#define VVAVE_H

#include <QObject>
#include <QQmlEngine>

#include "utils/bae.h"
#include <functional>

class CollectionDB;
class vvave : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QVariantList sources READ sourcesModel NOTIFY sourcesChanged FINAL)
	Q_PROPERTY(QList<QUrl> folders READ folders NOTIFY sourcesChanged FINAL)
    Q_PROPERTY(bool autoScan READ autoScan WRITE setAutoScan NOTIFY autoScanChanged)

public:
    static vvave *qmlAttachedProperties(QObject *object);

	static vvave * instance()
	{
		static vvave vvave;
		return &vvave;
	}

	vvave(const vvave &) = delete;
	vvave &operator=(const vvave &) = delete;
	vvave(vvave &&) = delete;
	vvave &operator=(vvave &&) = delete;

	QList<QUrl> folders();

    bool autoScan() const;

public slots:
	void openUrls(const QStringList &urls);

	void addSources(const QStringList &paths);
	bool removeSource(const QString &source);

	void scanDir(const QStringList &paths = BAE::defaultSources);

	static QStringList sources();
	static QVariantList sourcesModel();

    void setAutoScan(bool autoScan);

private:
	explicit vvave(QObject *parent = nullptr);
	CollectionDB *db;

	uint m_newTracks = 0;
	uint m_newAlbums = 0;
	uint m_newArtist = 0;
	uint m_newSources = 0;

    bool m_autoScan = false;

signals:
	void sourceAdded(QUrl source);
	void sourceRemoved(QUrl source);
	void tracksAdded(uint size);
	void albumsAdded(uint size);
	void artistsAdded(uint size);

	void openFiles(QVariantList tracks);
    void sourcesChanged();
    void autoScanChanged(bool autoScan);
};

QML_DECLARE_TYPEINFO(vvave, QML_HAS_ATTACHED_PROPERTIES)

#endif // VVAVE_H
