#ifndef PLAYER_H
#define PLAYER_H

#include <QObject>
#include <QtMultimedia/QMediaPlayer>
#include <QTimer>

class Player : public QObject
{
    Q_OBJECT
public:
    explicit Player(QObject *parent = nullptr);

    Q_INVOKABLE void source(const QString &url);
    Q_INVOKABLE bool play();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void seek(const int &pos);
    Q_INVOKABLE int duration();
    Q_INVOKABLE bool isPaused();
    Q_INVOKABLE QString transformTime(const int &pos);

private:
    QMediaPlayer *player;
    QTimer *updater;
    void update();

    QString sourceurl;

signals:
    void pos(int pos);
    void finished();
    void timing(QString time);
    void durationChanged(QString time);
    void isPlaying(bool playing);

public slots:
};

#endif // PLAYER_H
