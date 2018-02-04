#ifndef NOTIFICATIONCLIENT_H
#define NOTIFICATIONCLIENT_H

#include <QObject>

class NotificationClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString notification READ notification WRITE setNotification NOTIFY notificationChanged)
public:
    explicit NotificationClient(QObject *parent = 0);

    void setNotification(const QString &notification);
    QString notification() const;

signals:
    void notificationChanged();

private slots:
    void updateAndroidNotification();

private:
    QString m_notification;
};

#endif // NOTIFICATIONCLIENT_H
