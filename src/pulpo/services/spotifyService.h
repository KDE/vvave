#pragma once

#include "../service.h"
#include <QObject>

class spotify : public Service
{
    Q_OBJECT

private:
    inline static const QString API = "https://api.spotify.com/v1/search?q=";
    inline static const QString CLIENT_ID = "a49552c9276745f5b4752250c2d84367";
    inline static const QString CLIENT_SECRET = "b3f1562559f3405dbcde4a435f50089a";

public:
    explicit spotify();
    void set(const PULPO::REQUEST &request) override final;

protected:
    virtual void parseArtist(const QByteArray &array) override final;
    virtual void parseAlbum(const QByteArray &array) override final;
    virtual void parseTrack(const QByteArray &array) override final;
};

