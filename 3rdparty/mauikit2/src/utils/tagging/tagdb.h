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

#ifndef TAGDB_H
#define TAGDB_H

#include <QObject>
#include <QString>
#include <QStringList>
#include <QList>
#include <QSqlDatabase>
#include <QDebug>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QSqlDriver>
#include <QFileInfo>
#include <QDir>
#include <QVariantMap>

#include "tag.h"
#include "utils.h"


class TAGDB : public QObject
{
    Q_OBJECT
private:
    QString name;
    QSqlDatabase m_db;

public:
    /* utils*/
    Q_INVOKABLE bool checkExistance(const QString &tableName, const QString &searchId, const QString &search);
    Q_INVOKABLE bool checkExistance(const QString &queryStr);

protected:
    TAGDB(QObject *parent = nullptr);
    ~ TAGDB();

    QSqlQuery getQuery(const QString &queryTxt);
    void openDB(const QString &name);
    void prepareCollectionDB() const;

    bool insert(const QString &tableName, const QVariantMap &insertData);
    bool update(const QString &tableName, const TAG::DB &updateData, const QVariantMap &where);
    bool update(const QString &table, const QString &column, const QVariant &newValue, const QVariant &op, const QString &id);
    bool remove(const QString &tableName, const TAG::DB &removeData);

signals:

public slots:
};


#endif // DB_H
