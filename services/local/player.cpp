#include "player.h"
#include "../../utils/bae.h"


Player::Player(QObject *parent) : QObject(parent)
{
    this->player = new QMediaPlayer(this);

    connect(player, &QMediaPlayer::durationChanged, this, [&](qint64 dur)
    {
        emit this->durationChanged(BAE::transformTime(dur/1000));
    });

    this->player->setVolume(100);

    this->updater = new QTimer(this);
    connect(this->updater, &QTimer::timeout, this, &Player::update);
}

void Player::source(const QString &url)
{
    this->sourceurl = url;
    auto media = QMediaContent(QUrl::fromLocalFile(this->sourceurl));
    qDebug()<<this->player->mediaStatus();

    this->player->setMedia(media);
    qDebug()<<this->player->mediaStatus();

}

bool Player::play()
{
    if(sourceurl.isEmpty()) return false;

    if(!updater->isActive())
        this->updater->start(150);

    if(this->player->isAvailable())
        this->player->play();
    else return false;

    return true;
}

void Player::pause()
{
    if(this->player->isAvailable())
        this->player->pause();
}

void Player::stop()
{
    if(this->player->isAvailable())
    {
        this->player->stop();
        this->sourceurl = QString();
        this->player->setMedia(QMediaContent());
    }

    emit this->isPlaying(false);

        this->updater->stop();
}

void Player::seek(const int &pos)
{
    this->player->setPosition(pos);
}

int Player::duration()
{
    if(this->sourceurl.isEmpty()) return 0;

    return static_cast<int>(this->player->duration());
}

bool Player::isPaused()
{
    return !(this->player->state() == QMediaPlayer::PlayingState);
}

QString Player::transformTime(const int &pos)
{
    auto time =  BAE::transformTime(pos);
    return time;
}

void Player::update()
{
    if(this->player->isAvailable())
    {
        emit this->pos(static_cast<int>(static_cast<double>(this->player->position())/this->player->duration()*1000));
        emit this->timing(BAE::transformTime(player->position()/1000));
    }

    emit this->isPlaying(this->player->state() == QMediaPlayer::PlayingState ? true : false);
    if(this->player->state() == QMediaPlayer::StoppedState && this->updater->isActive())
        emit this->finished();

}
