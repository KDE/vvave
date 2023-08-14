#include "playlist.h"
#include "../../models/tracks/tracksmodel.h"

// #include <QRandomGenerator>
#include <QUrl>
#include <QDebug>
#include <MauiKit3/Core/utils.h>

#include <random>

Playlist::Playlist(QObject *parent)
    : QObject(parent)
    , m_playMode(static_cast<Playlist::PlayMode>(UTIL::loadSettings("PLAYMODE", "PLAYBACK", 0).toUInt()))
    ,m_autoResume(UTIL::loadSettings("autoResume", "Settings", -1).toBool())
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

Playlist::RepeatMode Playlist::repeatMode() const
{
    return m_repeatMode;
}

bool Playlist::autoResume() const
{
    return m_autoResume;
}

void Playlist::loadLastPlaylist()
{
    if (!m_model)
    {
        return;
    }

    QStringList urls = UTIL::loadSettings("LASTPLAYLIST", "PLAYLIST", QStringList()).toStringList();
    int lastIndex =   UTIL::loadSettings("PLAYLIST_POS", "MAINWINDOW", -1).toInt();
    for (const auto &url : urls)
    {
        m_model->appendUrl(QUrl::fromUserInput(url));
    }

    this->setCurrentIndex(lastIndex);
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

    switch(m_repeatMode)
    {

    case RepeatMode::Repeat:
    {
        setCurrentIndex(m_currentIndex);
        return;
    }

    case RepeatMode::RepeatOnce:
    {
        if(m_repeatFlag == 0)
        {
            m_repeatFlag = 1;
            setCurrentIndex(m_currentIndex);
            return;
        }else
        {
            m_repeatFlag = 0;
        }
        break;
    }
    default:
    case RepeatMode::NoRepeat: break;
    }

    switch(m_playMode)
    {
    case PlayMode::Normal:
    case PlayMode::Shuffle:
    {
        setCurrentIndex(m_currentIndex + 1 >= m_model->getCount() ? 0 : m_currentIndex + 1);
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

    if(!canGoPrevious())
        return;

    int previous = m_currentIndex - 1 >= 0 ? m_currentIndex - 1 : m_model->getCount() - 1;

    setCurrentIndex(previous);
}

void Playlist::play(int index)
{
    setCurrentIndex(index);
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
    const auto count = m_model->getCount();

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

void Playlist::insert(const QStringList &urls, const int &index)
{
    if (!m_model)
    {
        return;
    }

    if(!m_model->insertUrls(urls, index))
    {
        return;
    }

    if(index <= m_currentIndex)
    {
        changeCurrentIndex(m_currentIndex+urls.count());
        return;
    }
}

void Playlist::setModel(TracksModel *model)
{
    if (m_model == model)
        return;

    m_model->disconnect();
    m_model = model;

    connect(m_model, &TracksModel::countChanged, this, &Playlist::canPlayChanged);
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

void Playlist::changeCurrentIndex(int index)
{
    if (!m_model)
    {
        return;
    }

    const auto count = m_model->getCount();
    if (count > 0 && index < count && index >= 0)
    {
        m_currentIndex = index;
    } else
    {
        return;
    }

    emit currentIndexChanged(m_currentIndex);
}

void Playlist::setPlayMode(Playlist::PlayMode playMode)
{
    if (m_playMode == playMode)
        return;

    m_playMode = playMode;
    UTIL::saveSettings("PLAYMODE", m_playMode, "PLAYBACK");

    if (playMode == Playlist::PlayMode::Shuffle)
    {
        this->shuffleRange(0, m_model->getCount());
    }

    emit playModeChanged(m_playMode);
}

void Playlist::shuffleRange(int start, int stop)
{
    int len = stop - start;

    std::vector<int> shuffled_offsets = {};
    shuffled_offsets.reserve(len);
    for (int i = 0; i < len; i++) {
        shuffled_offsets.push_back(i);
    }
    std::random_device rd;
    std::mt19937 g{rd()};
    // This isn't really a great randomness source:
    // https://stackoverflow.com/questions/45069219/how-to-succinctly-portably-and-thoroughly-seed-the-mt19937-prng
    // https://stackoverflow.com/questions/18880654/why-do-i-get-the-same-sequence-for-every-run-with-stdrandom-device-with-mingw
    // https://en.cppreference.com/w/cpp/numeric/random/random_device
    // But at least in recent versions of most compilers, it should generate a new sequence each time:
    // https://gcc.gnu.org/bugzilla/show_bug.cgi?id=85494
    std::shuffle(
        shuffled_offsets.begin(),
        shuffled_offsets.end(),
        g
    );

    std::vector<QVariantMap> shuffled_tracks = {};
    int new_index = -1;

    for (int i = 0; i < len; i++) {
        int remap_i = start + shuffled_offsets[i];
        shuffled_tracks.push_back(m_model->get(remap_i));
        if (remap_i == currentIndex())
        {
            new_index = start + i;
        }
    }

    int i = start;
    for (auto track: shuffled_tracks) {
        m_model->update(track, i++);
    }

    if (new_index != -1)
    {
        changeCurrentIndex(new_index);
    }
}

void Playlist::move(int from, int to)
{
    if(!m_model)
    {
        return;
    }

    m_model->move(from, to);

    qDebug() << "changing current track index" << from << to << m_currentIndex;

    if(from == m_currentIndex)
    {
        changeCurrentIndex(to);
        return;
    }

    if(to <= m_currentIndex && from > m_currentIndex)
    {
        changeCurrentIndex(m_currentIndex+1);
        return;
    }

    if(from <= m_currentIndex && to > m_currentIndex)
    {
        changeCurrentIndex(m_currentIndex-1);
        return;
    }
}

void Playlist::remove(int index)
{
    if(!m_model)
    {
        return;
    }

    m_model->remove(index);
    if(index <= m_currentIndex)
    {
        changeCurrentIndex(m_currentIndex-1);
    }
}

void Playlist::setRepeatMode(Playlist::RepeatMode repeatMode)
{
    if (m_repeatMode == repeatMode)
        return;

    m_repeatMode = repeatMode;
    emit repeatModeChanged(m_repeatMode);
}

void Playlist::setAutoResume(bool autoResume)
{
    if (m_autoResume == autoResume)
        return;

    m_autoResume = autoResume;
    UTIL::saveSettings("autoResume", m_autoResume, "Settings");
    emit autoResumeChanged(m_autoResume);
}

void Playlist::componentComplete()
{
    if(m_autoResume)
    {
        this->loadLastPlaylist();
    }
}

void Playlist::classBegin()
{

}
