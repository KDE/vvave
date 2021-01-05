#ifndef GENIUSSERVICE_H
#define GENIUSSERVICE_H

#include "../pulpo.h"
#include <QObject>

class genius : public Pulpo
{
    Q_OBJECT

private:
    const QString KEY = "Bearer UARllo5N6CLQYVlqFwolyauSlYiyU_07YTg7HGHkWRbimN4GWPJehPP5fzu9lXeO";
    const QString API = "https://api.genius.com";

    QString getID(const QString &url);
    bool getAlbumInfo(const QByteArray &array);
    bool extractLyrics(const QByteArray &array);

public:
    explicit genius(const FMH::MODEL &song);
    virtual bool setUpService(const PULPO::ONTOLOGY &ontology, const PULPO::INFO &info);

protected:
    virtual bool parseArtist();
    virtual bool parseAlbum()
    {
        return false;
    }
    virtual bool parseTrack();
};

#endif // GENIUSSERVICE_H
