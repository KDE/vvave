#include "linking.h"
#include "socket.h"
#include <QHostAddress>
#include <QNetworkInterface>
#include "../../utils/babeconsole.h"
#include <QSysInfo>

Linking::Linking(QObject *parent) : QObject(parent)
{

    this->server = new Socket(BAE::LinkPort.toUInt(), this);
    connect(this->server, &Socket::connected, this, &Linking::init);
    connect(this->server, &Socket::message, [this](QString msg)
    {
        qDebug()<<"Reciving message in server:" << msg;
        this->decode(msg);
    });

    connect(&client, &QWebSocket::connected, this, &Linking::onConnected);
//    connect(&client, &QWebSocket::error, [this](QAbstractSocket::SocketError error)
//    {
//        emit this->clientConError(error);
//    });

    connect(&client, &QWebSocket::disconnected, this, &Linking::closed);
    connect(&client, &QWebSocket::textMessageReceived, [this](QString msg)
    {
        qDebug()<<msg;

    });
}

void Linking::init(const int &index)
{
    qDebug()<<"Got connected with index"<<index;
    emit this->devicesLinked();
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

void Linking::ask(LINK::CODE code, QString msg)
{
    auto JSON = QString("{ %1 : %2, %3 : \"%4\"  }").arg(BAE::SLANG[BAE::W::CODE],
            LINK::DECODE[code],
            BAE::SLANG[BAE::W::MSG],
            msg);
    client.sendTextMessage(JSON);
}

void Linking::decode(const QString &json)
{
    QJsonParseError jsonParseError;
    auto jsonResponse = QJsonDocument::fromJson(json.toUtf8(), &jsonParseError);

    if (jsonParseError.error != QJsonParseError::NoError) return;
    if (!jsonResponse.isObject()) return;

    QJsonObject mainJsonObject(jsonResponse.object());
    auto data = mainJsonObject.toVariantMap();

    auto code = data.value(BAE::SLANG[BAE::W::CODE]).toInt();
    auto msg = data.value(BAE::SLANG[BAE::W::MSG]).toString();

    qDebug()<<code<<msg<<data;

}

void Linking::onConnected()
{
    qDebug()<<"Got connected to server";
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

void Linking::handleError(QAbstractSocket::SocketError error)
{
    qDebug()<<error;
}
