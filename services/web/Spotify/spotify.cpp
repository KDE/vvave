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
