/*
   Babe - tiny music player
   Copyright (C) 2017  Camilo Higuita
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

   */

#include "collectionDB.h"
#include <QUuid>
#include <QString>
#include <QStringList>
#include <QCoreApplication>

using namespace BAE;

CollectionDB::CollectionDB(QObject *parent) : QObject(parent)
{
	QObject::connect(qApp, &QCoreApplication::aboutToQuit, [this]()
	{
		this->m_db.close();
		this->instance->deleteLater();
		this->instance = nullptr;
	});

	this->name = QUuid::createUuid().toString();

	if(!BAE::fileExists(BAE::CollectionDBPath + BAE::DBName))
	{
		QDir collectionDBPath_dir(BAE::CollectionDBPath);
		if (!collectionDBPath_dir.exists())
			collectionDBPath_dir.mkpath(".");

		this->openDB(this->name);
		qDebug()<<"Collection doesn't exists, trying to create it" << BAE::CollectionDBPath + BAE::DBName;
		this->prepareCollectionDB();

	}else this->openDB(this->name);

}

CollectionDB *CollectionDB::instance = nullptr;

CollectionDB *CollectionDB::getInstance()
{
	if(!instance)
	{
		instance = new CollectionDB();
		qDebug() << "getInstance(): First DBActions instance\n";
		return instance;
	} else
	{
		qDebug()<< "getInstance(): previous DBActions instance\n";
		return instance;
	}
}

void CollectionDB::prepareCollectionDB()
{
	QSqlQuery query(this->m_db);

	QFile file(":/db/script.sql");
	qDebug()<< file.exists();

	if (!file.exists())
	{
		QString log = QStringLiteral("Fatal error on build database. The file '");
		log.append(file.fileName() + QStringLiteral("' for database and tables creation query cannot be not found!"));
		qDebug()<<log;
		return;
	}

	if (!file.open(QIODevice::ReadOnly))
	{
		qDebug()<<QStringLiteral("Fatal error on try to create database! The file with sql queries for database creation cannot be opened!");
		return;
	}

	bool hasText;
	QString line;
	QByteArray readLine;
	QString cleanedLine;
	QStringList strings;

	while (!file.atEnd())
	{
		hasText     = false;
		line        = "";
		readLine    = "";
		cleanedLine = "";
		strings.clear();
		while (!hasText)
		{
			readLine    = file.readLine();
			cleanedLine = readLine.trimmed();
			strings     = cleanedLine.split("--");
			cleanedLine = strings.at(0);
			if (!cleanedLine.startsWith("--") && !cleanedLine.startsWith("DROP") && !cleanedLine.isEmpty())
				line += cleanedLine;
			if (cleanedLine.endsWith(";"))
				break;
			if (cleanedLine.startsWith("COMMIT"))
				hasText = true;
		}
		if (!line.isEmpty())
		{
			if (!query.exec(line))
			{
				qDebug()<<"exec failed"<<query.lastQuery()<<query.lastError();
			}

		} else qDebug()<<"exec wrong"<<query.lastError();
	}
	file.close();
}

bool CollectionDB::check_existance(const QString &tableName, const QString &searchId,const QString &search)
{
	auto queryStr = QString("SELECT %1 FROM %2 WHERE %3 = \"%4\"").arg(searchId, tableName, searchId, search);
	auto query = this->getQuery(queryStr);

	if (!query.exec())
	{
		qDebug()<<query.lastError().text();
		return false;
	}

	if (query.first())
		return true;

	return false;
}

bool CollectionDB::insert(const QString &tableName, const QVariantMap &insertData)
{
	if (tableName.isEmpty())
	{
		qDebug() << QStringLiteral("Fatal error on insert! The table name is empty!");
		return false;

	} else if (insertData.isEmpty())
	{
		qDebug() << QStringLiteral("Fatal error on insert! The insertData is empty!");
		return false;
	}

	QStringList strValues;
	QStringList fields = insertData.keys();
	QVariantList values = insertData.values();
	int totalFields = fields.size();
	for (int i = 0; i < totalFields; ++i)
		strValues.append("?");

	QString sqlQueryString = "INSERT INTO " + tableName + " (" + QString(fields.join(",")) + ") VALUES(" + QString(strValues.join(",")) + ")";
	QSqlQuery query(this->m_db);
	query.prepare(sqlQueryString);

	int k = 0;
	foreach (const QVariant &value, values)
		query.bindValue(k++, value);

	return query.exec();
}

bool CollectionDB::update(const QString &tableName, const FMH::MODEL &updateData, const QVariantMap &where)
{
	if (tableName.isEmpty())
	{
		qDebug()<<QStringLiteral("Fatal error on insert! The table name is empty!");
		return false;
	} else if (updateData.isEmpty())
	{
		qDebug()<<QStringLiteral("Fatal error on insert! The insertData is empty!");
		return false;
	}

	QStringList set;
	for (const auto &key : updateData.keys())
		set.append(QString("%1 = \"%2\"").arg(FMH::MODEL_NAME[key],updateData[key]));

	QStringList condition;
	for (const auto &key : where.keys())
		condition.append(QString("%1 = \"%2\"").arg(key, where[key].toString()));

	const QString sqlQueryString = "UPDATE " + tableName + " SET " + QString(set.join(",")) + " WHERE " + QString(condition.join(" AND ")) ;
	auto query = this->getQuery(sqlQueryString);
	qDebug()<<sqlQueryString;
	return this->execQuery(query);
}

bool CollectionDB::update(const QString &table, const QString &column, const QVariant &newValue, const QVariant &op, const QString &id)
{
	const auto queryStr = QString("UPDATE %1 SET %2 = \"%3\" WHERE %4 = \"%5\"").arg(table, column, newValue.toString().replace("\"","\"\""), op.toString(), id);
	auto query = this->getQuery(queryStr);
	return query.exec();
}

bool CollectionDB::remove(const QString &table, const QString &column, const QVariantMap &where)
{
	return false;}

bool CollectionDB::execQuery(QSqlQuery &query) const
{
	if(query.exec()) return true;
	qDebug()<<"ERROR ON EXEC QUERY";
	qDebug()<<query.lastError()<<query.lastQuery();
	return false;
}

bool CollectionDB::execQuery(const QString &queryTxt)
{
	auto query = this->getQuery(queryTxt);
	return this->execQuery(query);
}

void CollectionDB::openDB(const QString &name)
{
	if(!QSqlDatabase::contains(name))
	{
		this->m_db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), name);
		this->m_db.setDatabaseName(BAE::CollectionDBPath + BAE::DBName);
	}

	if (!this->m_db.isOpen())
	{
		if(!this->m_db.open())
			qDebug()<<"ERROR OPENING DB"<<this->m_db.lastError().text()<<m_db.connectionName();
		else
		{
			qDebug()<<"Setting pragma WAL";
			this->execQuery("PRAGMA journal_mode=WAL");
		}
	}
}

bool CollectionDB::addTrack(const FMH::MODEL &track)
{
	qDebug()<< "ÄDDING TRACKS" << track;
	auto url = track[FMH::MODEL_KEY::URL];
	auto title = track[FMH::MODEL_KEY::TITLE];
	auto artist = track[FMH::MODEL_KEY::ARTIST];
	auto album = track[FMH::MODEL_KEY::ALBUM];
	auto genre = track[FMH::MODEL_KEY::GENRE];
	auto year = track[FMH::MODEL_KEY::RELEASEDATE];
	auto sourceUrl = track[FMH::MODEL_KEY::SOURCE];
	auto duration = track[FMH::MODEL_KEY::DURATION];
	auto fav = track[FMH::MODEL_KEY::FAV];
	auto trackNumber = track[FMH::MODEL_KEY::TRACK];

	auto artwork = track[FMH::MODEL_KEY::ARTWORK].isEmpty() ? "" : track[FMH::MODEL_KEY::ARTWORK];

	auto artistTrack = track;
	artistTrack[FMH::MODEL_KEY::ARTWORK] = "";
	BAE::artworkCache(artistTrack, FMH::MODEL_KEY::ARTIST);
	auto artistArtwork = artistTrack[FMH::MODEL_KEY::ARTWORK];

	/* first needs to insert the source, album and artist*/
	QVariantMap sourceMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::URL], sourceUrl},
						   {FMH::MODEL_NAME[FMH::MODEL_KEY::SOURCETYPE], sourceType(url)}};

	insert(TABLEMAP[BAE::TABLE::SOURCES], sourceMap);

	QVariantMap artistMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST], artist},
						   {FMH::MODEL_NAME[FMH::MODEL_KEY::ARTWORK], artistArtwork},
						   {FMH::MODEL_NAME[FMH::MODEL_KEY::WIKI], ""}};

	insert(TABLEMAP[TABLE::ARTISTS],artistMap);

	QVariantMap albumMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM], album},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST], artist},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::ARTWORK], artwork},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::WIKI],""}};

	insert(TABLEMAP[TABLE::ALBUMS],albumMap);

	QVariantMap trackMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::SOURCE], sourceUrl},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::TRACK], trackNumber},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::TITLE], title},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST], artist},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM], album},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::DURATION], duration},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::COUNT], 0},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::FAV], fav},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::RATE], 0},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::RELEASEDATE], year},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::ADDDATE], QDateTime::currentDateTime()},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::LYRICS],""},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::GENRE], genre},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::COLOR], ""},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::WIKI], ""},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::COMMENT], ""}};

	return this->insert(BAE::TABLEMAP[BAE::TABLE::TRACKS], trackMap);
}

bool CollectionDB::updateTrack(const FMH::MODEL &track)
{
	if(this->check_existance(TABLEMAP[TABLE::TRACKS], FMH::MODEL_NAME[FMH::MODEL_KEY::URL], track[FMH::MODEL_KEY::URL]))
	{
		QVariantMap artistMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST], track[FMH::MODEL_KEY::ARTIST]},
							   {FMH::MODEL_NAME[FMH::MODEL_KEY::ARTWORK], ""},
							   {FMH::MODEL_NAME[FMH::MODEL_KEY::WIKI],""}};

		insert(TABLEMAP[TABLE::ARTISTS],artistMap);

		QVariantMap albumMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM], track[FMH::MODEL_KEY::ALBUM]},
							  {FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST], track[FMH::MODEL_KEY::ARTIST]},
							  {FMH::MODEL_NAME[FMH::MODEL_KEY::ARTWORK], ""},
							  {FMH::MODEL_NAME[FMH::MODEL_KEY::WIKI],""}};
		insert(TABLEMAP[TABLE::ALBUMS],albumMap);

		QVariantMap condition {{FMH::MODEL_NAME[FMH::MODEL_KEY::URL], track[FMH::MODEL_KEY::URL]}};

		if(this->update(TABLEMAP[TABLE::TRACKS], track, condition))
			if(cleanAlbums()) cleanArtists();

		return true;
	}

	return false;
}

bool CollectionDB::rateTrack(const QString &path, const int &value)
{
	if(update(TABLEMAP[TABLE::TRACKS],
			  FMH::MODEL_NAME[FMH::MODEL_KEY::RATE],
			  value,
			  FMH::MODEL_NAME[FMH::MODEL_KEY::URL],
			  path)) return true;
	return false;
}


bool CollectionDB::colorTagTrack(const QString &path, const QString &value)
{
	if(update(TABLEMAP[TABLE::TRACKS],
			  FMH::MODEL_NAME[FMH::MODEL_KEY::COLOR],
			  value,
			  FMH::MODEL_NAME[FMH::MODEL_KEY::URL],
			  path)) return true;
	return false;
}

bool CollectionDB::lyricsTrack(const FMH::MODEL &track, const QString &value)
{

	if(update(TABLEMAP[TABLE::TRACKS],
			  FMH::MODEL_NAME[FMH::MODEL_KEY::LYRICS],
			  value,
			  FMH::MODEL_NAME[FMH::MODEL_KEY::URL],
			  track[FMH::MODEL_KEY::URL])) return true;
	return false;
}

bool CollectionDB::tagsTrack(const FMH::MODEL &track, const QString &value, const QString &context)
{
	auto url = track[FMH::MODEL_KEY::URL];

	qDebug()<<"INSERTIN TRACK TAG"<<value<<context<<url;

	QVariantMap tagMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::TAG],value},{FMH::MODEL_NAME[FMH::MODEL_KEY::CONTEXT],context}};

	QVariantMap trackTagMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::TAG], value},
							 {FMH::MODEL_NAME[FMH::MODEL_KEY::CONTEXT], context},
							 {FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url}};

	insert(TABLEMAP[TABLE::TAGS],tagMap);
	insert(TABLEMAP[TABLE::TRACKS_TAGS],trackTagMap);
	return true;
}

bool CollectionDB::albumTrack(const FMH::MODEL &track, const QString &value)
{
	auto album = track[FMH::MODEL_KEY::ALBUM];
	auto artist = track[FMH::MODEL_KEY::ARTIST];
	auto url = track[FMH::MODEL_KEY::URL];

	auto queryTxt = QString("SELECT * %1 WHERE %2 = %3 AND %4 = %5").arg(TABLEMAP[TABLE::ALBUMS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM],
			album,
			FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],
			artist);

	auto result = this->getDBData(queryTxt);
	if(result.isEmpty())  return false;

	auto oldAlbum = result.first();
	QVariantMap albumMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM],value},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST], oldAlbum[FMH::MODEL_KEY::ARTIST]},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::ARTWORK], oldAlbum[FMH::MODEL_KEY::ARTWORK]},
						  {FMH::MODEL_NAME[FMH::MODEL_KEY::WIKI], oldAlbum[FMH::MODEL_KEY::WIKI]}};

	if (!insert(TABLEMAP[TABLE::ALBUMS],albumMap)) return false;

	// update albums SET album = "newalbumname" WHERE album = "albumname" NAD artist = "aretist name";
	queryTxt = QString("UPDATE %1 SET %2 = %3 AND %4 = %5 WHERE %2 = %6 AND %4 = %5").arg(TABLEMAP[TABLE::TRACKS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM],value,
			FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST], oldAlbum[FMH::MODEL_KEY::ARTIST], oldAlbum[FMH::MODEL_KEY::ALBUM]);
	auto query = this->getQuery(queryTxt);

	if(!execQuery(query)) return false;

	queryTxt = QString("DELETE FROM %1 WHERE %2 = %3 AND %4 = %5").arg(TABLEMAP[TABLE::ALBUMS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM], oldAlbum[FMH::MODEL_KEY::ALBUM], FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST], artist);
	query.prepare(queryTxt);

	if(!execQuery(query)) return false;

	return true;
}


bool CollectionDB::playedTrack(const QString &url, const int &increment)
{
	auto queryTxt = QString("UPDATE %1 SET %2 = %2 + %3 WHERE %4 = \"%5\"").arg(TABLEMAP[TABLE::TRACKS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::COUNT],
			QString::number(increment),
			FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url);

	auto query = this->getQuery(queryTxt);

	if(query.exec())
		return true;

	return false;
}

bool CollectionDB::wikiTrack(const FMH::MODEL &track, const QString &value)
{
	auto url = track[FMH::MODEL_KEY::URL];

	if(update(TABLEMAP[TABLE::TRACKS],
			  FMH::MODEL_NAME[FMH::MODEL_KEY::WIKI],
			  value,
			  FMH::MODEL_NAME[FMH::MODEL_KEY::URL],
			  url)) return true;

	return false;
}

bool CollectionDB::wikiArtist(const FMH::MODEL &track, const QString &value)
{
	auto artist = track[FMH::MODEL_KEY::ARTIST];

	if(update(TABLEMAP[TABLE::ARTISTS],
			  FMH::MODEL_NAME[FMH::MODEL_KEY::WIKI],
			  value,
			  FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],
			  artist)) return true;
	return false;
}

bool CollectionDB::tagsArtist(const FMH::MODEL &track, const QString &value, const QString &context)
{
	auto artist = track[FMH::MODEL_KEY::ARTIST];

	QVariantMap tagMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::TAG], value},
						{FMH::MODEL_NAME[FMH::MODEL_KEY::CONTEXT], context}};

	QVariantMap artistTagMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::TAG], value},
							  {FMH::MODEL_NAME[FMH::MODEL_KEY::CONTEXT], context},
							  {FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST], artist}};

	insert(TABLEMAP[TABLE::TAGS],tagMap);
	insert(TABLEMAP[TABLE::ARTISTS_TAGS],artistTagMap);

	return true;

}

bool CollectionDB::wikiAlbum(const FMH::MODEL &track,  QString value)
{
	auto artist = track[FMH::MODEL_KEY::ARTIST];
	auto album = track[FMH::MODEL_KEY::ALBUM];

	auto queryStr = QString("UPDATE %1 SET %2 = \"%3\" WHERE %4 = \"%5\" AND %6 = \"%7\"").arg(
				TABLEMAP[TABLE::ALBUMS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::WIKI], value.replace("\"","\"\""),
			FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM],
			album,FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST], artist);


	qDebug()<<queryStr;
	auto query = this->getQuery(queryStr);
	return query.exec();
}

bool CollectionDB::tagsAlbum(const FMH::MODEL &track, const QString &value, const QString &context)
{
	auto artist = track[FMH::MODEL_KEY::ARTIST];
	auto album = track[FMH::MODEL_KEY::ALBUM];

	QVariantMap tagMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::TAG],value},{FMH::MODEL_NAME[FMH::MODEL_KEY::CONTEXT],context}};

	QVariantMap albumsTagMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::TAG],value},
							  {FMH::MODEL_NAME[FMH::MODEL_KEY::CONTEXT],context},
							  {FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],artist},
							  {FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM],album}};

	insert(TABLEMAP[TABLE::TAGS],tagMap);
	insert(TABLEMAP[TABLE::ALBUMS_TAGS],albumsTagMap);
	return true;
}

bool CollectionDB::addPlaylist(const QString &title)
{
	if(!title.isEmpty())
	{
		QVariantMap playlist {{FMH::MODEL_NAME[FMH::MODEL_KEY::PLAYLIST], title},
							  {FMH::MODEL_NAME[FMH::MODEL_KEY::ADDDATE], QDateTime::currentDateTime()}};

		if(insert(TABLEMAP[TABLE::PLAYLISTS],playlist))
			return true;
	}

	return false;
}

bool CollectionDB::trackPlaylist(const QString &url, const QString &playlist)
{
	QVariantMap map {{FMH::MODEL_NAME[FMH::MODEL_KEY::PLAYLIST],playlist},
					 {FMH::MODEL_NAME[FMH::MODEL_KEY::URL],url},
					 {FMH::MODEL_NAME[FMH::MODEL_KEY::ADDDATE],QDate::currentDate()}};

	if(insert(TABLEMAP[TABLE::TRACKS_PLAYLISTS],map))
		return true;

	return false;
}


bool CollectionDB::addFolder(const QString &url)
{
	QVariantMap map {{FMH::MODEL_NAME[FMH::MODEL_KEY::URL],url},
					 {FMH::MODEL_NAME[FMH::MODEL_KEY::ADDDATE],QDateTime::currentDateTime()}};

	if(insert(TABLEMAP[TABLE::FOLDERS],map))
		return true;

	return false;
}


FMH::MODEL_LIST CollectionDB::getDBData(const QStringList &urls)
{
	FMH::MODEL_LIST mapList;

	for(const auto &url : urls)
	{
		const auto queryTxt = QString("SELECT * FROM %1 t INNER JOIN albums a on a.album = t.album and a.artist = t.artist WHERE t.%2 = \"%3\"").arg(TABLEMAP[TABLE::TRACKS],
				FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url);

		mapList << this->getDBData(queryTxt);
	}

	return mapList;
}

FMH::MODEL_LIST CollectionDB::getDBData(const QString &queryTxt, std::function<bool(FMH::MODEL &item)> modifier)
{
	FMH::MODEL_LIST mapList;

	auto query = this->getQuery(queryTxt);

	if(query.exec())
	{
		while(query.next())
		{
			FMH::MODEL data;
			for(const auto &key : FMH::MODEL_NAME.keys())
				if(query.record().indexOf(FMH::MODEL_NAME[key]) > -1)
					data.insert(key, query.value(FMH::MODEL_NAME[key]).toString());

			if(modifier)
			{
				if(!modifier(data))
					continue;
			}

			mapList << data;
		}

	}else qDebug()<< query.lastError()<< query.lastQuery();

	return mapList;
}

QStringList CollectionDB::dataToList(const FMH::MODEL_LIST &list, const FMH::MODEL_KEY &key)
{
	QStringList res;

	if(list.isEmpty())
		return res;

	for(const auto &item : list)
		res << item[key];

	return res;
}


FMH::MODEL_LIST CollectionDB::getAlbumTracks(const QString &album, const QString &artist, const FMH::MODEL_KEY &orderBy, const BAE::W &order)
{
	const auto queryTxt = QString("SELECT * FROM %1 WHERE %2 = \"%3\" AND %4 = \"%5\" ORDER by %6 %7").arg(TABLEMAP[TABLE::TRACKS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],
			artist,
			FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM],
			album,
			FMH::MODEL_NAME[orderBy], SLANG[order]);

	return this->getDBData(queryTxt);
}

FMH::MODEL_LIST CollectionDB::getArtistTracks(const QString &artist, const FMH::MODEL_KEY &orderBy, const BAE::W &order)
{
	const auto queryTxt = QString("SELECT * FROM %1 WHERE %2 = \"%3\" ORDER by %4 %5, %6 %5").arg(TABLEMAP[TABLE::TRACKS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],
			artist,
			FMH::MODEL_NAME[orderBy],
			SLANG[order],
			FMH::MODEL_NAME[FMH::MODEL_KEY::TRACK]);

	return this->getDBData(queryTxt);
}

QStringList CollectionDB::getArtistAlbums(const QString &artist)
{
	QStringList albums;

	const auto queryTxt = QString("SELECT %4 FROM %1 WHERE %2 = \"%3\" ORDER BY %4 ASC").arg(TABLEMAP[TABLE::ALBUMS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],
			artist,
			FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM]);
	auto query = this->getDBData(queryTxt);

	for(const auto &track : query)
		albums << track[FMH::MODEL_KEY::ALBUM];

	return albums;
}

FMH::MODEL_LIST CollectionDB::getBabedTracks(const FMH::MODEL_KEY &orderBy, const BAE::W &order)
{
	const auto queryTxt = QString("SELECT * FROM %1 WHERE %2 = 1 ORDER by %3 %4").arg(TABLEMAP[TABLE::TRACKS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::FAV],
			FMH::MODEL_NAME[orderBy], SLANG[order]);
	return this->getDBData(queryTxt);
}

FMH::MODEL_LIST CollectionDB::getSearchedTracks(const FMH::MODEL_KEY &where, const QString &search)
{
	QString queryTxt;

	if(where == FMH::MODEL_KEY::COUNT || where == FMH::MODEL_KEY::RATE || where == FMH::MODEL_KEY::FAV)
		queryTxt = QString("SELECT t.*, al.artwork FROM %1 t inner join albums al on al.album = t.album and t.artist = al.artist WHERE %2 = \"%3\"").arg(TABLEMAP[TABLE::TRACKS],
				FMH::MODEL_NAME[where],
				search);
	else if(where == FMH::MODEL_KEY::WIKI)

		queryTxt = QString("SELECT DISTINCT t.*, al.artwork FROM %1 t INNER JOIN %2 al ON t.%3 = al.%3 INNER JOIN %4 ar ON t.%5 = ar.%5 WHERE al.%6 LIKE \"%%7%\" OR ar.%6 LIKE \"%%7%\" COLLATE NOCASE").arg(TABLEMAP[TABLE::TRACKS],
				TABLEMAP[TABLE::ALBUMS],
				FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM],
				TABLEMAP[TABLE::ARTISTS],
				FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],
				FMH::MODEL_NAME[where],
				search);


	else if(where == FMH::MODEL_KEY::PLAYLIST)

		queryTxt = QString("SELECT t.* FROM %1 t INNER JOIN %2 tp ON t.%3 = tp.%3 WHERE tp.%4 = \"%5\"").arg(TABLEMAP[TABLE::TRACKS],
				TABLEMAP[TABLE::TRACKS_PLAYLISTS],
				FMH::MODEL_NAME[FMH::MODEL_KEY::URL],
				FMH::MODEL_NAME[where],
				search);


	else if(where == FMH::MODEL_KEY::TAG)

		queryTxt = QString("SELECT t.* FROM %1 t INNER JOIN %2 tt ON t.%3 = tt.%3 WHERE tt.%4 = \"%5\" COLLATE NOCASE "
						   "UNION "
						   "SELECT t.* FROM %1 t INNER JOIN %6 at ON t.%7 = at.%7 AND t.%8 = at.%8 WHERE at.%4 = \"%5\" COLLATE NOCASE "
						   "UNION "
						   "SELECT t.* FROM %1 t INNER JOIN %9 art ON t.%8 = art.%8 WHERE art.%4 LIKE \"%%5%\" COLLATE NOCASE "
						   "UNION "
						   "SELECT DISTINCT t.* FROM %1 t INNER JOIN %9 at ON t.%8 = at.%4 WHERE at.%8 LIKE \"%%5%\" COLLATE NOCASE").arg(
					TABLEMAP[TABLE::TRACKS],
				TABLEMAP[TABLE::TRACKS_TAGS],
				FMH::MODEL_NAME[FMH::MODEL_KEY::URL],
				FMH::MODEL_NAME[where],
				search,
				TABLEMAP[TABLE::ALBUMS_TAGS],
				FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM],
				FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],
				TABLEMAP[TABLE::ARTISTS_TAGS]);

	//    else if(where == FMH::MODEL_KEY::SQL)
	//        queryTxt = search;
	else
		queryTxt = QString("SELECT t.*, al.artwork FROM %1 t inner join albums al on al.album = t.album and t.artist = al.artist WHERE t.%2 LIKE \"%%3%\" ORDER BY strftime(\"%s\", t.addDate) desc LIMIT 1000").arg(TABLEMAP[TABLE::TRACKS],
				FMH::MODEL_NAME[where],
				search);

	return this->getDBData(queryTxt);

}

FMH::MODEL_LIST CollectionDB::getPlaylistTracks(const QString &playlist, const FMH::MODEL_KEY &orderBy, const BAE::W &order)
{
	const auto queryTxt= QString("SELECT t.* FROM %1 t INNER JOIN %2 tp ON t.%3 = tp.%3 WHERE tp.%4 = '%5' ORDER BY tp.%6 %7").arg(TABLEMAP[TABLE::TRACKS],
			TABLEMAP[TABLE::TRACKS_PLAYLISTS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::URL],
			FMH::MODEL_NAME[FMH::MODEL_KEY::PLAYLIST],
			playlist, FMH::MODEL_NAME[orderBy], SLANG[order]);

	return this->getDBData(queryTxt);
}

FMH::MODEL_LIST CollectionDB::getFavTracks(const int &stars, const int &limit, const FMH::MODEL_KEY &orderBy, const BAE::W &order)
{
	const auto queryTxt= QString("SELECT * FROM %1 WHERE %2 >= %3 ORDER BY %4 %5 LIMIT %6" ).arg(TABLEMAP[TABLE::TRACKS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::RATE],
			QString::number(stars),
			FMH::MODEL_NAME[orderBy],SLANG[order],QString::number(limit));

	return this->getDBData(queryTxt);
}

FMH::MODEL_LIST CollectionDB::getRecentTracks(const int &limit, const FMH::MODEL_KEY &orderBy, const BAE::W &order)
{
	const auto queryTxt= QString("SELECT * FROM %1 ORDER BY strftime(\"%s\",%2) %3 LIMIT %4" ).arg(TABLEMAP[TABLE::TRACKS],
			FMH::MODEL_NAME[orderBy],SLANG[order],QString::number(limit));

	return this->getDBData(queryTxt);
}

FMH::MODEL_LIST CollectionDB::getOnlineTracks(const FMH::MODEL_KEY &orderBy, const BAE::W &order)
{
	const auto queryTxt= QString("SELECT * FROM %1 WHERE %2 LIKE \"%3%\" ORDER BY %4 %5" ).arg(TABLEMAP[TABLE::TRACKS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::URL],
			YoutubeCachePath,
			FMH::MODEL_NAME[orderBy],
			SLANG[order]);

	return this->getDBData(queryTxt);
}

QStringList CollectionDB::getSourcesFolders()
{
	const auto data = this->getDBData("select * from folders order by strftime(\"%s\", addDate) desc");
	return this->dataToList(data, FMH::MODEL_KEY::URL);
}

FMH::MODEL_LIST CollectionDB::getMostPlayedTracks(const int &greaterThan, const int &limit, const FMH::MODEL_KEY &orderBy, const BAE::W &order)
{
	auto queryTxt = QString("SELECT * FROM %1 WHERE %2 > %3 ORDER BY %4 %5 LIMIT %6" ).arg(TABLEMAP[TABLE::TRACKS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::COUNT],
			QString::number(greaterThan),
			FMH::MODEL_NAME[orderBy],
			SLANG[order],
			QString::number(limit));

	return this->getDBData(queryTxt);
}


QString CollectionDB::trackColorTag(const QString &path)
{
	QString color;
	auto query = this->getDBData(QString("SELECT %1 FROM %2 WHERE %3 = \"%4\"").arg(FMH::MODEL_NAME[FMH::MODEL_KEY::COLOR],
								 TABLEMAP[TABLE::TRACKS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::URL],path));

	for(auto track : query)
		color = track[FMH::MODEL_KEY::COLOR];

	return color;
}

QStringList CollectionDB::getTrackTags(const QString &path)
{
	Q_UNUSED(path);
	return {};
}

int CollectionDB::getTrackStars(const QString &path)
{
	int stars = 0;
	auto query = this->getDBData(QString("SELECT %1 FROM %2 WHERE %3 = \"%4\"").arg(FMH::MODEL_NAME[FMH::MODEL_KEY::RATE],
								 TABLEMAP[TABLE::TRACKS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::URL],path));

	for(auto track : query)
		stars = track[FMH::MODEL_KEY::RATE].toInt();

	return stars;
}

//QStringList CollectionDB::getArtistTags(const QString &artist)
//{
//    QStringList tags;

//    auto queryStr = QString("SELECT at.%1 FROM %2 at "
//                            "INNER JOIN %3 ta ON ta.%1 = at.%1 "
//                            "WHERE ta.%4 = '%5' "
//                            "AND at.%6 = \"%7\"").arg(FMH::MODEL_NAME[KEY::TAG],
//            TABLEMAP[TABLE::ARTISTS_TAGS],
//            TABLEMAP[TABLE::TAGS],
//            FMH::MODEL_NAME[KEY::CONTEXT],
//            PULPO::CONTEXT_MAP[PULPO::CONTEXT::ARTIST_SIMILAR],
//            FMH::MODEL_NAME[KEY::ARTIST],artist);
//    auto query = this->getDBData(queryStr);
//    for(auto track : query)
//        tags << track[KEY::TAG];

//    return tags;
//}


//QStringList CollectionDB::getAlbumTags(const QString &album, const QString &artist)
//{
//    QStringList tags;

//    auto queryStr = QString("SELECT at.%1 FROM %2 at "
//                            "INNER JOIN %3 ta ON ta.%1 = at.%1 "
//                            "WHERE ta.%4 = '%5' AND at.%6 = \"%7\" AND at.%8 = \"%9\"").arg(FMH::MODEL_NAME[KEY::TAG],
//            TABLEMAP[TABLE::ALBUMS_TAGS],
//            TABLEMAP[TABLE::TAGS],
//            FMH::MODEL_NAME[KEY::CONTEXT],
//            PULPO::CONTEXT_MAP[PULPO::CONTEXT::TAG],
//            FMH::MODEL_NAME[KEY::ALBUM],album,
//            FMH::MODEL_NAME[KEY::ARTIST],artist);

//    auto query = this->getDBData(queryStr);

//    for(auto track : query)
//        tags << track[KEY::TAG];

//    return tags;
//}

QStringList CollectionDB::getPlaylistsList()
{
	QStringList playlists;
	auto queryTxt = QString("SELECT %1, %2 FROM %3 ORDER BY %2 DESC").arg(FMH::MODEL_NAME[FMH::MODEL_KEY::PLAYLIST],
			FMH::MODEL_NAME[FMH::MODEL_KEY::ADDDATE],
			TABLEMAP[TABLE::PLAYLISTS]);

	for(auto data : this->getDBData(queryTxt))
		playlists << data[FMH::MODEL_KEY::PLAYLIST];

	return playlists;
}

FMH::MODEL_LIST CollectionDB::getPlaylists()
{
	auto queryTxt = QString("SELECT %1, %2 FROM %3 ORDER BY %2 DESC").arg(FMH::MODEL_NAME[FMH::MODEL_KEY::PLAYLIST],
			FMH::MODEL_NAME[FMH::MODEL_KEY::ADDDATE],
			TABLEMAP[TABLE::PLAYLISTS]);

	return this->getDBData(queryTxt, [](FMH::MODEL &item)
	{
		item[FMH::MODEL_KEY::TYPE] = "public";
		return true;
	});
}

bool CollectionDB::removeTrack(const QString &path)
{
	auto queryTxt = QString("DELETE FROM %1 WHERE %2 =  \"%3\"").arg(TABLEMAP[TABLE::TRACKS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::URL],path);
	auto query = this->getQuery(queryTxt);
	if(query.exec())
	{
		if(cleanAlbums()) cleanArtists();
		return true;
	}
	return false;
}

QSqlQuery CollectionDB::getQuery(const QString &queryTxt)
{
	return QSqlQuery(queryTxt, this->m_db);
}

bool CollectionDB::removeSource(const QString &url)
{
	const auto path = url.endsWith("/") ? url.chopped(1) : url;
	auto queryTxt = QString("DELETE FROM %1 WHERE %2 LIKE \"%3%\"").arg(TABLEMAP[TABLE::TRACKS_PLAYLISTS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::URL], path);
	qDebug() << queryTxt;
	auto query = this->getQuery(queryTxt);
	if(query.exec())
	{
		queryTxt = QString("DELETE FROM %1 WHERE %2 LIKE \"%3%\"").arg(TABLEMAP[TABLE::TRACKS],
				FMH::MODEL_NAME[FMH::MODEL_KEY::SOURCE], path);

		query.prepare(queryTxt);
		if(query.exec())
		{
			queryTxt = QString("DELETE FROM %1 WHERE %2 LIKE \"%3%\"").arg(TABLEMAP[TABLE::SOURCES],
					FMH::MODEL_NAME[FMH::MODEL_KEY::URL],path);
			query.prepare(queryTxt);
			if(query.exec())
			{
				this->removeFolder(path);
				if(cleanAlbums())
					cleanArtists();
				return true;
			}
		}
	}

	return false;
}

sourceTypes CollectionDB::sourceType(const QString &url)
{
	/*for now*/
	Q_UNUSED(url);
	return sourceTypes::LOCAL;
}


/*******************OLD STUFF********************/

void CollectionDB::insertArtwork(const FMH::MODEL &track)
{
	auto artist = track[FMH::MODEL_KEY::ARTIST];
	auto album =track[FMH::MODEL_KEY::ALBUM];
	auto path = track[FMH::MODEL_KEY::ARTWORK];

	switch(BAE::albumType(track))
	{
	case TABLE::ALBUMS :
	{
		auto queryStr = QString("UPDATE %1 SET %2 = \"%3\" WHERE %4 = \"%5\" AND %6 = \"%7\"").arg(TABLEMAP[TABLE::ALBUMS],
				FMH::MODEL_NAME[FMH::MODEL_KEY::ARTWORK],
				path.isEmpty() ? SLANG[W::NONE] : path,
												  FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM],
												  album,
												  FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],
												  artist);

		auto query = this->getQuery(queryStr);
		if(!query.exec())qDebug()<<"COULDNT Artwork[cover] inerted into DB"<<artist<<album;
		break;

	}
	case TABLE::ARTISTS:
	{
		auto queryStr = QString("UPDATE %1 SET %2 = \"%3\" WHERE %4 = \"%5\"").arg(TABLEMAP[TABLE::ARTISTS],
				FMH::MODEL_NAME[FMH::MODEL_KEY::ARTWORK],
				path.isEmpty() ? SLANG[W::NONE] : path,
												  FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],
												  artist);
		auto query = this->getQuery(queryStr);
		if(!query.exec())qDebug()<<"COULDNT Artwork[head] inerted into DB"<<artist;

		break;

	}
	default: return;
	}

	emit artworkInserted(track);
}


bool CollectionDB::removePlaylistTrack(const QString &url, const QString &playlist)
{
	auto queryTxt = QString("DELETE FROM %1 WHERE %2 = \"%3\" AND %4 = \"%5\"").arg(TABLEMAP[TABLE::TRACKS_PLAYLISTS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::PLAYLIST],
			playlist,
			FMH::MODEL_NAME[FMH::MODEL_KEY::URL],
			url);

	auto query = this->getQuery(queryTxt);
	return query.exec();
}

bool CollectionDB::removePlaylist(const QString &playlist)
{
	QString queryTxt;
	queryTxt = QString("DELETE FROM %1 WHERE %2 = \"%3\"").arg(TABLEMAP[TABLE::TRACKS_PLAYLISTS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::PLAYLIST],playlist);

	auto query = this->getQuery(queryTxt);
	if(!query.exec()) return false;

	queryTxt = QString("DELETE FROM %1 WHERE %2 = \"%3\"").arg(TABLEMAP[TABLE::PLAYLISTS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::PLAYLIST],playlist);

	query.prepare(queryTxt);
	return query.exec();
}

void CollectionDB::removeMissingTracks()
{
	auto tracks = this->getDBData("select url from tracks");

	for(auto track : tracks)
		if(!BAE::fileExists(track[FMH::MODEL_KEY::URL]))
			this->removeTrack(track[FMH::MODEL_KEY::URL]);

}

bool CollectionDB::removeArtwork(const QString &table, const QVariantMap &item)
{
	return this->update(table, {{FMH::MODEL_KEY::ARTWORK, ""}}, item);
}

bool CollectionDB::removeArtist(const QString &artist)
{
	const auto queryTxt = QString("DELETE FROM %1 WHERE %2 = \"%3\" ").arg(TABLEMAP[TABLE::ARTISTS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],artist);
	auto query = this->getQuery(queryTxt);

	return query.exec();
}

bool CollectionDB::cleanArtists()
{
	//    delete from artists where artist in (select artist from artists except select distinct artist from tracks);
	const auto queryTxt=QString("DELETE FROM %1 WHERE %2 IN (SELECT %2 FROM %1 EXCEPT SELECT DISTINCT %2 FROM %3)").arg(
				TABLEMAP[TABLE::ARTISTS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],
			TABLEMAP[TABLE::TRACKS]
			);
	qDebug()<<queryTxt;

	auto query = this->getQuery(queryTxt);
	emit this->artistsCleaned(query.numRowsAffected());
	return query.exec();
}

bool CollectionDB::removeFolder(const QString &url)
{
	const auto queryTxt=QString("DELETE FROM %1 WHERE %2 LIKE \"%3%\"").arg(
				TABLEMAP[TABLE::FOLDERS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url);

	qDebug()<<queryTxt;

	auto query = this->getQuery(queryTxt);
	return query.exec();
}

bool CollectionDB::favTrack(const QString &path, const bool &value)
{
	if(this->update(TABLEMAP[TABLE::TRACKS],
					FMH::MODEL_NAME[FMH::MODEL_KEY::FAV],
					value ? 1 : 0,
					FMH::MODEL_NAME[FMH::MODEL_KEY::URL],
					path)) return true;
	return false;
}

bool CollectionDB::removeAlbum(const QString &album, const QString &artist)
{
	const auto queryTxt = QString("DELETE FROM %1 WHERE %2 = \"%3\" AND %4 = \"%5\"").arg(TABLEMAP[TABLE::ALBUMS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM],
			album,
			FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],
			artist);

	auto query = this->getQuery(queryTxt);
	return query.exec();
}

bool CollectionDB::cleanAlbums()
{
	//    delete from albums where (album, artist) in (select a.album, a.artist from albums a except select distinct album, artist from tracks);
   const auto queryTxt=QString("DELETE FROM %1 WHERE (%2, %3) IN (SELECT %2, %3 FROM %1 EXCEPT SELECT DISTINCT %2, %3  FROM %4)").arg(
				TABLEMAP[TABLE::ALBUMS],
			FMH::MODEL_NAME[FMH::MODEL_KEY::ALBUM],
			FMH::MODEL_NAME[FMH::MODEL_KEY::ARTIST],
			TABLEMAP[TABLE::TRACKS]
			);
	qDebug()<<queryTxt;
	auto query = this->getQuery(queryTxt);
	emit albumsCleaned(query.numRowsAffected());
	return query.exec();
}


