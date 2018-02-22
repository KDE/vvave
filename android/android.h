#ifndef ANDROID_H
#define ANDROID_H

#include <QObject>

class Android : public QObject
{
    Q_OBJECT
public:
    explicit Android(QObject *parent = nullptr);

signals:

public slots:
};

#endif // ANDROID_H