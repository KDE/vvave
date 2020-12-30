#ifndef NOTIFY_H
#define NOTIFY_H

#include <QByteArray>
#include <QObject>

#include <klocalizedstring.h>
#include <knotification.h>
#include <knotifyconfig.h>

#include "../utils/bae.h"
#include <QDebug>
#include <QMap>
#include <QPixmap>
#include <QStandardPaths>

class Notify : public QObject
{
    Q_OBJECT

public:
    explicit Notify(QObject *parent = nullptr);
    ~Notify();
    void notifySong(const FMH::MODEL &);
    void notify(const QString &title, const QString &body);

private:
    FMH::MODEL track;

signals:
    void babeSong();
    void skipSong();

public slots:
    void actions(uint id);
};

#endif // NOTIFY_H
