#include "player.h"

#include <QTime>
#include <MauiKit3/Accounts/mauiaccounts.h>
#include "powermanagementinterface.h"
#include <QMediaPlayerControl>
#include <QMediaService>

Player::Player(QObject *parent)
    : QObject(parent)
    , player(new QMediaPlayer(this))
    , m_power(new PowerManagementInterface(this))
{
    this->player->setVolume(this->volume);
    connect(this->player, &QMediaPlayer::stateChanged, [this](QMediaPlayer::State state) {
        auto position = this->player->position();
        // QMediaPlayer::duration() "may not be available when initial playback begins". Sometimes rapidly changing tracks causes position == 0.0 == duration, so check for that.
        if (state == QMediaPlayer::StoppedState && position > 0.0 && position == this->player->duration()) {
            Q_EMIT this->finished();
        }

        Q_EMIT this->stateChanged();
        Q_EMIT this->playingChanged();
    });

    connect(this->player, &QMediaPlayer::positionChanged, this, &Player::posChanged);
    connect(this->player, &QMediaPlayer::durationChanged, this, &Player::durationChanged);
}

inline QNetworkRequest getOcsRequest(const QNetworkRequest &request)
{
    qDebug() << Q_FUNC_INFO;

    qDebug() << "FORMING THE REQUEST" << request.url();

    // Read raw headers out of the provided request
    QMap<QByteArray, QByteArray> rawHeaders;
    const auto headerList =request.rawHeaderList();

    for (const QByteArray &headerKey : headerList) {
        rawHeaders.insert(headerKey, request.rawHeader(headerKey));
    }

    const auto account = FMH::toModel(MauiAccounts::instance()->getCurrentAccount());
    //    const auto account = FMH::MODEL();

    const QString concatenated = QString("%1:%2").arg(account[FMH::MODEL_KEY::USER], account[FMH::MODEL_KEY::PASSWORD]);
    const QByteArray data = concatenated.toLocal8Bit().toBase64();
    const QString headerData = "Basic " + data;

    // Construct new QNetworkRequest with prepared header values
    QNetworkRequest newRequest(request);

    newRequest.setRawHeader(QString("Authorization").toLocal8Bit(), headerData.toLocal8Bit());
    newRequest.setRawHeader(QByteArrayLiteral("OCS-APIREQUEST"), QByteArrayLiteral("true"));
    newRequest.setRawHeader(QByteArrayLiteral("Cache-Control"), QByteArrayLiteral("public"));
    newRequest.setRawHeader(QByteArrayLiteral("Content-Description"), QByteArrayLiteral("File Transfer"));

    newRequest.setHeader(QNetworkRequest::ContentTypeHeader, "audio/mpeg");
    newRequest.setAttribute(QNetworkRequest::CacheSaveControlAttribute, true);
    newRequest.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferCache);

    qDebug() << "headers" << newRequest.rawHeaderList() << newRequest.url();

    return newRequest;
}

bool Player::play() const
{
    if (this->url.isEmpty())
        return false;
    this->player->play();
    this->m_power->setPreventSleep(true);
    return true;
}

void Player::pause() const
{
    if (this->player->isAvailable())
        this->player->pause();
    this->m_power->setPreventSleep(false);

}

void Player::stop()
{
    if (this->player->isAvailable()) {
        this->player->stop();
        this->url = QString();
        this->player->setMedia(QMediaContent());
    }

    this->m_power->setPreventSleep(false);
}

QString Player::transformTime(const int &value)
{
    QString tStr;
    if (value) {
        QTime time((value / 3600) % 60, (value / 60) % 60, value % 60, (value * 1000) % 1000);
        QString format = "mm:ss";
        if (value > 3600)
            format = "hh:mm:ss";
        tStr = time.toString(format);
    }

    return tStr.isEmpty() ? "00:00" : tStr;
}

void Player::setUrl(const QUrl &value)
{
    //    if(value == this->url)
    //        return;

    this->url = value;
    Q_EMIT this->urlChanged();

    const auto media = this->url.isLocalFile() ? QMediaContent(this->url) : QMediaContent(getOcsRequest(QNetworkRequest(this->url)));

    this->player->setMedia(media);
}

QUrl Player::getUrl() const
{
    return this->url;
}

void Player::setVolume(const int &value)
{
    if (value == this->volume)
        return;

    this->volume = value;
    this->player->setVolume(volume);
    Q_EMIT this->volumeChanged();
}

int Player::getVolume() const
{
    return this->volume;
}

int Player::getDuration() const
{
    return static_cast<int>(this->player->duration());
}

QMediaPlayer::State Player::getState() const
{
    return this->player->state();
}

bool Player::getPlaying() const
{
    return player->state() == QMediaPlayer::State::PlayingState;
}

void Player::setPos(const int &value)
{
    this->player->setPosition(value);
}

int Player::getPos() const
{
    return this->player->position();
}
