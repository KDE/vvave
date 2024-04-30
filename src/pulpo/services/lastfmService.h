#pragma once

#include "../service.h"
#include <QObject>

class lastfm : public Service
{
    Q_OBJECT

private:
    inline static const QString API = "http://ws.audioscrobbler.com/2.0/";
    inline static const QString KEY = "&api_key=ba6f0bd3c887da9101c10a50cf2af133";

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
