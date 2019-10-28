#ifndef NEXTMUSIC_H
#define NEXTMUSIC_H

#include <QObject>

class NextMusic : public QObject
{
    Q_OBJECT
public:
    explicit NextMusic(QObject *parent = nullptr);

signals:

public slots:
};

#endif // NEXTMUSIC_H
