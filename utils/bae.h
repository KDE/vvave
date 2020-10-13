#ifndef BAE_H
#define BAE_H

#include <QString>
#include <QStandardPaths>
#include <QFileInfo>
#include <QImage>
#include <QTime>
#include <QDirIterator>

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#else
#include <MauiKit/fmh.h>
#endif

namespace BAE
{
	enum class W : uint_fast8_t
		{
		ALL,
		NONE,
		LIKE,
		TAG,
		SIMILAR,
		UNKNOWN,
		DONE,
		DESC,
		ASC,
		CODE,
		MSG
		};

	static const QMap<W,QString> SLANG =
	{
		{W::ALL, "ALL"},
		{W::NONE, "NONE"},
		{W::LIKE, "LIKE"},
		{W::SIMILAR, "SIMILAR"},
		{W::UNKNOWN, "UNKNOWN"},
		{W::DONE, "DONE"},
		{W::DESC, "DESC"},
		{W::ASC, "ASC"},
		{W::TAG, "TAG"},
		{W::MSG, "MSG"},
		{W::CODE, "CODE"}
	};

	enum class TABLE : uint8_t
		{
		ALBUMS,
		ARTISTS,
		SOURCES,
		SOURCES_TYPES,
		TRACKS,
		FOLDERS,
		ALL,
		NONE
		};

	static const QMap<TABLE,QString> TABLEMAP =
	{
		{TABLE::ALBUMS,"albums"},
		{TABLE::ARTISTS,"artists"},
		{TABLE::SOURCES,"sources"},
		{TABLE::SOURCES_TYPES,"sources_types"},
		{TABLE::TRACKS,"tracks"},
		{TABLE::FOLDERS,"folders"}

	};

	enum class KEY :uint8_t
		{
		URL = 0,
		SOURCES_URL = 1,
		TRACK = 2,
		TITLE = 3,
		ARTIST = 4,
		ALBUM = 5,
		DURATION = 6,
		PLAYED = 7,
		STARS = 9,
		RELEASE_DATE = 10,
		ADD_DATE = 11,
		LYRICS = 12,
		GENRE = 13,
		ART = 14,
		TAG = 15,
		MOOD = 16,
		PLAYLIST = 17,
		ARTWORK = 18,
		WIKI = 19,
		SOURCE_TYPE = 20,
		CONTEXT = 21,
		RETRIEVAL_DATE = 22,
		COMMENT = 23,
		ID = 24,
		SQL = 25,
		NONE = 26
		};

	typedef QMap<BAE::KEY, QString> DB;
	typedef QList<DB> DB_LIST;

	static const DB KEYMAP =
	{
		{KEY::URL, "url"},
		{KEY::SOURCES_URL, "sources_url"},
		{KEY::TRACK, "track"},
		{KEY::TITLE, "title"},
		{KEY::ARTIST, "artist"},
		{KEY::ALBUM, "album"},
		{KEY::DURATION, "duration"},
		{KEY::PLAYED, "played"},
		{KEY::STARS, "stars"},
		{KEY::RELEASE_DATE, "releaseDate"},
		{KEY::ADD_DATE, "addDate"},
		{KEY::LYRICS, "lyrics"},
		{KEY::GENRE, "genre"},
		{KEY::ART, "art"},
		{KEY::TAG, "tag"},
		{KEY::MOOD, "mood"},
		{KEY::PLAYLIST, "playlist"},
		{KEY::ARTWORK, "artwork"},
		{KEY::WIKI, "wiki"},
		{KEY::SOURCE_TYPE, "source_types_id"},
		{KEY::CONTEXT, "context"},
		{KEY::RETRIEVAL_DATE, "retrieval_date"},
		{KEY::ID, "id"},
		{KEY::COMMENT, "comment"},
		{KEY::SQL, "sql"}
	};

	static const QString CollectionDBPath =  QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/vvave/").toLocalFile();

#ifdef Q_OS_ANDROID
	const static QString CachePath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/vvave/").toString();
#else
	const static QString CachePath =  QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation)+"/vvave/").toString();
#endif

    const static QString DBName = QStringLiteral("collection.db");
	const static QStringList defaultSources = QStringList() << FMH::MusicPath
															<< FMH::DownloadsPath;

	const static inline QString fixTitle(const QString &title,const QString &s,const QString &e)
	{
		QString newTitle;
		for(int i=0; i<title.size();i++)
			if(title.at(i)==s)
			{
				while(title.at(i)!=e)
					if(i==title.size()-1) break;
					else i++;

			}else newTitle+=title.at(i);

		return newTitle.simplified();
	}

	const static inline QString removeSubstring(const QString &newTitle, const QString &subString)
	{
		const int indexFt = newTitle.indexOf(subString, 0, Qt::CaseInsensitive);

		if (indexFt != -1)
			return newTitle.left(indexFt).simplified();
		else
			return newTitle;
	}

	const static inline QString ucfirst(const QString &str)/*uppercase first letter*/
	{
		if (str.isEmpty()) return "";

		QStringList tokens;
		QStringList result;
		QString output;

		if(str.contains(" "))
		{
			tokens = str.split(" ");

			for(auto str : tokens)
			{
				str = str.toLower();
				str[0] = str[0].toUpper();
				result<<str;
			}

			output = result.join(" ");
		}else output = str;

		return output.simplified();
	}

	const static inline QString fixString (const QString &str)
	{
		//title.remove(QRegExp(QString::fromUtf8("[·-`~!@#$%^&*()_—+=|:;<>«»,.?/{}\'\"\\\[\\\]\\\\]")));
		QString title = str;
		title = title.remove(QChar::Null);
		title = title.contains(QChar('\u0000')) ? title.replace(QChar('\u0000'),"") : title;
		title = title.contains("(") && title.contains(")") ? fixTitle(title, "(",")") : title;
		title = title.contains("[") && title.contains("]") ? fixTitle(title, "[","]") : title;
		title = title.contains("{") && title.contains("}") ? fixTitle(title, "{","}") : title;
		title = title.contains("ft", Qt::CaseInsensitive) ? removeSubstring(title, "ft") : title;
		title = title.contains("ft.", Qt::CaseInsensitive) ? removeSubstring(title, "ft.") : title;
		title = title.contains("featuring", Qt::CaseInsensitive) ? removeSubstring(title, "featuring"):title;
		title = title.contains("feat", Qt::CaseInsensitive) ? removeSubstring(title, "feat") : title;
		title = title.contains("official video", Qt::CaseInsensitive) ? removeSubstring(title, "official video"):title;
		title = title.contains("live", Qt::CaseInsensitive) ? removeSubstring(title, "live") : title;
		title = title.contains("...") ? title.replace("..." ,"") : title;
		title = title.contains("|") ? title.replace("|", "") : title;
		title = title.contains("|") ? removeSubstring(title, "|") : title;
		title = title.contains('"') ? title.replace('"', "") : title;
		title = title.contains(":") ? title.replace(":", "") : title;
		//    title=title.contains("&")? title.replace("&", "and"):title;
		//qDebug()<<"fixed string:"<<title;

		return ucfirst(title).simplified();
	}

	static inline BAE::TABLE albumType(const FMH::MODEL &albumMap)
	{
		if(albumMap[FMH::MODEL_KEY::ALBUM].isEmpty() && !albumMap[FMH::MODEL_KEY::ARTIST].isEmpty())
			return BAE::TABLE::ARTISTS;
		else if(!albumMap[FMH::MODEL_KEY::ALBUM].isEmpty() && !albumMap[FMH::MODEL_KEY::ARTIST].isEmpty())
			return BAE::TABLE::ALBUMS;

		return BAE::TABLE::NONE;
	}

	static inline void saveArt(FMH::MODEL &track, const QByteArray &array, const QString &path)
	{
		if(!array.isNull() && !array.isEmpty())
		{
			// qDebug()<<"tryna save array: "<< array;

			QImage img;
			img.loadFromData(array);
			QString name = !track[FMH::MODEL_KEY::ALBUM].isEmpty() ? track[FMH::MODEL_KEY::ARTIST] + "_" + track[FMH::MODEL_KEY::ALBUM] : track[FMH::MODEL_KEY::ARTIST];
			name.replace("/", "-");
			name.replace("&", "-");
			const QString format = "PNG";
			qDebug()<< "SAVER TO "<< path + name + ".png";
			if (img.save(path + name + ".png", format.toLatin1(), 100))
				track.insert(FMH::MODEL_KEY::ARTWORK,path + name + ".png");
			else  qDebug() << "couldn't save artwork";
		}else qDebug()<<"array is empty";
	}

	static inline bool artworkCache(FMH::MODEL &track, const FMH::MODEL_KEY &type = FMH::MODEL_KEY::ID)
	{
		QDirIterator it(QUrl(CachePath).toLocalFile(), QDir::Files, QDirIterator::NoIteratorFlags);
		while (it.hasNext())
		{
			const auto file = QUrl::fromLocalFile(it.next());
			const auto fileName = QFileInfo(file.toLocalFile()).baseName();
			switch(type)
			{
				case FMH::MODEL_KEY::ALBUM:
					if(fileName == (track[FMH::MODEL_KEY::ARTIST]+"_"+track[FMH::MODEL_KEY::ALBUM]))
					{
						track.insert(FMH::MODEL_KEY::ARTWORK, file.toString());
						return true;
					}
					break;

				case FMH::MODEL_KEY::ARTIST:
					if(fileName == (track[FMH::MODEL_KEY::ARTIST]))
					{
						track.insert(FMH::MODEL_KEY::ARTWORK, file.toString());
						return true;
					}
					break;
				default: break;
			}
		}
		return false;
	}
}



#endif // BAE_H
