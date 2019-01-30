#include "basemodel.h"
#include "baselist.h"

BaseModel::BaseModel(QObject *parent)
    : QAbstractListModel(parent),
      mList(nullptr)
{}

int BaseModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || !mList)
        return 0;

    return mList->items().size();
}

QVariant BaseModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !mList)
        return QVariant();

    return mList->items().at(index.row())[static_cast<FMH::MODEL_KEY>(role)];
}

bool BaseModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!mList)
        return false;

    if (mList->update(index.row(), value, role))
    {
        emit dataChanged(index, index, QVector<int>() << role);
        return true;
    }
    return false;
}

Qt::ItemFlags BaseModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable; // FIXME: Implement me!
}

QHash<int, QByteArray> BaseModel::roleNames() const
{
    QHash<int, QByteArray> names;
    for(auto key : FMH::MODEL_NAME.keys())
            names[key] = QString(FMH::MODEL_NAME[key]).toUtf8();
    return names;
}

BaseList *BaseModel::getList() const
{
    return this->mList;
}

void BaseModel::setList(BaseList *value)
{
    beginResetModel();

    if(mList)
        mList->disconnect(this);

    mList = value;

    if(mList)
    {
        connect(this->mList, &BaseList::preItemAppended, this, [=]()
        {
            const int index = mList->items().size();
            beginInsertRows(QModelIndex(), index, index);
        });

        connect(this->mList, &BaseList::postItemAppended, this, [=]()
        {
            endInsertRows();
        });

        connect(this->mList, &BaseList::preItemAppendedAt, this, [=](int index)
        {
            beginInsertRows(QModelIndex(), index, index);
        });

        connect(this->mList, &BaseList::preItemRemoved, this, [=](int index)
        {
            beginRemoveRows(QModelIndex(), index, index);
        });

        connect(this->mList, &BaseList::postItemRemoved, this, [=]()
        {
            endRemoveRows();
        });

        connect(this->mList, &BaseList::updateModel, this, [=](int index, QVector<int> roles)
        {
            emit this->dataChanged(this->index(index), this->index(index), roles);
        });

        connect(this->mList, &BaseList::preListChanged, this, [=]()
        {
            beginResetModel();
        });

        connect(this->mList, &BaseList::postListChanged, this, [=]()
        {
            endResetModel();
        });
    }

    endResetModel();
}

QVariantMap BaseModel::get(const int &index) const
{
   return this->mList->get(index);
}
