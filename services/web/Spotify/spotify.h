#ifndef SPOTIFY_H
#define SPOTIFY_H

#include <QObject>
#include <QWidget>
#include <QMap>

#include "../../../pulpo/pulpo.h"
#include "../../../utils/bae.h"


class Spotify : public QObject
{
    Q_OBJECT
public:
    explicit Spotify(QObject *parent = nullptr);

signals:
public slots:
};

#endif // SPOTIFY_H
