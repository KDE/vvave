#ifndef NOTIFY_H
#define NOTIFY_H

#include <QObject>
#include <QByteArray>

#include <klocalizedstring.h>
#include <knotifyconfig.h>
#include <knotification.h>

#include <QStandardPaths>
#include <QPixmap>
#include <QDebug>
#include <QMap>
#include "../utils/bae.h"

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
