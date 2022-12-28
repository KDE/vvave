#ifndef PLAYLIST_H
#define PLAYLIST_H

#include <QObject>
#include <QVariant>
#include <QQmlParserStatus>

class TracksModel;
class Player;
class Playlist : public QObject, public QQmlParserStatus
{
    Q_INTERFACES(QQmlParserStatus)
    Q_OBJECT

    Q_PROPERTY(TracksModel *model WRITE setModel READ model NOTIFY modelChanged)
    Q_PROPERTY(QVariantMap currentTrack READ currentTrack NOTIFY currentTrackChanged FINAL)
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY currentIndexChanged FINAL)

    Q_PROPERTY(PlayMode playMode READ playMode WRITE setPlayMode NOTIFY playModeChanged)

    Q_PROPERTY(RepeatMode repeatMode READ repeatMode WRITE setRepeatMode NOTIFY repeatModeChanged)

    Q_PROPERTY(bool autoResume READ autoResume WRITE setAutoResume NOTIFY autoResumeChanged)

public:
    enum PlayMode : uint_fast8_t
    {
        Normal,
        Shuffle,
    };
    Q_ENUM(PlayMode)

    enum RepeatMode : uint_fast8_t
    {
        NoRepeat,
        RepeatOnce,
        Repeat
    };
    Q_ENUM(RepeatMode)

    explicit Playlist(QObject *parent = nullptr);
    TracksModel *model() const;

    QVariantMap currentTrack() const;

    int currentIndex() const;
    PlayMode playMode() const;

    RepeatMode repeatMode() const;

    bool autoResume() const;

private:
    TracksModel *m_model = nullptr;
    Player *m_player = nullptr;
    QVariantMap m_currentTrack;

    int m_currentIndex = -1;
    QVector<QPair<int, QVariantMap>> m_history; //history of track and its index

    PlayMode m_playMode = PlayMode::Normal;
    RepeatMode m_repeatMode = RepeatMode::NoRepeat;
    uint m_repeatFlag = 0;

    bool m_autoResume;

    void appendHistory();

public slots:
    bool canGoNext() const;
    bool canGoPrevious() const;
    bool canPlay() const;

    void next();
    void previous();
    void nextShuffle();
    void play(int index);
    void clear();

    void save();
    void loadLastPlaylist();

    void append(const QVariantMap &track);
    void insert(const QStringList &urls, const int &index);

    void setModel(TracksModel *model);
    void setCurrentIndex(int index);
    void changeCurrentIndex(int index);

    void setPlayMode(Playlist::PlayMode playMode);

    void move(int from, int to);
    void remove(int index);

    void setRepeatMode(RepeatMode repeatMode);

    void setAutoResume(bool autoResume);

signals:
    void canPlayChanged();
    void modelChanged(TracksModel *model);
    void currentTrackChanged(QVariantMap currentTrack);
    void currentIndexChanged(int currentIndex);
    void missingFile(QVariantMap track);
    void playModeChanged(Playlist::PlayMode playMode);
    void repeatModeChanged(RepeatMode repeatMode);
    void autoResumeChanged(bool autoResume);

    // QQmlParserStatus interface
public:
    void classBegin() override final;
    void componentComplete() override final;
};

#endif // PLAYLIST_H
