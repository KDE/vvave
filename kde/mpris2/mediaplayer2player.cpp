/***************************************************************************
   SPDX-FileCopyrightText: 2014 (c) Sujith Haridasan <sujith.haridasan@kdemail.net>
   SPDX-FileCopyrightText: 2014 (c) Ashish Madeti <ashishmadeti@gmail.com>
   SPDX-FileCopyrightText: 2016 (c) Matthieu Gallien <matthieu_gallien@yahoo.fr>

   SPDX-License-Identifier: GPL-3.0-or-later
 ***************************************************************************/

#include "mediaplayer2player.h"
#include "mpris2.h"

#include "../../services/local/player.h"
#include "../../services/local/playlist.h"

#include <QCryptographicHash>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QStringList>

static const double MAX_RATE = 1.0;
static const double MIN_RATE = 1.0;

MediaPlayer2Player::MediaPlayer2Player(Playlist *playListControler, Player *audioPlayer, bool showProgressOnTaskBar, QObject *parent)
    : QDBusAbstractAdaptor(parent)
    , m_playListControler(playListControler)
    , m_audioPlayer(audioPlayer)
    , mProgressIndicatorSignal(QDBusMessage::createSignal(QStringLiteral("/org/maui/vvave"), QStringLiteral("com.canonical.Unity.LauncherEntry"), QStringLiteral("Update")))
    , mShowProgressOnTaskBar(showProgressOnTaskBar)
{
    if (!m_playListControler) {
        return;
    }

    connect(m_playListControler, &Playlist::currentIndexChanged, this, &MediaPlayer2Player::playerSourceChanged, Qt::QueuedConnection);
    connect(m_playListControler, &Playlist::canPlayChanged, this, &MediaPlayer2Player::playControlEnabledChanged);
    connect(m_playListControler, &Playlist::canPlayChanged, this, &MediaPlayer2Player::skipBackwardControlEnabledChanged);
    connect(m_playListControler, &Playlist::canPlayChanged, this, &MediaPlayer2Player::skipForwardControlEnabledChanged);
    connect(m_audioPlayer, &Player::stateChanged, this, &MediaPlayer2Player::playerPlaybackStateChanged);
    connect(m_audioPlayer, &Player::stateChanged, this, &MediaPlayer2Player::playerIsSeekableChanged);
    connect(m_audioPlayer, &Player::posChanged, this, &MediaPlayer2Player::audioPositionChanged);
    connect(m_audioPlayer, &Player::durationChanged, this, &MediaPlayer2Player::audioDurationChanged);
    connect(m_audioPlayer, &Player::volumeChanged, this, &MediaPlayer2Player::playerVolumeChanged);

    m_volume = m_audioPlayer->getVolume() / 100;
    m_canPlay = m_playListControler->canPlay();
    signalPropertiesChange(QStringLiteral("Volume"), Volume());

    m_mediaPlayerPresent = 1;
}

MediaPlayer2Player::~MediaPlayer2Player() = default;

QString MediaPlayer2Player::PlaybackStatus() const
{
    QString result;

    if (!m_playListControler) {
        result = QStringLiteral("Stopped");
        return result;
    }

    if (m_audioPlayer->getState() == QMediaPlayer::StoppedState) {
        result = QStringLiteral("Stopped");
    } else if (m_audioPlayer->getState() == QMediaPlayer::PlayingState) {
        result = QStringLiteral("Playing");
    } else {
        result = QStringLiteral("Paused");
    }

    if (mShowProgressOnTaskBar) {
        QVariantMap parameters;

        if (m_audioPlayer->getState() == QMediaPlayer::StoppedState || m_audioPlayer->getDuration() == 0) {
            parameters.insert(QStringLiteral("progress-visible"), false);
            parameters.insert(QStringLiteral("progress"), 0);
        } else {
            parameters.insert(QStringLiteral("progress-visible"), true);
            parameters.insert(QStringLiteral("progress"), qRound(static_cast<double>(m_position / m_audioPlayer->getDuration())) / 1000.0);
        }

        mProgressIndicatorSignal.setArguments({QStringLiteral("application://org.maui.vvave.desktop"), parameters});

        QDBusConnection::sessionBus().send(mProgressIndicatorSignal);
    }

    return result;
}

bool MediaPlayer2Player::CanGoNext() const
{
    return m_canGoNext;
}

void MediaPlayer2Player::Next()
{
    emit next();

    if (m_playListControler) {
        m_playListControler->next();
    }
}

bool MediaPlayer2Player::CanGoPrevious() const
{
    return m_canGoPrevious;
}

void MediaPlayer2Player::Previous()
{
    emit previous();

    if (m_playListControler) {
        m_playListControler->previous();
    }
}

bool MediaPlayer2Player::CanPause() const
{
    return m_canPlay;
}

void MediaPlayer2Player::Pause()
{
    if (m_playListControler) {
        m_audioPlayer->pause();
    }
}

void MediaPlayer2Player::PlayPause()
{
    emit playPause();

    if (m_playListControler) {
        m_audioPlayer->pause();
    }
}

void MediaPlayer2Player::Stop()
{
    emit stop();

    if (m_playListControler) {
        m_audioPlayer->stop();
    }
}

bool MediaPlayer2Player::CanPlay() const
{
    return m_canPlay;
}

void MediaPlayer2Player::Play()
{
    if (m_playListControler) {
        m_audioPlayer->play();
    }
}

double MediaPlayer2Player::Volume() const
{
    return m_volume;
}

void MediaPlayer2Player::setVolume(double volume)
{
    m_volume = qBound(0.0, volume, 1.0);
    emit volumeChanged(m_volume);

    m_audioPlayer->setVolume(100 * m_volume);

    signalPropertiesChange(QStringLiteral("Volume"), Volume());
}

QVariantMap MediaPlayer2Player::Metadata() const
{
    return m_metadata;
}

qlonglong MediaPlayer2Player::Position() const
{
    return m_position;
}

void MediaPlayer2Player::setPropertyPosition(int newPositionInMs)
{
    m_position = qlonglong(newPositionInMs) * 1000;

    Q_EMIT Seeked(m_position);

    /* only sent new progress when it has advanced more than 1 %
     * to limit DBus traffic
     */
    const auto incrementalProgress = static_cast<double>(newPositionInMs - mPreviousProgressPosition) / m_audioPlayer->getDuration();
    if (mShowProgressOnTaskBar && (incrementalProgress > 0.01 || incrementalProgress < 0)) {
        mPreviousProgressPosition = newPositionInMs;
        QVariantMap parameters;
        parameters.insert(QStringLiteral("progress-visible"), true);
        parameters.insert(QStringLiteral("progress"), static_cast<double>(newPositionInMs) / m_audioPlayer->getDuration());

        mProgressIndicatorSignal.setArguments({QStringLiteral("application://org.maui.vvave.desktop"), parameters});

        QDBusConnection::sessionBus().send(mProgressIndicatorSignal);
    }
}

double MediaPlayer2Player::Rate() const
{
    return m_rate;
}

void MediaPlayer2Player::setRate(double newRate)
{
    if (newRate <= 0.0001 && newRate >= -0.0001) {
        Pause();
    } else {
        m_rate = qBound(MinimumRate(), newRate, MaximumRate());
        emit rateChanged(m_rate);

        signalPropertiesChange(QStringLiteral("Rate"), Rate());
    }
}

double MediaPlayer2Player::MinimumRate() const
{
    return MIN_RATE;
}

double MediaPlayer2Player::MaximumRate() const
{
    return MAX_RATE;
}

bool MediaPlayer2Player::CanSeek() const
{
    return m_playerIsSeekableChanged;
}

bool MediaPlayer2Player::CanControl() const
{
    return true;
}

void MediaPlayer2Player::Seek(qlonglong Offset)
{
    if (mediaPlayerPresent()) {
        auto offset = (m_position + Offset) / 1000;
        m_audioPlayer->setPos(int(offset));
    }
}

void MediaPlayer2Player::emitSeeked(int pos)
{
    emit Seeked(qlonglong(pos) * 1000);
}

void MediaPlayer2Player::SetPosition(const QDBusObjectPath &trackId, qlonglong pos)
{
    if (trackId.path() == m_currentTrackId) {
        m_audioPlayer->setPos(int(pos / 1000));
    }
}

void MediaPlayer2Player::OpenUri(const QString &uri)
{
    Q_UNUSED(uri);
}

void MediaPlayer2Player::playerSourceChanged()
{
    if (!m_playListControler) {
        return;
    }

    setCurrentTrack(m_playListControler->currentIndex());
}

void MediaPlayer2Player::playControlEnabledChanged()
{
    if (!m_playListControler) {
        return;
    }

    m_canPlay = m_playListControler->canPlay();

    signalPropertiesChange(QStringLiteral("CanPause"), CanPause());
    signalPropertiesChange(QStringLiteral("CanPlay"), CanPlay());

    emit canPauseChanged();
    emit canPlayChanged();
}

void MediaPlayer2Player::skipBackwardControlEnabledChanged()
{
    if (!m_playListControler) {
        return;
    }

    m_canGoPrevious = m_playListControler->canGoPrevious();

    signalPropertiesChange(QStringLiteral("CanGoPrevious"), CanGoPrevious());
    emit canGoPreviousChanged();
}

void MediaPlayer2Player::skipForwardControlEnabledChanged()
{
    if (!m_playListControler) {
        return;
    }

    m_canGoNext = m_playListControler->canGoNext();

    signalPropertiesChange(QStringLiteral("CanGoNext"), CanGoNext());
    emit canGoNextChanged();
}

void MediaPlayer2Player::playerPlaybackStateChanged()
{
    signalPropertiesChange(QStringLiteral("PlaybackStatus"), PlaybackStatus());
    emit playbackStatusChanged();

    playerIsSeekableChanged();
}

void MediaPlayer2Player::playerIsSeekableChanged()
{
    m_playerIsSeekableChanged = m_audioPlayer->getState() == QMediaPlayer::State::PausedState || m_audioPlayer->getState() == QMediaPlayer::State::PlayingState;

    signalPropertiesChange(QStringLiteral("CanSeek"), CanSeek());
    emit canSeekChanged();
}

void MediaPlayer2Player::audioPositionChanged()
{
    setPropertyPosition(static_cast<int>(m_audioPlayer->getPos()));
}

void MediaPlayer2Player::audioDurationChanged()
{
    m_metadata = getMetadataOfCurrentTrack();
    signalPropertiesChange(QStringLiteral("Metadata"), Metadata());

    skipBackwardControlEnabledChanged();
    skipForwardControlEnabledChanged();
    playerPlaybackStateChanged();
    playerIsSeekableChanged();
    setPropertyPosition(static_cast<int>(m_audioPlayer->getPos()));
}

void MediaPlayer2Player::playerVolumeChanged()
{
    setVolume(m_audioPlayer->getVolume() / 100.0);
}

int MediaPlayer2Player::currentTrack() const
{
    return m_playListControler->currentIndex();
}

void MediaPlayer2Player::setCurrentTrack(int newTrackPosition)
{
    m_currentTrack = m_playListControler->currentTrack().value("url").toString();
    m_currentTrackId = QDBusObjectPath(QLatin1String("/org/maui/vvave/playlist/") + QString::number(newTrackPosition)).path();

    emit currentTrackChanged();

    m_metadata = getMetadataOfCurrentTrack();
    signalPropertiesChange(QStringLiteral("Metadata"), Metadata());
}

QVariantMap MediaPlayer2Player::getMetadataOfCurrentTrack()
{
    auto result = QVariantMap();

    if (m_currentTrackId.isEmpty()) {
        return {};
    }

    result[QStringLiteral("mpris:trackid")] = QVariant::fromValue<QDBusObjectPath>(QDBusObjectPath(m_currentTrackId));
    result[QStringLiteral("mpris:length")] = qlonglong(m_audioPlayer->getDuration()) * 1000;
    // convert milli-seconds into micro-seconds

    auto track = m_playListControler->currentTrack();
    result[QStringLiteral("xesam:title")] = track["title"].toString();
    result[QStringLiteral("xesam:url")] = track["url"].toString();

    result[QStringLiteral("xesam:album")] = track["album"].toString();
    ;

    result[QStringLiteral("xesam:artist")] = QStringList{track["artist"].toString()};

    result[QStringLiteral("mpris:artUrl")] = track["artwork"].toString();

    return result;
}

int MediaPlayer2Player::mediaPlayerPresent() const
{
    return m_mediaPlayerPresent;
}

bool MediaPlayer2Player::showProgressOnTaskBar() const
{
    return mShowProgressOnTaskBar;
}

void MediaPlayer2Player::setShowProgressOnTaskBar(bool value)
{
    mShowProgressOnTaskBar = value;

    QVariantMap parameters;

    if (!mShowProgressOnTaskBar || m_audioPlayer->getState() == QMediaPlayer::StoppedState || m_audioPlayer->getDuration() == 0) {
        parameters.insert(QStringLiteral("progress-visible"), false);
        parameters.insert(QStringLiteral("progress"), 0);
    } else {
        parameters.insert(QStringLiteral("progress-visible"), true);
        parameters.insert(QStringLiteral("progress"), qRound(static_cast<double>(m_position / m_audioPlayer->getDuration())) / 1000.0);
    }

    mProgressIndicatorSignal.setArguments({QStringLiteral("application://org.maui.vvave.desktop"), parameters});

    QDBusConnection::sessionBus().send(mProgressIndicatorSignal);
}

void MediaPlayer2Player::setMediaPlayerPresent(int status)
{
    if (m_mediaPlayerPresent != status) {
        m_mediaPlayerPresent = status;
        emit mediaPlayerPresentChanged();

        signalPropertiesChange(QStringLiteral("CanGoNext"), CanGoNext());
        signalPropertiesChange(QStringLiteral("CanGoPrevious"), CanGoPrevious());
        signalPropertiesChange(QStringLiteral("CanPause"), CanPause());
        signalPropertiesChange(QStringLiteral("CanPlay"), CanPlay());
        emit canGoNextChanged();
        emit canGoPreviousChanged();
        emit canPauseChanged();
        emit canPlayChanged();
    }
}

void MediaPlayer2Player::signalPropertiesChange(const QString &property, const QVariant &value)
{
    QVariantMap properties;
    properties[property] = value;
    const int ifaceIndex = metaObject()->indexOfClassInfo("D-Bus Interface");
    QDBusMessage msg = QDBusMessage::createSignal(QStringLiteral("/org/mpris/MediaPlayer2"), QStringLiteral("org.freedesktop.DBus.Properties"), QStringLiteral("PropertiesChanged"));

    msg << QLatin1String(metaObject()->classInfo(ifaceIndex).value());
    msg << properties;
    msg << QStringList();

    QDBusConnection::sessionBus().send(msg);
}

#include "moc_mediaplayer2player.cpp"
