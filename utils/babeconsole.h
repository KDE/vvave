#ifndef BABECONSOLE_H
#define BABECONSOLE_H

#include <QObject>
#include <iostream>

using namespace std;
class BabeConsole : public QObject
{
    Q_OBJECT
public:
    explicit BabeConsole(QObject *parent = nullptr);
    void msg(const QString &msg);

signals:
    void debug(QString msg);

public slots:
};



#endif // BABECONSOLE_H
