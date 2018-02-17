#ifndef BABECONSOLE_H
#define BABECONSOLE_H

#include <QObject>
#include "singleton.h"

class BabeConsole : public QObject
{
    Q_OBJECT
public:
    explicit BabeConsole(QObject *parent = nullptr);
    static void msg(const QString &msg);

signals:
    void debug(QString msg);

public slots:
};

typedef Singleton<BabeConsole> bDebug;

#endif // BABECONSOLE_H
