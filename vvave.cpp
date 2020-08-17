#include "vvave.h"

#include "db/collectionDB.h"
#include "services/local/fileloader.h"
#include "utils/brain.h"

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
#include "kde/notify.h"
#endif

#ifdef STATIC_MAUIKIT
#include "fm.h"
#else
#include <MauiKit/fm.h>
#endif

/*
 * Sets upthe app default config paths
 * BrainDeamon to get collection information
 * YoutubeFetcher ?
 *
 * */
vvave::vvave(QObject *parent) : QObject(parent),
	db(CollectionDB::getInstance())
{
	for(const auto &path : {BAE::CachePath, BAE::YoutubeCachePath})
	{
		QDir dirPath(path);
		if (!dirPath.exists())
			dirPath.mkpath(".");
	}
}

//// PUBLIC SLOTS
QList<QUrl> vvave::folders()
{
	const auto sources = CollectionDB::getInstance()->getDBData("select * from sources");
	return QUrl::fromStringList(FMH::modelToList(sources, FMH::MODEL_KEY::URL));
}

void vvave::addSources(const QStringList &paths)
{
	QStringList urls = sources();
	QStringList newUrls;

	for(const auto &path : paths)
	{
		if(!urls.contains(path))
		{
			newUrls << path;
		}
	}

	if(newUrls.isEmpty())
		return;

	urls << newUrls;
	FMStatic::saveSettings("SETTINGS", QVariant::fromValue(urls), "SOURCES");

	scanDir(urls);
	emit sourcesChanged();
}

bool vvave::removeSource(const QString &source)
{
	auto urls = this->sources();
	if(!urls.contains(source))
		return false;

	urls.removeOne(source);
	FMStatic::saveSettings("SETTINGS", QVariant::fromValue(urls), "SOURCES");
	emit sourcesChanged();

	if(this->db->removeSource(source))
	{
		emit this->refreshTables();
		return true;
	}

	return false;
}

void vvave::scanDir(const QStringList &paths)
{
	auto fileLoader = new FileLoader();
	connect(fileLoader, &FileLoader::itemReady, [this](FMH::MODEL item)
	{
		db->addTrack(item);
	});

	connect(fileLoader, &FileLoader::itemsReady, [this](FMH::MODEL_LIST items)
	{
//        for(const auto &item : items)
//            db->addTrack(item);
		emit this->refreshTables();
	});

	connect(fileLoader, &FileLoader::finished, [=] (uint)
	{
		delete fileLoader;
	});

	fileLoader->requestPath(QUrl::fromStringList(paths), true);
}

QStringList vvave::sources()
{
	return FMStatic::loadSettings("SETTINGS", "SOURCES", QVariant::fromValue(BAE::defaultSources)).toStringList();
}

QVariantList vvave::sourcesModel()
{
	QVariantList res;
	for(const auto url : sources())
		res << FMH::getDirInfo(url);

	return res;
}

void vvave::openUrls(const QStringList &urls)
{
	if(urls.isEmpty()) return;

	QVariantList data;

	for(const auto &url : urls)
	{
		auto _url = QUrl::fromUserInput(url);
		if(db->check_existance(BAE::TABLEMAP[BAE::TABLE::TRACKS], FMH::MODEL_NAME[FMH::MODEL_KEY::URL], _url.toString()))
		{
			data << FMH::toMap(this->db->getDBData(QStringList() << _url.toString()).first());
		}else
		{
			TagInfo info(_url.toLocalFile());
			if(!info.isNull())
			{
				const auto album = BAE::fixString(info.getAlbum());
				const auto track= info.getTrack();
				const auto title = BAE::fixString(info.getTitle()); /* to fix*/
				const auto artist = BAE::fixString(info.getArtist());
				const auto genre = info.getGenre();
				const auto sourceUrl = QFileInfo(_url.toLocalFile()).dir().path();
				const auto duration = info.getDuration();
				const auto year = info.getYear();

				data << QVariantMap({
										{FMH::MODEL_NAME[FMH::MODEL_KEY::URL], _url.toString()},
										{FMH::MODEL_NAME[FMH::MODEL_KEY::TRACK], QString::number(track)},
										{FMH::MODEL_NAME[FMH::MODEL_KEY::TITLE], title},
										{FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST], artist},
										{FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM], album},
										{FMH::MODEL_NAME[FMH::MODEL_KEY::DURATION],QString::number(duration)},
										{FMH::MODEL_NAME[FMH::MODEL_KEY::GENRE], genre},
										{FMH::MODEL_NAME[FMH::MODEL_KEY::SOURCE], sourceUrl},
										{FMH::MODEL_NAME[FMH::MODEL_KEY::FAV],"0"},
										{FMH::MODEL_NAME[FMH::MODEL_KEY::RELEASEDATE], QString::number(year)}
									});
			}
		}
	}

	emit this->openFiles(data);
}



