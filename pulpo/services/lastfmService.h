#ifndef LASTFMSERVICE_H
#define LASTFMSERVICE_H

#include <QObject>
#include "../service.h"

class lastfm : public Service
{
    Q_OBJECT

private:

    const QString API = "http://ws.audioscrobbler.com/2.0/";
    const QString KEY = "&api_key=ba6f0bd3c887da9101c10a50cf2af133";

    void parseSimilar();

public:
    explicit lastfm();
    ~lastfm() override;

    void set(const PULPO::REQUEST &request) override final;

protected:
    virtual void parseArtist(const QByteArray &array) override final;
    virtual void parseAlbum(const QByteArray &array) override final;
//    virtual void parseTrack(const QByteArray &array);


    /*INTERNAL IMPLEMENTATION*/

};

#endif // LASTFM_H
