#pragma once

#include <QObject>

#include <MauiKit4/Audio/mediaplayer.h>

class PowerManagementInterface;
class Player : public MediaPlayer
{
    Q_OBJECT
    Q_PROPERTY(bool playing READ getPlaying NOTIFY playingChanged)

public:
    explicit Player(QObject *parent = nullptr);
    
    bool getPlaying() const;

public Q_SLOTS:
    static QString transformTime(int value);
   
private:   
    PowerManagementInterface *m_power;
    int amountBuffers = 0;

Q_SIGNALS:
    void playingChanged();   
};
