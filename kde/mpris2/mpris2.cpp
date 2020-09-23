/***************************************************************************
   SPDX-FileCopyrightText: 2014 (c) Sujith Haridasan <sujith.haridasan@kdemail.net>
   SPDX-FileCopyrightText: 2014 (c) Ashish Madeti <ashishmadeti@gmail.com>
   SPDX-FileCopyrightText: 2016 (c) Matthieu Gallien <matthieu_gallien@yahoo.fr>

   SPDX-License-Identifier: GPL-3.0-or-later
 ***************************************************************************/

#include "mpris2.h"
#include "mediaplayer2.h"
#include "mediaplayer2player.h"
#include "../../services/local/player.h"
#include "../../services/local/playlist.h"
#include <QDBusConnection>

#if defined Q_OS_WIN
#include <Windows.h>
#else
#include <unistd.h>
#endif

Mpris2::Mpris2(QObject* parent)
	: QObject(parent)
{}

void Mpris2::initDBusService()
{
	QString mspris2Name(QStringLiteral("org.mpris.MediaPlayer2.") + m_playerName);

	bool success = QDBusConnection::sessionBus().registerService(mspris2Name);

	// If the above failed, it's likely because we're not the first instance
	// or the name is already taken. In that event the MPRIS2 spec wants the
	// following:
	if (!success) {
#if defined Q_OS_WIN
		success = QDBusConnection::sessionBus().registerService(mspris2Name + QLatin1String(".instance") + QString::number(GetCurrentProcessId()));
#else
		success = QDBusConnection::sessionBus().registerService(mspris2Name + QLatin1String(".instance") + QString::number(getpid()));
#endif
	}

	if (success) {
		m_mp2 = std::make_unique<MediaPlayer2>(this);
		m_mp2p = std::make_unique<MediaPlayer2Player>(m_playListModel, m_audioPlayer, mShowProgressOnTaskBar, this);

		QDBusConnection::sessionBus().registerObject(QStringLiteral("/org/mpris/MediaPlayer2"), this, QDBusConnection::ExportAdaptors);

		connect(m_mp2.get(), &MediaPlayer2::raisePlayer, this, &Mpris2::raisePlayer);
	}
}

Mpris2::~Mpris2()
= default;

QString Mpris2::playerName() const
{
	return m_playerName;
}

Playlist * Mpris2::playListModel() const
{
	return m_playListModel;
}

Player * Mpris2::audioPlayer() const
{
	return m_audioPlayer;
}

bool Mpris2::showProgressOnTaskBar() const
{
	return mShowProgressOnTaskBar;
}

void Mpris2::setPlayerName(const QString &playerName)
{
	if (m_playerName == playerName) {
		return;
	}

	m_playerName = playerName;

	if (m_playListModel && m_audioPlayer && m_audioPlayer && !m_playerName.isEmpty()) {
		if (!m_mp2) {
			initDBusService();
		}
	}

	emit playerNameChanged();
}

void Mpris2::setPlayListModel(Playlist * playListModel)
{
	if (m_playListModel == playListModel) {
		return;
	}

	m_playListModel = playListModel;

	if (m_playListModel && m_audioPlayer && m_audioPlayer && !m_playerName.isEmpty()) {
		if (!m_mp2) {
			initDBusService();
		}
	}

	emit playListModelChanged();
}


void Mpris2::setAudioPlayer(Player * audioPlayer)
{
	if (m_audioPlayer == audioPlayer)
		return;

	m_audioPlayer = audioPlayer;

	if (m_playListModel && m_audioPlayer && m_audioPlayer && !m_playerName.isEmpty()) {
		if (!m_mp2) {
			initDBusService();
		}
	}

	emit audioPlayerChanged();
}

void Mpris2::setShowProgressOnTaskBar(bool value)
{
	m_mp2p->setShowProgressOnTaskBar(value);
	mShowProgressOnTaskBar = value;
	Q_EMIT showProgressOnTaskBarChanged();
}

#include "moc_mpris2.cpp"
