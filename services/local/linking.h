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
        PLAYLISTS = 5,
        GETQUERY = 6,
        };

    Q_ENUM_NS(CODE);

    static QMap<CODE, QString> DECODE =
    {
        {CODE::CONNECTED, "CONNECTED"},
        {CODE::ERROR, "ERROR"},
        {CODE::DISCONNECTED, "DISCONNECTED"},
        {CODE::SEARCHFOR, "SEARCHFOR"},
        {CODE::PLAYLISTS, "PLAYLISTS"},
        {CODE::GETQUERY, "GETQUERY"}

    };
}


class Linking : public QObject
{
        Q_OBJECT

    private:
        Socket *server;
        QWebSocket client;
        QString IP;

        QString stringify(const QVariantMap &map);

    public:
        explicit Linking(QObject *parent = nullptr);
        QString deviceName;

        void init(const int &index);
        Q_INVOKABLE void setIp(const QString &ip);
        Q_INVOKABLE QString getIp();
        Q_INVOKABLE QString deviceIp();
        Q_INVOKABLE QString getPort();
        Q_INVOKABLE QString getDeviceName();
        Q_INVOKABLE void ask(int code, QString msg);
        QVariantMap decode(const QString &json);
        void onConnected();
        QStringList checkAddresses();
        Q_INVOKABLE void connectTo(QString ip, QString port);
        Q_INVOKABLE void sendToClient(QVariantMap map);

    signals:
        void devicesLinked();
        void serverConReady(QString deviceName);
        void serverConDisconnected(QString index);

        void clientConDisconnected();
        void clientConError(QString message);
        void parseAsk(QString json);

        void responseReady(QVariantMap map);
    public slots:
        void handleError(QAbstractSocket::SocketError error);

};

#endif // LINKING_H
