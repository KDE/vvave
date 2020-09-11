#ifndef VVAVE_H
#define VVAVE_H

#include <QObject>
#include "utils/bae.h"
#include <functional>

class CollectionDB;
class vvave : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QVariantList sources READ sourcesModel NOTIFY sourcesChanged FINAL)
	Q_PROPERTY(QList<QUrl> folders READ folders NOTIFY sourcesChanged FINAL)

public:
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

public slots:
	void openUrls(const QStringList &urls);

	void addSources(const QStringList &paths);
	bool removeSource(const QString &source);

	void scanDir(const QStringList &paths = BAE::defaultSources);

	static QStringList sources();
	static QVariantList sourcesModel();

private:
	explicit vvave(QObject *parent = nullptr);
	CollectionDB *db;

signals:
	void refreshTables();
	void refreshTracks();
	void refreshAlbums();
	void refreshArtists();
	void openFiles(QVariantList tracks);
	void sourcesChanged();
};

#endif // VVAVE_H
