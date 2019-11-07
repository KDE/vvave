#ifndef TAGSMODEL_H
#define TAGSMODEL_H

#include <QAbstractListModel>
#include <QList>

class TagsList;
class TagsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(TagsList *list READ getList WRITE setList)

public:
    explicit TagsModel(QObject *parent = nullptr);

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    // Editable:
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    Qt::ItemFlags flags(const QModelIndex& index) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

    TagsList* getList() const;
    void setList(TagsList *value);

private:
    TagsList *mList;
signals:
    void listChanged();
};

#endif // SYNCINGMODEL_H
