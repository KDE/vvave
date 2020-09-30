/***************************************************************************
   SPDX-FileCopyrightText: 2014 (c) Sujith Haridasan <sujith.haridasan@kdemail.net>
   SPDX-FileCopyrightText: 2014 (c) Ashish Madeti <ashishmadeti@gmail.com>
   SPDX-FileCopyrightText: 2016 (c) Matthieu Gallien <matthieu_gallien@yahoo.fr>

   SPDX-License-Identifier: GPL-3.0-or-later
 ***************************************************************************/

#ifndef MEDIACENTER_MPRIS2_H
#define MEDIACENTER_MPRIS2_H

#include <QObject>
#include <QSharedPointer>
#include <memory>

class MediaPlayer2Player;
class MediaPlayer2;

class Player;
class Playlist;

class Mpris2 : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString playerName
               READ playerName
               WRITE setPlayerName
               NOTIFY playerNameChanged)

    Q_PROPERTY(Playlist* playListModel
               READ playListModel
               WRITE setPlayListModel
               NOTIFY playListModelChanged)

    Q_PROPERTY(Player* audioPlayer
               READ audioPlayer
               WRITE setAudioPlayer
               NOTIFY audioPlayerChanged)

    Q_PROPERTY(bool showProgressOnTaskBar
               READ showProgressOnTaskBar
               WRITE setShowProgressOnTaskBar
               NOTIFY showProgressOnTaskBarChanged)

public:
    explicit Mpris2(QObject* parent = nullptr);
    ~Mpris2() override;

    QString playerName() const;

    Playlist* playListModel() const;

    Player* audioPlayer() const;

    bool showProgressOnTaskBar() const;

public Q_SLOTS:

    void setPlayerName(const QString &playerName);

    void setPlayListModel(Playlist* playListModel);

    void setAudioPlayer(Player* audioPlayer);

    void setShowProgressOnTaskBar(bool value);

Q_SIGNALS:
    void raisePlayer();

    void playerNameChanged();

    void playListModelChanged();

    void audioPlayerChanged();

    void showProgressOnTaskBarChanged();

private:

    void initDBusService();

#if defined Q_OS_LINUX && !defined Q_OS_ANDROID
    std::unique_ptr<MediaPlayer2> m_mp2;
    std::unique_ptr<MediaPlayer2Player> m_mp2p;
#endif

    QString m_playerName;
    Playlist* m_playListModel = nullptr;
    Player* m_audioPlayer = nullptr;
    bool mShowProgressOnTaskBar = true;
};

#endif //MEDIACENTER_MPRIS2_H
