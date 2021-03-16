#ifndef PLAYLIST_H
#define PLAYLIST_H

#include <QObject>
#include <QVariant>

class TracksModel;
class Player;
class Playlist : public QObject
{
    Q_OBJECT

    Q_PROPERTY(TracksModel *model WRITE setModel READ model NOTIFY modelChanged)
    Q_PROPERTY(QVariantMap currentTrack READ currentTrack NOTIFY currentTrackChanged FINAL)
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)

    Q_PROPERTY(PlayMode playMode READ playMode WRITE setPlayMode NOTIFY playModeChanged)

public:

    enum PlayMode : uint_fast8_t
    {
        Normal,
        Shuffle,
        Repeat
    };
    Q_ENUM(PlayMode)

    explicit Playlist(QObject *parent = nullptr);
    TracksModel *model() const;

    QVariantMap currentTrack() const;

    int currentIndex() const;


    PlayMode playMode() const;

private:
    TracksModel *m_model = nullptr;
    Player *m_player = nullptr;
    QVariantMap m_currentTrack;
    int m_currentIndex = -1;
    int m_previousIndex = -1;

    PlayMode m_playMode = PlayMode::Normal;

public slots:

    bool canGoNext() const;
    bool canGoPrevious() const;
    bool canPlay() const;

    void next();
    void previous();
    void nextShuffle();
    void clear();
    void save();
    void append(const QUrl &url);
    void append(const QVariantMap &track);

    void setModel(TracksModel *model);
    void setCurrentIndex(int index);

    void setPlayMode(PlayMode playMode);

signals:
    void canPlayChanged();
    void modelChanged(TracksModel *model);
    void currentTrackChanged(QVariantMap currentTrack);
    void currentIndexChanged(int currentIndex);
    void missingFile(QVariantMap track);
    void playModeChanged(PlayMode playMode);
};

#endif // PLAYLIST_H
