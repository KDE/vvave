#pragma once

#include <QObject>
#include <QtMultimedia/QMediaPlayer>
#include <QtMultimedia/QAudioOutput>

class PowerManagementInterface;
class Player : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ getUrl WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(int volume READ getVolume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(QMediaPlayer::PlaybackState state READ getState NOTIFY stateChanged)
    Q_PROPERTY(int duration READ getDuration NOTIFY durationChanged)
    Q_PROPERTY(bool playing READ getPlaying NOTIFY playingChanged)
    Q_PROPERTY(int pos READ getPos WRITE setPos NOTIFY posChanged)

public:
    explicit Player(QObject *parent = nullptr);

    void setUrl(const QUrl &value);
    QUrl getUrl() const;

    void setVolume(const int &value);
    int getVolume() const;

    int getDuration() const;

    QMediaPlayer::PlaybackState getState() const;
    bool getPlaying() const;

    int getPos() const;
    void setPos(const int &value);

public Q_SLOTS:
    static QString transformTime(const int &value);
    void stop();

    bool play() const;
    void pause() const;

private:
    QMediaPlayer *player;
    QAudioOutput *m_output;
    QUrl url;
    PowerManagementInterface *m_power;
    int amountBuffers = 0;
    int volume = 100;

Q_SIGNALS:
    void durationChanged();
    void urlChanged();
    void volumeChanged();
    void posChanged();
    void stateChanged();
    void playingChanged();
    void finished();
};
