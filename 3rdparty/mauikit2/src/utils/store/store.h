/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2018  camilo <email>
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef STORE_H
#define STORE_H

#include <QObject>
#include "fmh.h"

#ifdef STATIC_MAUIKIT
//#include "providermanager.h"
//#include "provider.h"
//#include "category.h"
//#include "content.h"
//#include "listjob.h"
//#include "person.h"
//#include "project.h"
//#include "downloaditem.h"
#include <attica/Attica/attica/providermanager.h>
#include <attica/Attica/attica/provider.h>
#include <attica/Attica/attica/category.h>
#include <attica/Attica/attica/content.h>
#include <attica/Attica/attica/listjob.h>
#include <attica/Attica/attica/person.h>
#include <attica/Attica/attica/project.h>
#include <attica/Attica/attica/downloaditem.h>

#else
#include <Attica/ProviderManager>
#include <Attica/Provider>
#include <Attica/ListJob>
#include <Attica/Content>
#include <Attica/DownloadItem>
#include <Attica/AccountBalance>
#include <Attica/Person>
#include <Attica/Project>
#include <Attica/Category>
#endif

namespace STORE
{
	
	typedef QString PROVIDER;
	
	const PROVIDER OPENDESKTOP_API = "https://api.opendesktop.org/v1/";
	const PROVIDER KDELOOK_API = "https://api.kde-look.org/ocs/v1/";
	const PROVIDER KRITA_API = "https://share.krita.org/ocs/v1/";
	const PROVIDER OPENDESKTOPCC_API = "https://pling.cc/ocs/v1/";
	
    enum CATEGORY_KEY : uint
	{
		WALLPAPERS,
		IMAGES,
		COMICS,
		AUDIO,
		ART,
		CLIPS,
		MOVIES,
		EBOOKS,
		NONE
	};
	
    enum ATTRIBUTE_KEY : uint
	{
		PREVIEW_1,
		PREVIEW_2,
		PREVIEW_SMALL_1,
		PREVIEW_SMALL_2,
		DOWNLOAD_LINK,
		XDG_TYPE
	};
	
	static const QHash<STORE::ATTRIBUTE_KEY, QString> ATTRIBUTE=
	{
		{STORE::ATTRIBUTE_KEY::PREVIEW_1, QString("previewpic1")},
		{STORE::ATTRIBUTE_KEY::PREVIEW_2, QString("previewpic2")},
		{STORE::ATTRIBUTE_KEY::PREVIEW_SMALL_1, QString("smallpreviewpic1")},
		{STORE::ATTRIBUTE_KEY::PREVIEW_SMALL_2, QString("smallpreviewpic2")},
		{STORE::ATTRIBUTE_KEY::DOWNLOAD_LINK, QString("downloadlink1")}, 
		{STORE::ATTRIBUTE_KEY::XDG_TYPE, QString("xdg_type")} 
	};
	
	const QStringList WALLPAPERS_LIST = QStringList
	{
		"wallpapers", 
		"wallpapers", 
		"Wallpaper", 
		"Wallpapers",
		"Wallpaper 800x600",
		"Wallpaper 1024x768", 
		"Wallpaper 1280x1024",
		"Wallpaper 1440x900", 
		"Wallpaper 1600x1200",
		"Wallpaper (other)",
		"KDE Wallpaper 800x600",
		"KDE Wallpaper 1024x768", 
		"KDE Wallpaper 1280x1024",
		"KDE Wallpaper 1440x900", 
		"KDE Wallpaper 1600x1200",
		"KDE Wallpaper (other)"			
	};
	
	const QStringList COMICS_LIST = QStringList
	{
		"comics", 
		"Comics", 
		"comic", 
		"Comic"		
	};	
	
	const QStringList ART_LIST = QStringList
	{
		"art", 
		"drawings", 
		"Art", 
		"Wallpapers", 
		"Drawings", 
		"Paintings", 
		"paintings",
		"Drawings/Paintings"
	};
	
	const QStringList EBOOKS_LIST = QStringList
	{
		"Books", 
		"Books/ Arts & Photography", 
		"Books/ Biographies & Memoirs", 
		"Books/ Business & Investing", 
		"Books/ Calendars", 
		"Books/ Comics & Graphic Novels", 
		"Books/ Computers & Technology",
		"Books/ Cookbooks, Food & Wine",
		"Books/ Fun",
		"Books/ Gutenberg",
		"Gutenberg/ Adventure",
		"Gutenberg/ African American Writers",
		"Gutenberg/ American Revolutionary War",
		"Gutenberg/ Arthurian Legends",
		"Gutenberg/ Banned Books from Anne Haight's list",
		"Gutenberg/ Best Books Ever Listings",
		"Gutenberg/ Bestsellers, American, 1895-1923",
		"Gutenberg/ Canada",
		"Gutenberg/ Children's Literature",
		"Gutenberg/ Christianity",
		"Gutenberg/ Christmas",
		"Gutenberg/ CIA World Factbooks"
		"Gutenberg/ Contemporary Reviews",
		"Gutenberg/ Fantasy",
		"Gutenberg/ Gothic Fiction",
		"Gutenberg/ Harvard Classics",
		"Gutenberg/ Historical Fiction",
		"Gutenberg/ Horror" "137",
		"Gutenberg/ Latter Day Saints",
		"Gutenberg/ Mathematics",
		"Gutenberg/ Movie Books",
		"Gutenberg/ Native America",
		"Gutenberg/ No Category",
		"Gutenberg/ Opera",
		"Gutenberg/ Philosophy",
		"Gutenberg/ Plays",
		"Gutenberg/ Poetry",
		"Gutenberg/ Politics",
		"Gutenberg/ Precursors of Science Fiction",
		"Gutenberg/ Reference",
		"Gutenberg/ Science Fiction",
		"Gutenberg/ Science Fiction by Women",
		"Gutenberg/ Slavery",
		"Gutenberg/ United States",
		"Gutenberg/ United States Law",
		"Gutenberg/ US Civil War",
		"Books/ Health, Fitness & Dieting",
		"Books/ Literature & Fiction",
		"Books/ Mystery, Thriller & Suspense",
		"Books/ Sports & Outdoors",
		"Books/ Travel"
		
	};
	
	static const QHash<CATEGORY_KEY, QStringList> CATEGORIES =
	{
		{CATEGORY_KEY::WALLPAPERS, QStringList() << STORE::WALLPAPERS_LIST},
		
		{CATEGORY_KEY::COMICS, QStringList() << STORE::COMICS_LIST},
		
		{CATEGORY_KEY::ART, QStringList () << STORE::ART_LIST},
		
		{CATEGORY_KEY::EBOOKS, QStringList () << STORE::EBOOKS_LIST},
		
		{CATEGORY_KEY::IMAGES, QStringList () << STORE::WALLPAPERS_LIST << STORE::COMICS_LIST << STORE::ART_LIST}		
	};
}

class Store : public QObject
{
	Q_OBJECT
	
public:  
// 	 Q_ENUM(STORE::CATEGORY_KEY);	
	
	Store(QObject *parent = nullptr);   
	~Store();
	
	void start();
	void setProvider(const STORE::PROVIDER &provider);
	void setCategory(const STORE::CATEGORY_KEY &categoryKey);
	
	void searchFor(const STORE::CATEGORY_KEY& categoryKey, const QString &query = QString(), const int &limit = 10, const int &page = 1, const Attica::Provider::SortMode &sortBy = Attica::Provider::SortMode::Rating);
	void listProjects();
	void listCategories();
	
	void download(const QString &id);
	void download(const FMH::MODEL &item);
	
	QHash<QString, QString> getCategoryIDs();
	
public slots:
	void providersChanged();
	void categoryListResult(Attica::BaseJob* j);
	void projectListResult(Attica::BaseJob *j);
	void contentListResult(Attica::BaseJob *j);
	void contentDownloadReady(Attica::BaseJob *j);
	void getPersonInfo(const QString &nick);
	
	void perfomSearch();	
	
private:
	Attica::ProviderManager m_manager;
	Attica::Provider m_provider;
	QHash<QString, QString> categoryID;
	STORE::CATEGORY_KEY m_category = STORE::CATEGORY_KEY::NONE;
	
	STORE::PROVIDER provider = STORE::KDELOOK_API;
	
	QString query;
	int limit = 10;
	int page = 0;
	
	Attica::Provider::SortMode sortBy = Attica::Provider::SortMode::Rating;
	
	void downloadLink(const QString &url, const QString &fileName);
	
signals:
	void storeReady();
	void contentReady(FMH::MODEL_LIST list);
	void downloadReady(FMH::MODEL item);
	void warning(QString warning);
	void categoryIDsReady();
};




#endif // STORE_H
