#ifndef BASEMODEL_H
#define BASEMODEL_H

#include <QAbstractListModel>
#include <QList>

class BaseList;
class BaseModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(BaseList *list READ getList WRITE setList)

public:
    explicit BaseModel(QObject *parent = nullptr);

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    // Editable:
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    Qt::ItemFlags flags(const QModelIndex& index) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

    BaseList* getList() const;
    void setList(BaseList *value);

private:
    BaseList *mList;
signals:
    void listChanged();

public slots:
    QVariantMap get(const int &index) const;
    void clear();
};

#endif // NOTESMODEL_H
