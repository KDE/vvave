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

    auto JSON = QString("{ \"%1\" : \"%2\", \"%3\" : \"%4\" }").arg(BAE::SLANG[BAE::W::CODE],
            QString::number(map[BAE::SLANG[BAE::W::CODE]].toInt()),
            BAE::SLANG[BAE::W::MSG],
            map[BAE::SLANG[BAE::W::MSG]].toString());

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

        emit this->responseReady(decode(msg));
    });
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
    auto JSON = QString("{ \"%1\" : \"%2\", \"%3\" : \"%4\" }").arg(BAE::SLANG[BAE::W::CODE],
            QString::number(code),
            BAE::SLANG[BAE::W::MSG],
            msg);

    client.sendTextMessage(JSON);
    qDebug()<<"msg sent as json to server";
}

QVariantMap Linking::decode(const QString &json)
{
    qDebug()<<"trying to decode msg";
    QJsonParseError jsonParseError;
    auto jsonResponse = QJsonDocument::fromJson(json.toUtf8(), &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError) return QVariantMap ();
    if (!jsonResponse.isObject()) return QVariantMap ();

    qDebug()<<"trying to decode msg2";

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

    server->sendMessageTo(0, json);
}

void Linking::handleError(QAbstractSocket::SocketError error)
{
    emit this->clientConError("An error happened connecting to server");
}
