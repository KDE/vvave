#ifndef KDECONNECT_H
#define KDECONNECT_H

#include <QObject>
#include <QMap>
#include <QString>
#include <QVariantList>

class KdeConnect : public QObject
{
    Q_OBJECT
public:
    explicit KdeConnect(QObject *parent = nullptr);
    static QVariantList getDevices();
    static bool sendToDevice(const QString &device, const QString &id, const QString &url);
signals:

public slots:
};

#endif // KDECONNECT_H
