#pragma once

#include <QDomDocument>
#include <QJsonDocument>
#include <QObject>
#include <QUrl>
#include <QVariantMap>

#include "../utils/bae.h"
#include "enums.h"

#define ERROR(request)                                                                                                                                                                                                                         \
{                                                                                                                                                                                                                                          \
    emit this->error(request);                                                                                                                                                                                                             \
    return;                                                                                                                                                                                                                                \
    }

class Service : public QObject
{
    Q_OBJECT

private:
public:
    explicit Service(QObject *parent = nullptr);

protected:
    PULPO::REQUEST request; // the main request. the track info, the ontology and info type
    PULPO::SCOPE scope; // what ontology and info can the service parse
    PULPO::RESPONSES responses;

    void parse(const QByteArray &array);

    virtual void set(const PULPO::REQUEST &request);
    virtual void parseArtist(const QByteArray &array)
    {
        Q_UNUSED(array)
    }
    virtual void parseAlbum(const QByteArray &array)
    {
        Q_UNUSED(array)
    }
    virtual void parseTrack(const QByteArray &array)
    {
        Q_UNUSED(array)
    }

    void retrieve(const QString &url, const QMap<QString, QString> &headers = {});

    static PULPO::RESPONSE packResponse(const PULPO::ONTOLOGY &ontology, const PULPO::INFO &info, const PULPO::VALUE &value);

    bool scopePass();

Q_SIGNALS:
    void arrayReady(QByteArray array);
    void responseReady(PULPO::REQUEST request, PULPO::RESPONSES responses);
    void error(PULPO::REQUEST request);
};
