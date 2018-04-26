#include "spotify.h"

#include <QObject>
#include <QtNetwork>
#include <QUrl>
#include <QNetworkAccessManager>
#include <QDomDocument>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QVariantMap>

using namespace BAE;


Spotify::Spotify(QObject *parent) : QObject(parent)
{

}

Spotify::~Spotify()
{

}

void Spotify::setCode(const QString &code)
{
    if(code.isEmpty())
        this->code = BAE::loadSettings("SPOTIFY_CODE", "VVAVE", "").toString();
    else
    {
        this->code = code;
        BAE::saveSettings("SPOTIFY_CODE", code, "VVAVE");
    }
}

QString Spotify::getCode()
{
    return BAE::loadSettings("SPOTIFY_CODE", "VVAVE", "").toString();
}
