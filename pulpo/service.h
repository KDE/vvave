#ifndef SERVICE_H
#define SERVICE_H

#include <QObject>
#include <QUrl>
#include <QDomDocument>
#include <QJsonDocument>
#include <QVariantMap>

#include "enums.h"
#include "../utils/bae.h"

class Service : public QObject
{
    Q_OBJECT

private:

public:
    explicit Service(QObject *parent = nullptr);

protected:
    PULPO::REQUEST request; //the main request. the track info, the ontology and info type
    PULPO::SCOPE scope; //what ontology and info can the service parse
    PULPO::RESPONSES responses;

    void parse(const QByteArray &array);

    virtual void set(const PULPO::REQUEST &request);
    virtual void parseArtist(const QByteArray &array) {}
    virtual void parseAlbum(const QByteArray &array) {}
    virtual void parseTrack(const QByteArray &array) {}

    void retrieve(const QString &url, const QMap<QString, QString> &headers = {});

    static PULPO::RESPONSE packResponse(const PULPO::ONTOLOGY &ontology, const PULPO::INFO &info, const PULPO::VALUE &value);

signals:
    void arrayReady(QByteArray array);
    void responseReady(PULPO::REQUEST request, PULPO::RESPONSES responses);

public slots:
};

#endif // SERVICE_H
