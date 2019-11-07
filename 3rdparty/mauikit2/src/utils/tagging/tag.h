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

#ifndef TAG_H
#define TAG_H

#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QFileInfo>
#include <QImage>
#include <QTime>
#include <QSettings>
#include <QDirIterator>
#include <QVariantList>

namespace TAG
{
    enum class TABLE : uint8_t
    {
        USERS,
        TAGS_USERS,
        APPS_USERS,
        TAGS,
        TAGS_URLS,
        APPS,
        ABSTRACT,
        TAGS_ABSTRACT,
        NONE
    };

    static const QMap<TABLE,QString> TABLEMAP =
    {
        {TABLE::TAGS, "tags"},
        {TABLE::TAGS_URLS,"tags_urls"},
        {TABLE::USERS, "users"},
        {TABLE::TAGS_USERS,"tags_users"},
        {TABLE::APPS, "apps"},
        {TABLE::ABSTRACT,"abstract"},
        {TABLE::TAGS_ABSTRACT, "tags_abstract"},
        {TABLE::APPS_USERS,"apps_users"}
    };

	enum KEYS : uint_fast8_t
    {
        URL,
        APP,
        URI,
        MAC,
        LAST_SYNC,
        NAME,
        VERSION,
        LOT,
        TAG,
        COLOR,
        ADD_DATE,
        COMMENT,
        MIME,
        TITLE,
        DEVICE,
		KEY
    };/* Q_ENUM_NS(KEYS);*/

    typedef QMap<TAG::KEYS, QString> DB;
    typedef QList<DB> DB_LIST;
	
    static const DB KEYMAP =
    {
        {TAG::KEYS::URL, "url"},
		{TAG::KEYS::TAG, "tag"},
		{TAG::KEYS::COLOR, "color"},
		{TAG::KEYS::ADD_DATE, "addDate"},
		{TAG::KEYS::COMMENT, "comment"},
		{TAG::KEYS::MIME, "mime"},
		{TAG::KEYS::TITLE, "title"},
		{TAG::KEYS::NAME, "name"},
		{TAG::KEYS::DEVICE, "device"},
		{TAG::KEYS::MAC, "mac"},
		{TAG::KEYS::LAST_SYNC, "lastSync"},
		{TAG::KEYS::LOT, "lot"},
		{TAG::KEYS::KEY, "key"},
		{TAG::KEYS::NAME, "name"},
		{TAG::KEYS::APP, "app"},
		{TAG::KEYS::URI, "uri"},
		{TAG::KEYS::VERSION, "version"}
    };	
	
    static const QMap<QString, TAG::KEYS> MAPKEY =
	{
		{TAG::KEYMAP[KEYS::URL], KEYS::URL},
		{TAG::KEYMAP[KEYS::TAG], KEYS::TAG},
		{TAG::KEYMAP[KEYS::COLOR], KEYS::TAG},
		{TAG::KEYMAP[KEYS::ADD_DATE], KEYS::ADD_DATE},
		{TAG::KEYMAP[KEYS::COMMENT], KEYS::COMMENT},
		{TAG::KEYMAP[KEYS::MIME], KEYS::MIME},
		{TAG::KEYMAP[KEYS::TITLE], KEYS::TITLE},
		{TAG::KEYMAP[KEYS::NAME], KEYS::NAME},
		{TAG::KEYMAP[KEYS::DEVICE], KEYS::DEVICE},
		{TAG::KEYMAP[KEYS::MAC], KEYS::MAC},
		{TAG::KEYMAP[KEYS::LAST_SYNC], KEYS::LAST_SYNC},
		{TAG::KEYMAP[KEYS::LOT], KEYS::LOT},
		{TAG::KEYMAP[KEYS::KEY], KEYS::LOT},
		{TAG::KEYMAP[KEYS::NAME], KEYS::NAME},
		{TAG::KEYMAP[KEYS::APP], KEYS::APP},
		{TAG::KEYMAP[KEYS::URI], KEYS::URI},
		{TAG::KEYMAP[KEYS::VERSION], KEYS::VERSION}
	};

    const QString TaggingPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/maui/tagging/";
    const QString DBName = "tagging.db";
}

#endif // TAG_H
