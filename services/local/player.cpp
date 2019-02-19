#include "player.h"
#include "../../utils/bae.h"


Player::Player(QObject *parent) : QObject(parent)
{
    this->player = new QMediaPlayer(this);
    this->buffer = new QBuffer(this->player);

    connect(this->player, &QMediaPlayer::durationChanged, this, [&](qint64 dur)
    {
        emit this->durationChanged(/*BAE::transformTime(dur/1000)*/);
    });

    this->player->setVolume(this->volume);

    this->updater = new QTimer(this);
    connect(this->updater, &QTimer::timeout, this, &Player::update);
}

bool Player::play()
{
    if(this->url.isEmpty()) return false;

    if(!updater->isActive())
        this->updater->start(500);

    this->player->play();

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
        this->url = QString();
        this->player->setMedia(QMediaContent());
    }

    this->playing = false;
    emit this->playingChanged();

    this->updater->stop();

    this->emitState();
}

void Player::emitState()
{
    switch(this->player->state())
    {
    case QMediaPlayer::PlayingState:
        this->state = Player::STATE::PLAYING;
        break;
    case QMediaPlayer::PausedState:
        this->state = Player::STATE::PAUSED;
        break;
    case QMediaPlayer::StoppedState:
        this->state = Player::STATE::STOPED;
        break;
    }

    emit this->stateChanged();
}

QString Player::transformTime(const int &pos)
{
    auto time =  BAE::transformTime(pos);
    return time;
}
void Player::appendBuffe(QByteArray &array)
{
    qDebug()<<"APENDING TO BUFFER"<< array << this->array;
    this->array.append(array, array.length());
    amountBuffers++;

    if(amountBuffers == 1)
        playBuffer();
}

void Player::playRemote(const QString &url)
{
    qDebug()<<"Trying to play remote"<<url;
    this->url = url;
    this->player->setMedia(QUrl::fromUserInput(url));
    this->play();
}

void Player::setUrl(const QString &value)
{
    if(value == this->url)
        return;

    this->url = value;
    emit this->urlChanged();

    this->pos = 0;
    emit this->posChanged();

    auto media = QMediaContent(QUrl::fromLocalFile(this->url));
    this->player->setMedia(media);
    this->emitState();
}

QString Player::getUrl() const
{
    return this->url;
}

void Player::setVolume(const int &value)
{
    if(value == this->volume)
        return;

    this->volume = value;
    this->player->setVolume(volume);
    emit this->volumeChanged();
}

int Player::getVolume() const
{
    return this->volume;
}

int Player::getDuration() const
{
    return static_cast<int>(this->player->duration());
}


Player::STATE Player::getState() const
{
    return this->state;
}

void Player::setPlaying(const bool &value)
{
    this->playing = value;

    if(this->playing)
        this->play();
    else this->pause();

    emit this->playingChanged();
    this->emitState();
}

bool Player::getPlaying() const
{
    return this->playing;
}

bool Player::getFinished()
{
    return this->finished;
}

void Player::setPos(const int &value)
{
    this->pos = value;
    this->player->setPosition( this->player->duration() / 1000 * this->pos);
    this->emitState();
    this->posChanged();
}

int Player::getPos() const
{
    return this->pos;
}

void Player::playBuffer()
{
    buffer->setData(array);
    buffer->open(QIODevice::ReadOnly);
    if(!buffer->isReadable()) qDebug()<<"Cannot read buffer";
    player->setMedia(QMediaContent(),buffer);
    this->url = "buffer";
    this->play();
    this->emitState();
}

void Player::update()
{
    if(this->player->isAvailable())
    {
        this->pos = static_cast<int>(static_cast<double>(this->player->position())/this->player->duration()*1000);;
        emit this->posChanged();
    }

    if(this->player->state() == QMediaPlayer::StoppedState && this->updater->isActive() && this->player->position() == this->player->duration())
    {
        this->finished = true;
        emit this->finishedChanged();
    }

    this->emitState();
}
