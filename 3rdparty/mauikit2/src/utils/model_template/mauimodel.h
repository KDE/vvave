/*
 * <one line to give the program's name and a brief idea of what it does.>
 * Copyright (C) 2019  camilo <chiguitar@unal.edu.co>
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

#ifndef MAUIMODEL_H
#define MAUIMODEL_H

#include <QObject>
#include <QAbstractListModel>
#include <QSortFilterProxyModel>
#include <QList>

class MauiList;

#ifndef STATIC_MAUIKIT
#include "mauikit_export.h"
#endif

#ifdef STATIC_MAUIKIT
class MauiModel : public QSortFilterProxyModel
#else
class MAUIKIT_EXPORT MauiModel : public QSortFilterProxyModel
#endif
{
    Q_OBJECT
    Q_PROPERTY(MauiList *list READ getList WRITE setList)
  
    class PrivateAbstractListModel;    
    
public:    
    MauiModel(QObject *parent = nullptr);
    ~MauiModel();	
    
    MauiList* getList() const;
    void setList(MauiList *value);
    
protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
    
private:
    PrivateAbstractListModel *m_model;    
    
public slots:
    void setFilterString(const QString &string);
    void setSortOrder(const int &sortOrder);    
    
    QVariantMap get(const int &index);
    QVariantList getAll();
    
signals:
    void listChanged();
};

class MauiModel::PrivateAbstractListModel : public QAbstractListModel 
{
    Q_OBJECT
public:
    PrivateAbstractListModel(QObject *parent = nullptr);
    ~PrivateAbstractListModel();
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    
    // Editable:
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    
    Qt::ItemFlags flags(const QModelIndex& index) const override;
    
    virtual QHash<int, QByteArray> roleNames() const override;
    
    MauiList* getList() const;
    void setList(MauiList *value);	
    
private:    
    MauiList *list;
    
};

#endif // MAUIMODEL_H
