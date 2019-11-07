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

#include "storemodel.h"
#include "storelist.h"
#include "fmh.h"

StoreModel::StoreModel(QObject *parent)
: QAbstractListModel(parent),
mList(nullptr)
{}

int StoreModel::rowCount(const QModelIndex &parent) const
{
	if (parent.isValid() || !mList)
		return 0;
	
	return mList->items().size();
}

QVariant StoreModel::data(const QModelIndex &index, int role) const
{
	if (!index.isValid() || !mList)
		return QVariant();
	
	return mList->items().at(index.row())[static_cast<FMH::MODEL_KEY>(role)];
}

bool StoreModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
	
	return false;
}

Qt::ItemFlags StoreModel::flags(const QModelIndex &index) const
{
	if (!index.isValid())
		return Qt::NoItemFlags;
	
	return Qt::ItemIsEditable; // FIXME: Implement me!
}

QHash<int, QByteArray> StoreModel::roleNames() const
{
	QHash<int, QByteArray> names;
	
	for(auto key : FMH::MODEL_NAME.keys())
		names[key] = QString(FMH::MODEL_NAME[key]).toUtf8();
	
	return names;
}

StoreList *StoreModel::getList() const
{
	return this->mList;
}

void StoreModel::setList(StoreList *value)
{
	beginResetModel();
	
	if(mList)
		mList->disconnect(this);
	
	mList = value;
	
	if(mList)
	{
		connect(this->mList, &StoreList::preItemAppended, this, [=]()
		{
			const int index = mList->items().size();
			beginInsertRows(QModelIndex(), index, index);
		});
		
		connect(this->mList, &StoreList::postItemAppended, this, [=]()
		{
			endInsertRows();
		});
		
		connect(this->mList, &StoreList::preItemRemoved, this, [=](int index)
		{
			beginRemoveRows(QModelIndex(), index, index);
		});
		
		connect(this->mList, &StoreList::postItemRemoved, this, [=]()
		{
			endRemoveRows();
		});
		
		connect(this->mList, &StoreList::updateModel, this, [=](int index, QVector<int> roles)
		{
			emit this->dataChanged(this->index(index), this->index(index), roles);
		});
		
		connect(this->mList, &StoreList::preListChanged, this, [=]()
		{
			beginResetModel();
		});
		
		connect(this->mList, &StoreList::postListChanged, this, [=]()
		{
			endResetModel();
		});
	}
	
	endResetModel();
}
