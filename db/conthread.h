#ifndef CONTHREAD_H
#define CONTHREAD_H

#include <QObject>
#include <QThread>

class CollectionDB;
class ConThread : public QObject
{
    Q_OBJECT
public:
    explicit ConThread();
    ~ConThread();
    void start(QString table, QVariantList wheres);
    void stop();
    void pause();
    bool isRunning();
    void setInterval(const uint &interval);

    void get(QString query);

private:
    QThread t;
    CollectionDB *db;
    uint interval = 0;
    bool go = false;
    QList<QMap<QString, QVariant>> queue;

signals:
    void finished();
    void dataReady(QVariantList);

public slots:
    void set(QString tableName, QVariantList wheres);

};

#endif // CONTHREAD_H
