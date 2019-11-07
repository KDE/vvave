/*
 *   Copyright 2018 Camilo Higuita <milo.h@aol.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "tagging.h"
#include <QMimeDatabase>
#include <QNetworkInterface>

#include "utils.h"

Tagging::Tagging(QObject *parent) : TAGDB(parent)
{
    this->setApp();
}

Tagging::~Tagging() 
{
// 	delete this->instance;
}

Tagging *Tagging::instance = nullptr;
Tagging *Tagging::getInstance()
{
    if(!instance)
    {
        instance = new Tagging();
        qDebug() << "getInstance(): First instance\n";
        return instance;
    } else
    {
        qDebug()<< "getInstance(): previous instance\n";
        return instance;
    }
}

QVariantList Tagging::get(const QString &queryTxt)
{
    QVariantList mapList;

    auto query = this->getQuery(queryTxt);

    if(query.exec())
    {
        while(query.next())
        {
            QVariantMap data;
            for(auto key : TAG::KEYMAP.keys())
                if(query.record().indexOf(TAG::KEYMAP[key]) > -1)
                    data[TAG::KEYMAP[key]] = query.value(TAG::KEYMAP[key]).toString();

            mapList<< data;

        }

    }else qDebug()<< query.lastError()<< query.lastQuery();

    return mapList;
}

bool Tagging::tagExists(const QString &tag, const bool &strict)
{
    return !strict ? this->checkExistance(TAG::TABLEMAP[TAG::TABLE::TAGS], TAG::KEYMAP[TAG::KEYS::TAG], tag) :
            this->checkExistance(QString("select t.tag from TAGS t inner join TAGS_USERS tu on t.tag = tu.tag inner join APPS_USERS au on au.mac = tu.mac "
            "where au.app = '%1' and au.uri = '%2' and t.tag = '%3'").arg(this->application, this->uri, tag));
}

bool Tagging::urlTagExists(const QString &url,const QString &tag, const bool &strict)
{
	return !strict ? this->checkExistance(QString("select * from TAGS_URLS where url = '%1' and tag = '%2'").arg(url, tag)) :
	this->checkExistance(QString("select t.tag from TAGS t inner join TAGS_USERS tu on t.tag = tu.tag inner join APPS_USERS au on au.mac = tu.mac "
	"where au.app = '%1' and au.uri = '%2' and t.tag = '%3'").arg(this->application, this->uri, tag));
}

void Tagging::setApp()
{
    this->application = UTIL::app->applicationName();
	this->version = UTIL::app->applicationVersion();
    this->comment = QString();
	this->uri = UTIL::app->organizationDomain().isEmpty() ? QString("org.maui.%1").arg(this->application) : UTIL::app->organizationDomain();
    this->app();
}

bool Tagging::tag(const QString &tag, const QString &color, const QString &comment)
{
    if(tag.isEmpty()) return false;

    QVariantMap tag_map
    {
        {TAG::KEYMAP[TAG::KEYS::TAG], tag},
        {TAG::KEYMAP[TAG::KEYS::COLOR], color},
        {TAG::KEYMAP[TAG::KEYS::ADD_DATE], QDateTime::currentDateTime().toString(Qt::TextDate)},
        {TAG::KEYMAP[TAG::KEYS::COMMENT], comment},
    };

    this->insert(TAG::TABLEMAP[TAG::TABLE::TAGS], tag_map);

    QVariantMap tag_user_map
    {
        {TAG::KEYMAP[TAG::KEYS::TAG], tag},
        {TAG::KEYMAP[TAG::KEYS::MAC], this->id()}
    };

    if(this->insert(TAG::TABLEMAP[TAG::TABLE::TAGS_USERS], tag_user_map))
    {
        emit this->tagged(tag);
        return true;
    }

    return false;
}

bool Tagging::tagUrl(const QString &url, const QString &tag, const QString &color, const QString &comment)
{
    auto myTag = tag.trimmed();

    this->tag(myTag, color, comment);

    QMimeDatabase mimedb;
    auto mime = mimedb.mimeTypeForFile(url);

    QVariantMap tag_url_map
    {
        {TAG::KEYMAP[TAG::KEYS::URL], url},
        {TAG::KEYMAP[TAG::KEYS::TAG], myTag},
        {TAG::KEYMAP[TAG::KEYS::TITLE], QFileInfo(url).baseName()},
        {TAG::KEYMAP[TAG::KEYS::MIME], mime.name()},
        {TAG::KEYMAP[TAG::KEYS::ADD_DATE], QDateTime::currentDateTime()},
        {TAG::KEYMAP[TAG::KEYS::COMMENT], comment}
    };

    emit this->urlTagged(url, myTag);
    return this->insert(TAG::TABLEMAP[TAG::TABLE::TAGS_URLS], tag_url_map);
}

bool Tagging::tagAbstract(const QString &tag, const QString &key, const QString &lot, const QString &color, const QString &comment)
{
    this->abstract(key, lot, comment);
    this->tag(tag, color, comment);

    QVariantMap tag_abstract_map
    {
        {TAG::KEYMAP[TAG::KEYS::APP], this->application},
        {TAG::KEYMAP[TAG::KEYS::URI], this->uri},
        {TAG::KEYMAP[TAG::KEYS::TAG], tag},
        {TAG::KEYMAP[TAG::KEYS::KEY], key},
        {TAG::KEYMAP[TAG::KEYS::LOT], lot},
        {TAG::KEYMAP[TAG::KEYS::ADD_DATE], QDateTime::currentDateTime()},
        {TAG::KEYMAP[TAG::KEYS::COMMENT], comment},
    };

    emit this->abstractTagged(key, lot, tag);
    return this->insert(TAG::TABLEMAP[TAG::TABLE::TAGS_ABSTRACT], tag_abstract_map);
}

bool Tagging::updateUrlTags(const QString &url, const QStringList &tags)
{
    this->removeUrlTags(url);
    for(const auto &tag : tags)
        this->tagUrl(url, tag);
    
    return true;
}

bool Tagging::updateUrl(const QString& url, const QString& newUrl)
{
	return this->update(TAG::TABLEMAP[TAG::TABLE::TAGS_URLS], {{TAG::KEYS::URL, newUrl}}, {{TAG::KEYMAP[TAG::KEYS::URL], url}});
}

bool Tagging::updateAbstractTags(const QString &key, const QString &lot, const QStringList &tags)
{
	this->removeAbstractTags(key, lot);
	
	for(const auto &tag : tags)
		this->tagAbstract(tag, key, lot);
	
	return true;
}

QVariantList Tagging::getUrlsTags(const bool &strict)
{
    const auto query = QString("select distinct t.* from TAGS t inner join TAGS_USERS tu on t.tag = tu.tag "
                         "inner join APPS_USERS au on au.mac = tu.mac "
                         "inner join TAGS_URLS turl on turl.tag = t.tag "
                         "where au.app = '%1' and au.uri = '%2'").arg(this->application, this->uri);


    return !strict ? this->get("select distinct t.* from tags t inner join TAGS_URLS turl on turl.tag = t.tag") :
                         this->get(query);
}

QVariantList Tagging::getAbstractsTags(const bool &strict)
{
    return !strict ? this->get("select t.* from tags t inner join TAGS_ABSTRACT tab on tab.tag = t.tag") :
                         this->get(QString("select t.* from TAGS t inner join TAGS_USERS tu on t.tag = tu.tag "
                                           "inner join APPS_USERS au on au.mac = tu.mac "
                                           "inner join TAGS_ABSTRACT tab on tab.tag = t.tag "
                                           "where au.app = '%1' and au.uri = '%2'").arg(this->application, this->uri));
}

QVariantList Tagging::getAllTags(const bool &strict)
{
    return !strict ? this->get("select * from tags") :
                         this->get(QString("select t.* from TAGS t inner join TAGS_USERS tu on t.tag = tu.tag inner join APPS_USERS au on au.mac = tu.mac "
                                           "where au.app = '%1' and au.uri = '%2'").arg(this->application, this->uri));
	
}

QVariantList Tagging::getUrls(const QString &tag, const bool &strict)
{
    return !strict ? this->get(QString("select turl.*, t.color, t.comment as tagComment from TAGS t inner join TAGS_URLS turl on turl.tag = t.tag where t.tag = '%1'").arg(tag)):
                          this->get(QString("select distinct turl.*, t.color, t.comment as tagComment from TAGS t "
                                            "inner join TAGS_USERS tu on t.tag = tu.tag "
                                            "inner join APPS_USERS au on au.mac = tu.mac "
                                            "inner join TAGS_URLS turl on turl.tag = t.tag "
                                            "where au.app = '%1' and au.uri = '%2' "
                                            "and t.tag = '%3'").arg(this->application, this->uri, tag));
}

QVariantList Tagging::getUrlTags(const QString &url, const bool &strict)
{

    return !strict ? this->get(QString("select turl.*, t.color, t.comment as tagComment from tags t inner join TAGS_URLS turl on turl.tag = t.tag where turl.url  = '%1'").arg(url)) :
                         this->get(QString("select distinct t.* from TAGS t inner join TAGS_USERS tu on t.tag = tu.tag inner join APPS_USERS au on au.mac = tu.mac inner join TAGS_URLS turl on turl.tag = t.tag "
                                           "where au.app = '%1' and au.uri = '%2' and turl.url = '%3'").arg(this->application, this->uri, url));
}

QVariantList Tagging::getAbstractTags(const QString &key, const QString &lot, const bool &strict)
{
    return !strict ? this->get(QString("select t.* from TAGS t inner join TAGS_ABSTRACT ta on ta.tag = t.tag where ta.key = '%1' and ta.lot = '%2'").arg(key, lot)) :
                         this->get(QString("select distinct t.*  from TAGS t inner join TAGS_ABSTRACT ta on ta.tag = t.tag "
                                           "inner join TAGS_USERS tu on t.tag = tu.tag "
                                           "inner join APPS_USERS au on au.mac = tu.mac "
                                           "where au.app = '%1' and au.uri = '%2' and ta.key = '%3' and ta.lot = '%4'").arg(this->application, this->uri, key, lot));
}

bool Tagging::removeAbstractTag(const QString& key, const QString& lot, const QString &tag)
{
	TAG::DB data {{TAG::KEYS::KEY, key}, {TAG::KEYS::LOT, lot}, {TAG::KEYS::TAG, tag}};
	return this->remove(TAG::TABLEMAP[TAG::TABLE::TAGS_ABSTRACT], data);		
}

bool Tagging::removeAbstractTags(const QString& key, const QString& lot)
{
	for(const auto &map : this->getAbstractTags(key, lot))
	{
		auto tag = map.toMap().value(TAG::KEYMAP[TAG::KEYS::TAG]).toString();
		this->removeAbstractTag(key, lot, tag);
	}
	
	return true;
}

bool Tagging::removeUrlTags(const QString &url)
{
    for(const auto &map : this->getUrlTags(url))
    {
        auto tag = map.toMap().value(TAG::KEYMAP[TAG::KEYS::TAG]).toString();
        this->removeUrlTag(url, tag);
    }

    return true;
}

bool Tagging::removeUrlTag(const QString& url, const QString& tag)
{	
	TAG::DB data {{TAG::KEYS::URL, url}, {TAG::KEYS::TAG, tag}};
	return this->remove(TAG::TABLEMAP[TAG::TABLE::TAGS_URLS], data);	
}

QString Tagging::mac()
{
    QNetworkInterface mac;
    qDebug()<< "MAC ADDRES:"<< mac.hardwareAddress();
    return mac.hardwareAddress();
}

QString Tagging::device()
{
    return QSysInfo::prettyProductName();
}

QString Tagging::id()
{
    return QSysInfo::machineHostName();

    //    qDebug()<< "VERSION IS LES THAN "<< QT_VERSION;

    //#if QT_VERSION < QT_VERSION_CHECK(5, 1, 1)
    //    return QSysInfo::machineHostName();
    //#else
    //    return QString(QSysInfo::machineUniqueId());
    //#endif
}

bool Tagging::app()
{
    qDebug()<<"REGISTER APP" << this->application<< this->uri<< this->version<< this->comment;
    QVariantMap app_map
    {
        {TAG::KEYMAP[TAG::KEYS::APP], this->application},
        {TAG::KEYMAP[TAG::KEYS::URI], this->uri},
        {TAG::KEYMAP[TAG::KEYS::VERSION], this->version},
        {TAG::KEYMAP[TAG::KEYS::ADD_DATE], QDateTime::currentDateTime()},
        {TAG::KEYMAP[TAG::KEYS::COMMENT], this->comment},
    };

    this->insert(TAG::TABLEMAP[TAG::TABLE::APPS], app_map);

    this->user();

    QVariantMap users_apps_map
    {
        {TAG::KEYMAP[TAG::KEYS::APP], this->application},
        {TAG::KEYMAP[TAG::KEYS::URI], this->uri},
        {TAG::KEYMAP[TAG::KEYS::MAC], this->id()},
        {TAG::KEYMAP[TAG::KEYS::ADD_DATE], QDateTime::currentDateTime()},
    };

    return this->insert(TAG::TABLEMAP[TAG::TABLE::APPS_USERS], users_apps_map);

}

bool Tagging::user()
{
    QVariantMap user_map
    {
        {TAG::KEYMAP[TAG::KEYS::MAC], this->id()},
        {TAG::KEYMAP[TAG::KEYS::NAME], UTIL::whoami()},
        {TAG::KEYMAP[TAG::KEYS::LAST_SYNC], QDateTime::currentDateTime()},
        {TAG::KEYMAP[TAG::KEYS::ADD_DATE], QDateTime::currentDateTime()},
        {TAG::KEYMAP[TAG::KEYS::DEVICE], this->device()},
    };

    return this->insert(TAG::TABLEMAP[TAG::TABLE::USERS], user_map);
}

bool Tagging::abstract(const QString &key, const QString &lot, const QString &comment)
{
    QVariantMap abstract_map
    {
        {TAG::KEYMAP[TAG::KEYS::APP], this->application},
        {TAG::KEYMAP[TAG::KEYS::URI], this->uri},
        {TAG::KEYMAP[TAG::KEYS::KEY], key},
        {TAG::KEYMAP[TAG::KEYS::LOT], lot},
        {TAG::KEYMAP[TAG::KEYS::ADD_DATE], QDateTime::currentDateTime()},
        {TAG::KEYMAP[TAG::KEYS::COMMENT], comment},
    };

    return this->insert(TAG::TABLEMAP[TAG::TABLE::ABSTRACT], abstract_map);
}


