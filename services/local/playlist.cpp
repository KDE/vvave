#include "playlist.h"
#include "../../models/tracks/tracksmodel.h"

#include <QRandomGenerator>

#ifdef STATIC_MAUIKIT
#include "utils.h"
#else
#include <MauiKit/utils.h>
#endif

Playlist::Playlist(QObject * parent) :  QObject(parent)
,m_shuffle(UTIL::loadSettings("SHUFFLE","PLAYBACK", false).toBool())
{}

TracksModel * Playlist::model() const
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

bool Playlist::shuffle() const
{
	return m_shuffle;
}

bool Playlist::canGoNext() const
{
	if(!m_model)
	{
		return false;
	}

	return m_model->getCount() > 0;
}

bool Playlist::canGoPrevious() const
{
	if(!m_model)
	{
		return false;
	}

	return m_model->getCount() > 0;
}

bool Playlist::canPlay() const
{
	if(!m_model)
	{
		return false;
	}

	return m_model->getCount() > 0;
}

void Playlist::next()
{
	if(!m_model)
	{
		return;
	}

	m_previousIndex = m_currentIndex;

	if(m_shuffle)
	{
		nextShuffle ();
	}else
	{
		setCurrentIndex ( m_currentIndex+1 >= m_model->getCount() ? 0 : m_currentIndex+1);
	}
}

void Playlist::previous()
{
	if(!m_model)
	{
		return;
	}

	auto previous = m_currentIndex-1 >= 0 ? m_currentIndex-1 : m_model->getCount ()-1;
	m_previousIndex = m_currentIndex;
	setCurrentIndex (previous);
}

void Playlist::nextShuffle()
{
	if(!m_model)
	{
		return;
	}

	auto count= m_model->getCount();
	setCurrentIndex (std::rand() % count);
}

void Playlist::clear()
{
	if(!m_model)
	{
		return;
	}

	m_model->clear ();
	setCurrentIndex (-1);
}

void Playlist::save()
{
	if(!m_model)
	{
		return;
	}

	QStringList urls;
	const auto count = std::min(m_model->getCount(), 15);

	for(int i=0 ; i < count; i++)
	{
		auto url = m_model->get(i).value("url").toString();
		urls << url;
	}

	UTIL::saveSettings("LASTPLAYLIST", urls, "PLAYLIST");
	UTIL::saveSettings("PLAYLIST_POS", m_currentIndex, "MAINWINDOW");
}

void Playlist::append(const QUrl & url)//TODO
{
	if(!m_model)
	{
		return;
	}

	//	m_model->append ()
}

void Playlist::append(const QVariantMap & track)
{
	if(!m_model)
	{
		return;
	}

	m_model->append(track);
}

void Playlist::setModel(TracksModel * model)
{
	if (m_model == model)
		return;

	m_model->disconnect ();

	m_model = model;

	connect(m_model, &TracksModel::countChanged, this, &Playlist::canPlayChanged);

	emit modelChanged(m_model);
}

void Playlist::setCurrentIndex(int index)
{
	if(!m_model)
	{
		return;
	}

	if (m_currentIndex == index)
		return;

	m_currentIndex = index;
	emit currentIndexChanged(m_currentIndex);

	const auto count = m_model->getCount();
	if(count > 0 && index < count && index >= 0)
	{
		m_currentTrack = m_model->get (m_currentIndex);
	}else
	{
		m_currentTrack = QVariantMap();
	}

	emit currentTrackChanged (m_currentTrack);
}

void Playlist::setShuffle(bool shuffle)
{
	if (m_shuffle == shuffle)
		return;

	m_shuffle = shuffle;
	UTIL::saveSettings("SHUFFLE", m_shuffle, "PLAYBACK");
	emit shuffleChanged(m_shuffle);
}


