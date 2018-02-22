#ifndef NOTIFICATIONCLIENT_H
#define NOTIFICATIONCLIENT_H

#include <QObject>

class NotificationClient : public QObject
{
    Q_OBJECT
public:
    explicit NotificationClient(QObject *parent = 0);

    void notify(const QString &notification);
    QString notification() const;

signals:
    void notificationChanged();

private slots:
    void updateAndroidNotification();

private:
    QString m_notification;
};

#endif // NOTIFICATIONCLIENT_H
