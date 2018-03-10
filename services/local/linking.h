#ifndef LINKING_H
#define LINKING_H

#include <QObject>
#include <QWebSocket>
#include "../../utils/bae.h"
#include <QMap>

class Socket;

namespace LINK
{
    Q_NAMESPACE

        enum CODE
        {
        CONNECTED = 1,
        ERROR = 2,
        DISCONNECTED = 3,
        SEARCHFOR = 4,
        };

    Q_ENUM_NS(CODE);

   static QMap<CODE, QString> DECODE =
    {
        {CODE::CONNECTED, "CONNECTED"},
        {CODE::ERROR, "ERROR"},
        {CODE::DISCONNECTED, "DISCONNECTED"},
        {CODE::SEARCHFOR, "SEARCHFOR"}
    };
}


class Linking : public QObject
{
        Q_OBJECT

    private:
        Socket *server;
        QWebSocket client;

        QString IP;

    public:
        explicit Linking(QObject *parent = nullptr);

        void init(const int &index);
        Q_INVOKABLE void setIp(const QString &ip);
        Q_INVOKABLE QString getIp();
        Q_INVOKABLE QString deviceIp();
        Q_INVOKABLE QString getPort();
        Q_INVOKABLE void ask(LINK::CODE code, QString msg);
        void decode(const QString &json);
        void onConnected();
        QStringList checkAddresses();
        Q_INVOKABLE void connectTo(QString ip, QString port);

    signals:
        void closed();
        void devicesLinked();
        void serverConReady(const QString deviceName);

        void clientConError(const QString &message);
    public slots:
        void handleError(QAbstractSocket::SocketError error);

};

#endif // LINKING_H
