#ifndef PLAYER_H
#define PLAYER_H

#include <QObject>
#include <QtMultimedia/QMediaPlayer>
#include <QTimer>
#include <QBuffer>

class Player : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ getUrl WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(int volume READ getVolume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(Player::STATE state READ getState NOTIFY stateChanged)
    Q_PROPERTY(int duration READ getDuration NOTIFY durationChanged)
    Q_PROPERTY(bool playing READ getPlaying WRITE setPlaying NOTIFY playingChanged)
    Q_PROPERTY(bool finished READ getFinished NOTIFY finishedChanged)
    Q_PROPERTY(int pos READ getPos WRITE setPos NOTIFY posChanged)

public:

    enum STATE : uint_fast8_t
    {
        PLAYING,
        PAUSED,
        STOPED
    };Q_ENUM(STATE)

    explicit Player(QObject *parent = nullptr);

    void setUrl(const QUrl &value);
    QUrl getUrl() const;

    void setVolume(const int &value);
    int getVolume() const;

    int getDuration() const;

    Player::STATE getState() const;

    void setPlaying(const bool &value);
    bool getPlaying() const;

    bool getFinished();

    int getPos() const;
    void setPos(const int &value);

private:
    QMediaPlayer *player;
    QTimer *updater;
    int amountBuffers = 0;
    int pos = 0;
    int volume = 100;

    QUrl url;
    Player::STATE state = STATE::STOPED;
    bool playing = false;
    bool finished = false;

    bool play() const;
    void pause() const;
    void update();

    void emitState();

signals:
    void durationChanged();
    void urlChanged();
    void volumeChanged();

    void stateChanged();
    void playingChanged();
    void finishedChanged();

    void posChanged();

public slots:
    static QString transformTime(const int &pos);
    void stop();

};

#endif // PLAYER_H
