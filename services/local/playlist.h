#ifndef PLAYLIST_H
#define PLAYLIST_H

#include <QObject>
#include <QVariant>

class TracksModel;
class Player;
class Playlist : public QObject
{
        Q_OBJECT

        Q_PROPERTY (TracksModel *model WRITE setModel READ model NOTIFY modelChanged)
        Q_PROPERTY (QVariantMap currentTrack READ currentTrack NOTIFY currentTrackChanged FINAL )
        Q_PROPERTY (int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged )

        Q_PROPERTY (bool shuffle READ shuffle WRITE setShuffle NOTIFY shuffleChanged)

    public:
        explicit Playlist(QObject *parent = nullptr );
        TracksModel * model() const;

        QVariantMap currentTrack() const;

        int currentIndex() const;

        bool shuffle() const;

    private:
        TracksModel *m_model = nullptr;
        Player *m_player = nullptr;
        QVariantMap m_currentTrack;
        int m_currentIndex = -1;
        int m_previousIndex = -1;
        bool m_shuffle = false;

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

        void setModel(TracksModel * model);
        void setCurrentIndex(int index);

        void setShuffle(bool shuffle);

    signals:
        void canPlayChanged();
        void modelChanged(TracksModel * model);
        void currentTrackChanged(QVariantMap currentTrack);
        void currentIndexChanged(int currentIndex);
        void shuffleChanged(bool shuffle);
        void missingFile(QVariantMap track);
};

#endif // PLAYLIST_H
