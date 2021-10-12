#include "playlist.h"
#include "../../models/tracks/tracksmodel.h"

#include <QRandomGenerator>
#include <QUrl>
#include <QDebug>
#include <MauiKit/Core/utils.h>

Playlist::Playlist(QObject *parent)
    : QObject(parent)
    , m_playMode(static_cast<Playlist::PlayMode>(UTIL::loadSettings("PLAYMODE", "PLAYBACK", 0).toUInt()))
{
}

TracksModel *Playlist::model() const
{
    return m_model;
}

QVariantMap Playlist::currentTrack() const
{
    return m_currentTrack;
}

int Playlist::currentIndex() const
{
    return m_currentIndex;
}

Playlist::PlayMode Playlist::playMode() const
{
    return m_playMode;
}

void Playlist::loadLastPlaylist()
{
    if (!m_model)
    {
        return;
    }

    QStringList urls = UTIL::loadSettings("LASTPLAYLIST", "PLAYLIST", QStringList()).toStringList();
//    int lastIndex =   UTIL::loadSettings("PLAYLIST_POS", "MAINWINDOW", -1).toInt();
    for (const auto &url : urls)
    {
       m_model->appendUrl(QUrl::fromUserInput(url));
    }

//    this->setCurrentIndex(lastIndex);
}

bool Playlist::canGoNext() const
{
    if (!m_model)
    {
        return false;
    }

    return m_model->getCount() > 0;
}

bool Playlist::canGoPrevious() const
{
    if (!m_model)
    {
        return false;
    }

    return m_model->getCount() > 0;
}

bool Playlist::canPlay() const
{
    if (!m_model)
    {
        return false;
    }

    return m_model->getCount() > 0;
}

void Playlist::next()
{
    if (!m_model)
    {
        return;
    }

    m_previousIndex = m_currentIndex;

    switch(m_playMode)
    {
    case PlayMode::Normal:
    {
        setCurrentIndex(m_currentIndex + 1 >= m_model->getCount() ? 0 : m_currentIndex + 1);
        break;
    }

    case PlayMode::Shuffle:
    {
        nextShuffle();
        break;
    }

    case PlayMode::Repeat:
    {
        setCurrentIndex(m_currentIndex);
        break;
    }
    }
}

void Playlist::previous()
{
    if (!m_model)
    {
        return;
    }

    auto previous = m_currentIndex - 1 >= 0 ? m_currentIndex - 1 : m_model->getCount() - 1;
    m_previousIndex = m_currentIndex;
    setCurrentIndex(previous);
}

void Playlist::nextShuffle()
{
    if (!m_model)
    {
        return;
    }

    auto count = m_model->getCount();
    setCurrentIndex(std::rand() % count);
}

void Playlist::clear()
{
    if (!m_model)
    {
        return;
    }

    m_model->clear();
    setCurrentIndex(-1);
}

void Playlist::save()
{
    if (!m_model)
    {
        return;
    }

    QStringList urls;
    const auto count = std::min(m_model->getCount(), 15);

    for (int i = 0; i < count; i++) {
        auto url = m_model->get(i).value("url").toString();
        urls << url;
    }

    UTIL::saveSettings("LASTPLAYLIST", urls, "PLAYLIST");
    UTIL::saveSettings("PLAYLIST_POS", m_currentIndex, "MAINWINDOW");
}

void Playlist::append(const QVariantMap &track)
{
    if (!m_model)
    {
        return;
    }

    m_model->append(track);
}

void Playlist::setModel(TracksModel *model)
{
    if (m_model == model)
        return;

    m_model->disconnect();
    m_model = model;

    connect(m_model, &TracksModel::countChanged, this, &Playlist::canPlayChanged);

    this->loadLastPlaylist();
    emit modelChanged(m_model);
}

void Playlist::setCurrentIndex(int index)
{
    if (!m_model)
    {
        return;
    }

    const auto count = m_model->getCount();
    if (count > 0 && index < count && index >= 0)
    {
        m_currentIndex = index;
        m_currentTrack = m_model->get(m_currentIndex);
        auto url = m_currentTrack["url"].toUrl();
        if (!FMH::fileExists(url) && url.isLocalFile())
        {
            emit this->missingFile(m_currentTrack);
        }

    } else
    {
        m_currentIndex = -1;
        m_currentTrack = QVariantMap();
    }

    emit currentIndexChanged(m_currentIndex);
    emit currentTrackChanged(m_currentTrack);
}

void Playlist::setPlayMode(Playlist::PlayMode playMode)
{
    if (m_playMode == playMode)
        return;

    m_playMode = playMode;
    UTIL::saveSettings("PLAYMODE", m_playMode, "PLAYBACK");
    emit playModeChanged(m_playMode);
}

