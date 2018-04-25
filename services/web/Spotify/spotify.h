#ifndef SPOTIFY_H
#define SPOTIFY_H

#include <QObject>

class spotify : public QObject
{
    Q_OBJECT
public:
    explicit spotify(QObject *parent = nullptr);

signals:

public slots:
};

#endif // SPOTIFY_H