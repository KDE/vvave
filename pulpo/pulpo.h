#ifndef PULPO_H
#define PULPO_H

#include <QPixmap>
#include <QList>
#include <QDebug>
#include <QImage>
#include <QtCore>
#include <QUrl>
#include <QObject>
#include <QVariantMap>

#include "../utils/bae.h"
#include "enums.h"

using namespace PULPO;

class Pulpo : public QObject
{
    Q_OBJECT

public:
    explicit Pulpo(QObject *parent = nullptr);
    ~Pulpo();

    void request(const PULPO::REQUEST &request);

private:
    void start();
    QList<SERVICES> services = {};

    PULPO::REQUEST req;

    void passSignal(const REQUEST &request, const RESPONSES &responses);

signals:
    void infoReady(PULPO::REQUEST request, PULPO::RESPONSES responses);
    void error();
    void finished();
};

#endif // ARTWORK_H
