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

    if(this->queue.size() > 1) return;

    if(this->go)
    {
        qDebug()<<"RUNNIGN QUERY ON CONTHREAD"<<this->queue.first()["TABLE"].toString();
        QMetaObject::invokeMethod(this, "set", Q_ARG(QString, this->queue.first()["TABLE"].toString()), Q_ARG(QVariantList, this->queue.first()["WHERES"].toList()));

    }else return;
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

void ConThread::setInterval(const uint &interval)
{
    this->interval = interval;
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

    this->queue.removeFirst();
    emit this->finished();

    if(!this->queue.isEmpty())
        this->set(this->queue.first()["TABLE"].toString(), this->queue.first()["WHERES"].toList());

}


