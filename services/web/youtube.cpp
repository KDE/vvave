/*
   Babe - tiny music player
   Copyright (C) 2017  Camilo Higuita
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software Foundation,
   Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

   */


#include "youtube.h"

#include <QtNetwork>
#include <QUrl>
#include <QNetworkAccessManager>
#include <QDomDocument>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QVariantMap>

#include "../../pulpo/pulpo.h"
#include "../../utils/bae.h"

using namespace BAE;

YouTube::YouTube(QObject *parent) : QObject(parent)
{

}

YouTube::~YouTube(){}

bool YouTube::getQuery(const QString &query, const int &limit)
{
    QUrl encodedQuery(query);
    encodedQuery.toEncoded(QUrl::FullyEncoded);

    auto url = this->API[METHOD::SEARCH];

    url.append("q="+encodedQuery.toString());
    url.append(QString("&maxResults=%1&part=snippet").arg(QString::number(limit)));
    url.append("&key="+ BAE::loadSettings("YOUTUBEKEY", "BABE", this->KEY).toString());

    qDebug()<< url;
    auto array = this->startConnection(url);

    if(array.isEmpty()) return false;

    return this->packQueryResults(array);
}

bool YouTube::packQueryResults(const QByteArray &array)
{
    QJsonParseError jsonParseError;
    QJsonDocument jsonResponse = QJsonDocument::fromJson(static_cast<QString>(array).toUtf8(), &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError)
        return false;

    if (!jsonResponse.isObject())
        return false;

    QJsonObject mainJsonObject(jsonResponse.object());
    auto data = mainJsonObject.toVariantMap();
    auto items = data.value("items").toList();

    if(items.isEmpty()) return false;

    QVariantList res;

    for(auto item : items)
    {
        auto itemMap = item.toMap().value("id").toMap();
        auto id = itemMap.value("videoId").toString();
        auto url = "https://www.youtube.com/embed/"+id;

        auto snippet = item.toMap().value("snippet").toMap();

        auto comment = snippet.value("description").toString();
        auto title = snippet.value("title").toString();
        auto artwork = snippet.value("thumbnails").toMap().value("high").toMap().value("url").toString();
        auto artist = BAE::SLANG[W::UNKNOWN];
        auto album = BAE::SLANG[W::UNKNOWN];

        if(title.contains("-"))
        {
            auto data = title.split("-");
            if(data.size() > 1)
            {
                artist = data[0].trimmed();
                title = data[1].trimmed();
            }

        }

        if(!id.isEmpty())
        {
            qDebug()<<url<<artwork;

            QVariantMap map = {
                {BAE::KEYMAP[BAE::KEY::ID], id},
                {BAE::KEYMAP[BAE::KEY::URL], url},
                {BAE::KEYMAP[BAE::KEY::TITLE], title},
                {BAE::KEYMAP[BAE::KEY::ALBUM], album},
                {BAE::KEYMAP[BAE::KEY::ARTIST], artist},
                {BAE::KEYMAP[BAE::KEY::ARTWORK], artwork},
                {BAE::KEYMAP[BAE::KEY::COMMENT], comment},
                {BAE::KEYMAP[BAE::KEY::BABE], "0"},
                {BAE::KEYMAP[BAE::KEY::STARS], "0"},
                {BAE::KEYMAP[BAE::KEY::ART], ""},
                {BAE::KEYMAP[BAE::KEY::TRACK], "0"}
            };

            res << map;
        }
    }

    emit this->queryResultsReady(res);
    return true;
}

void YouTube::getId(const QString &results)
{

}

void YouTube::getUrl(const QString &id)
{

}

QString YouTube::getKey() const
{
    return this->KEY;
}


QByteArray YouTube::startConnection(const QString &url, const QMap<QString, QString> &headers)
{
    if(!url.isEmpty())
    {
        QUrl mURL(url);
        QNetworkAccessManager manager;
        QNetworkRequest request (mURL);

        if(!headers.isEmpty())
            for(auto key: headers.keys())
                request.setRawHeader(key.toLocal8Bit(), headers[key].toLocal8Bit());

        QNetworkReply *reply =  manager.get(request);
        QEventLoop loop;
        connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);

        connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), &loop,
                SLOT(quit()));

        loop.exec();

        if(reply->error())
        {
            qDebug() << reply->error();
            return QByteArray();
        }

        if(reply->bytesAvailable())
        {
            auto data = reply->readAll();
            reply->deleteLater();

            return data;
        }
    }

    return QByteArray();
}

QUrl YouTube::fromUserInput(const QString &userInput)
{
    if (userInput.isEmpty())
        return QUrl::fromUserInput("about:blank");
    const QUrl result = QUrl::fromUserInput(userInput);
    return result.isValid() ? result : QUrl::fromUserInput("about:blank");
}

