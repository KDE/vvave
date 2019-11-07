#include "tagsmodel.h"
#include "tagslist.h"

#include "tag.h"

TagsModel::TagsModel(QObject *parent)
    : QAbstractListModel(parent),
      mList(nullptr)
{}

int TagsModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || !mList)
        return 0;

    return mList->items().size();
}

QVariant TagsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !mList)
        return QVariant();

    return this->mList->items().at(index.row())[static_cast<TAG::KEYS>(role)];
}

bool TagsModel::setData(const QModelIndex &index, const QVariant &value, int role)
{

    return false;
}

Qt::ItemFlags TagsModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable; // FIXME: Implement me!
}

QHash<int, QByteArray> TagsModel::roleNames() const
{
    QHash<int, QByteArray> names;

        for(auto key : TAG::KEYMAP.keys())
            names[key] = QString(TAG::KEYMAP[key]).toUtf8();

        return names;
}

TagsList *TagsModel::getList() const
{
    return this->mList;
}

void TagsModel::setList(TagsList *value)
{
    beginResetModel();

    if(mList)
        mList->disconnect(this);

    mList = value;

    if(mList)
    {
        connect(this->mList, &TagsList::preItemAppended, this, [=]()
        {
            const int index = mList->items().size();
            beginInsertRows(QModelIndex(), index, index);
        });

        connect(this->mList, &TagsList::postItemAppended, this, [=]()
        {
            endInsertRows();
        });

        connect(this->mList, &TagsList::preItemRemoved, this, [=](int index)
        {
            beginRemoveRows(QModelIndex(), index, index);
        });

        connect(this->mList, &TagsList::postItemRemoved, this, [=]()
        {
            endRemoveRows();
        });

        connect(this->mList, &TagsList::updateModel, this, [=](int index, QVector<int> roles)
        {
            emit this->dataChanged(this->index(index), this->index(index), roles);
        });

        connect(this->mList, &TagsList::preListChanged, this, [=]()
        {
            beginResetModel();
        });

        connect(this->mList, &TagsList::postListChanged, this, [=]()
        {
            endResetModel();
        });
    }

    endResetModel();
}
