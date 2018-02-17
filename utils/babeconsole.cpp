#include "babeconsole.h"
#include <QDebug>

BabeConsole::BabeConsole(QObject *parent) : QObject(parent)
{

}

void BabeConsole::msg(const QString &msg)
{
//    emit debug(msg);
    bDebug::Instance()->debug(msg);
    qDebug()<<msg;
}

