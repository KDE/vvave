#ifndef SYNCINGLIST_H
#define SYNCINGLIST_H

#include <QObject>
#include "fmh.h"

class FM;
class SyncingList : public QObject
{
    Q_OBJECT
 
public:    
    explicit SyncingList(QObject *parent = nullptr);
    FMH::MODEL_LIST items() const;

private:
    FMH::MODEL_LIST list;
	void setList();
	FM *fm;
   
protected:

signals:
    void preItemAppended();
    void postItemAppended();
    void preItemRemoved(int index);
    void postItemRemoved();
    void updateModel(int index, QVector<int> roles);
    void preListChanged();
    void postListChanged();

public slots:    
    QVariantMap get(const int &index) const;
	void insert(const QVariantMap &data);
	void removeAccount(const QString &server, const QString &user);
	void removeAccountAndFiles(const QString &server, const QString &user);
	void refresh();

};

#endif // SYNCINGLIST_H
