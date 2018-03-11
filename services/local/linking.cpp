#include "linking.h"
#include "socket.h"
#include <QHostAddress>
#include <QNetworkInterface>
#include "../../utils/babeconsole.h"
#include <QSysInfo>
#include <QAbstractSocket>

QString Linking::stringify(const QVariantMap &map)
{
    if(map.isEmpty()) return "{}";
    auto jsonResponse = QJsonDocument::fromVariant(map);
    QString JSON(jsonResponse.toJson(QJsonDocument::Compact));

    qDebug()<<"strigified json"<<JSON;
    return JSON;
}

Linking::Linking(QObject *parent) : QObject(parent)
{

    this->server = new Socket(BAE::LinkPort.toUInt(), this);
    connect(this->server, &Socket::connected, this, &Linking::init);
    connect(this->server, &Socket::message, this, &Linking::parseAsk);
    connect(this->server, &Socket::disconnected, [this](QString id)
    {
        emit this->serverConDisconnected(id);
    });

    connect(&client, &QWebSocket::connected, this, &Linking::onConnected);
    connect(&client, SIGNAL(error(QAbstractSocket::SocketError)), this, SLOT(handleError(QAbstractSocket::SocketError)));
    connect(&client, &QWebSocket::disconnected, this, &Linking::clientConDisconnected);
    connect(&client, &QWebSocket::textMessageReceived, [this](QString msg)
    {
        auto decoded = decode(msg);
        qDebug()<<"client recived message"<<msg;
        emit this->responseReady(decoded);
    });
}

QVariantMap Linking::packResponse(const LINK::CODE &code, const QVariant &content)
{
    QVariantMap map;
    map.insert(BAE::SLANG[BAE::W::CODE], code);
    map.insert(BAE::SLANG[BAE::W::MSG], content);

    return map;
}

void Linking::init(const int &index)
{
    qDebug()<<"Got connected with index"<<index;
}

void Linking::setIp(const QString &ip)
{
    this->IP = ip;
}

QString Linking::getIp()
{
    return this->IP;
}

QString Linking::deviceIp()
{
    auto ipList = this->checkAddresses();

    if(ipList.isEmpty()) return "No IP";

    return ipList.first();
}

QString Linking::getPort()
{
    return BAE::LinkPort;
}

QString Linking::getDeviceName()
{
    return this->deviceName;
}

void Linking::ask(int code, QString msg)
{
    bDebug::Instance()->msg("Sending msg to server: "+QString::number(code)+" :: "+ msg);
    client.sendTextMessage(stringify(packResponse(static_cast<LINK::CODE>(code), msg)));
}

QVariantMap Linking::decode(const QString &json)
{
    bDebug::Instance()->msg("Decoding client msg");
    QJsonParseError jsonParseError;
    auto jsonResponse = QJsonDocument::fromJson(json.toUtf8(), &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError) return QVariantMap ();
    if (!jsonResponse.isObject()) return QVariantMap ();

    QJsonObject mainJsonObject(jsonResponse.object());
    auto data = mainJsonObject.toVariantMap();

    return data;
}

void Linking::onConnected()
{
    qDebug()<<"Got connected to server";
    emit this->devicesLinked();
    this->ask(LINK::CODE::CONNECTED, QSysInfo::prettyProductName());
}

QStringList Linking::checkAddresses()
{
    QList<QHostAddress> list = QNetworkInterface::allAddresses();

    QStringList res;
    for(int nIter=0; nIter<list.count(); nIter++)
    {
        if(!list[nIter].isLoopback())
            if (list[nIter].protocol() == QAbstractSocket::IPv4Protocol )
                res << list[nIter].toString();

    }

    return res;
}

void Linking::connectTo(QString ip, QString port)
{
    this->IP = ip;
    if(this->IP.isEmpty()) return;

    auto url = QUrl(QString("ws://"+this->IP+":"+port));
    client.open(url);
    qDebug()<<url<<ip<<port;
}

void Linking::sendToClient(QVariantMap map)
{
    auto json = stringify(map);

    qDebug()<<"Seing message to client:" <<json;
    qDebug()<<map;
    server->sendMessageTo(0, json);
}

void Linking::handleError(QAbstractSocket::SocketError error)
{
    qDebug()<<error;
    emit this->clientConError("An error happened connecting to server");
}
