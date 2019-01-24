#ifndef PLAYER_H
#define PLAYER_H

#include <QObject>
#include <QtMultimedia/QMediaPlayer>
#include <QTimer>
#include <QBuffer>

class Player : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString url READ getUrl WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(int volume READ getVolume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(int position READ getPosition WRITE setPosition NOTIFY positionChanged)
    Q_PROPERTY(Player::STATE state READ getState NOTIFY stateChanged)
    Q_PROPERTY(int duration READ getDuration NOTIFY durationChanged)
    Q_PROPERTY(bool playing READ getPlaying WRITE setPlaying NOTIFY playingChanged)
    Q_PROPERTY(bool finished READ getFinished NOTIFY finishedChanged)

public:

    enum STATE : uint_fast8_t
    {
        PLAYING,
        PAUSED,
        STOPED,
        ERROR
    };Q_ENUM(STATE)

    explicit Player(QObject *parent = nullptr);

    void playBuffer();
    Q_INVOKABLE void appendBuffe(QByteArray &array);
    void setUrl(const QString &value);
    QString getUrl() const;

    void setVolume(const int &value);
    int getVolume() const;

    int getDuration() const;

    void setPosition(const int &value);
    int getPosition() const;

    Player::STATE getState() const;

    void setPlaying(const bool &value);
    bool getPlaying() const;

    bool getFinished();

private:
    QMediaPlayer *player;
    QTimer *updater;
    int amountBuffers =0;
    void update();
    QBuffer *buffer;
    QByteArray array;

    QString url;
    int volume = 100;
    int position = 0;
    Player::STATE state = STATE::STOPED;
    bool playing = false;
    bool finished = false;

    bool play();
    void pause();

    void emitState();

signals:
    void durationChanged();
    void urlChanged();
    void volumeChanged();
    void positionChanged();
    void stateChanged();
    void playingChanged();
    void finishedChanged();

public slots:
    QString transformTime(const int &pos);
    void playRemote(const QString &url);
    void stop();

};

#endif // PLAYER_H
