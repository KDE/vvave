#include "conthread.h"
#include <QMap>
#include <QList>

ConThread::ConThread() : CollectionDB(nullptr)
{
    this->moveToThread(&t);
    this->t.start();
}

ConThread::~ConThread()
{
    this->stop();
}

void ConThread::start(QString table, QVariantList wheres)
{
    if(!this->go) this->go = true;

    this->queue.append({{QString ("TABLE"), table}, {QString ("WHERES"), wheres}});

    qDebug()<<"NOW ON THREAD<<"<< queue;

    if(this->queue.size() > 1) return;

    while(!this->queue.isEmpty())
    {
        if(this->go)
        {
            qDebug()<<"RUNNIGN QUERY ON CONTHREAD"<<this->queue.first()["TABLE"].toString();
            QMetaObject::invokeMethod(this, "set", Q_ARG(QString, this->queue.first()["TABLE"].toString()), Q_ARG(QVariantList, this->queue.first()["WHERES"].toList()));
            qDebug()<<"FINISHED SET ON QUEUE CONTHREAD"<< this->queue.first()["TABLE"].toString();
            this->queue.removeFirst();
            qDebug()<<this->queue.size();
        }else return;
    }

    qDebug()<<"FINISHED SET ON CONTHREAD TOTALLY";

}

void ConThread::stop()
{
    this->go = false;
    this->t.quit();
    this->t.wait();
}

void ConThread::pause()
{
    this->go = false;
}

bool ConThread::isRunning()
{
    return this->go;
}

void ConThread::setInterval()
{

}

void ConThread::get(QString query)
{
    auto data = getDBDataQML(query);
    emit this->dataReady(data);
}

void ConThread::set(QString tableName, QVariantList wheres)
{
    for(auto variant : wheres)
    {
        this->insert(tableName, QVariantMap(variant.toMap()));
        this->t.msleep(this->interval);
    }
}


