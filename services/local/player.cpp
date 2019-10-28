#include "player.h"
#include "../../utils/bae.h"


Player::Player(QObject *parent) : QObject(parent),
    player(new QMediaPlayer(this)),
    updater(new QTimer(this))
{
    this->buffer = new QBuffer(this->player);

//    connect(this->player, &QMediaPlayer::durationChanged, this, [&](qint64 dur)
//    {
//        emit this->durationChanged(/*BAE::transformTime(dur/1000)*/);
//    });

    this->player->setVolume(this->volume);
    connect(this->updater, &QTimer::timeout, this, &Player::update);
}

inline QNetworkRequest getOcsRequest(const QNetworkRequest& request)
{
    qDebug() << Q_FUNC_INFO;

    // Read raw headers out of the provided request
    QMap<QByteArray, QByteArray> rawHeaders;
    for (const QByteArray& headerKey : request.rawHeaderList()) {
        rawHeaders.insert(headerKey, request.rawHeader(headerKey));
    }


    const QString concatenated =  "mauitest:mauitest";
    const QByteArray data = concatenated.toLocal8Bit().toBase64();
    const QString headerData = "Basic " + data;


    // Construct new QNetworkRequest with prepared header values
    QNetworkRequest newRequest(request);

    newRequest.setRawHeader(QString("Authorization").toLocal8Bit(), headerData.toLocal8Bit());
    newRequest.setRawHeader(QByteArrayLiteral("OCS-APIREQUEST"), QByteArrayLiteral("true"));


    qDebug() << "headers" << newRequest.rawHeaderList() << newRequest.url();

    return newRequest;
}

bool Player::play() const
{
    if(this->url.isEmpty()) return false;

    if(!updater->isActive())
        this->updater->start(500);

    this->player->play();

    return true;
}

void Player::pause() const
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
    return BAE::transformTime(pos);
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

void Player::setUrl(const QUrl &value)
{
    if(value == this->url)
        return;

    this->url = value;
    emit this->urlChanged();

    this->pos = 0;
    emit this->posChanged();

    const auto media = this->url.isLocalFile() ? QMediaContent(this->url) : QMediaContent(getOcsRequest(QNetworkRequest(this->url)));

    this->player->setMedia(media);
    this->emitState();
}

QUrl Player::getUrl() const
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
    this->player->setPosition(this->player->duration() / 1000 * this->pos);
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
